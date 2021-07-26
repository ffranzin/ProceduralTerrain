using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace MyTerrain
{
    public class TerrainRenderer
    {
        private readonly MyTerrain m_Terrain;

        private readonly Mesh m_InstanceGridMesh;

        private readonly Vector2[] _HeightmapAtlasPos;
        private readonly Vector2[] normalmapAtlasPos;
        private readonly Vector4[] positions;

        private readonly MaterialPropertyBlock mpb;
        private readonly uint[] args = new uint[5] { 0, 0, 0, 0, 0 };

        private ComputeBuffer m_PositionBuffer;
        private ComputeBuffer m_ArgsBuffer;
        private ComputeBuffer m_HeightmapAtlasPosBuffer;
        private ComputeBuffer m_NormalmapAtlasPosBuffer;

        public TerrainRenderer(MyTerrain terrain)
        {
            m_Terrain = terrain;

            mpb = new MaterialPropertyBlock();

            m_InstanceGridMesh = CreateGridMesh(MyTerrain.GridSize);

            positions = new Vector4[MyTerrain.MAX_NODES_SELECTED];
            _HeightmapAtlasPos = new Vector2[MyTerrain.MAX_NODES_SELECTED];
            normalmapAtlasPos = new Vector2[MyTerrain.MAX_NODES_SELECTED];

            SetComputeBuffers();
            SetUniforms();
        }


        public void Render(Camera cam, List<QuadTreeNode> selection)
        {
            if (selection != null && selection.Count > 0)
            {
                UpdateBuffers(selection);

                Graphics.DrawMeshInstancedIndirect(m_InstanceGridMesh, 0, m_Terrain.instanceMaterial, new Bounds(Vector3.zero, Vector3.one * float.MaxValue), m_ArgsBuffer, 0, mpb, ShadowCastingMode.Off, true, 0, cam, LightProbeUsage.BlendProbes);
            }
        }

        private void SetComputeBuffers()
        {
            m_ArgsBuffer = new ComputeBuffer(1, args.Length * sizeof(uint), ComputeBufferType.IndirectArguments);
            m_PositionBuffer = new ComputeBuffer(MyTerrain.MAX_NODES_SELECTED, 16);
            m_HeightmapAtlasPosBuffer = new ComputeBuffer(MyTerrain.MAX_NODES_SELECTED, sizeof(float) * 2);
            m_NormalmapAtlasPosBuffer = new ComputeBuffer(MyTerrain.MAX_NODES_SELECTED, sizeof(float) * 2);
        }

        private void SetUniforms()
        {
            mpb.SetTexture("_HeightmapAtlas", m_Terrain.m_HeightmapAtlas.texture);
            mpb.SetTexture("_NormalmapAtlas", m_Terrain.m_NormalmapAtlas.texture);

            mpb.SetBuffer("_HeightmapAtlasPosBuffer", m_HeightmapAtlasPosBuffer);
            mpb.SetBuffer("_NormalmapAtlasPosBuffer", m_NormalmapAtlasPosBuffer);

            mpb.SetBuffer("_PositionBuffer", m_PositionBuffer);

            Shader.SetGlobalInt("_HeightmapSize", MyTerrain.HeightmapSize);
            Shader.SetGlobalInt("_HeightmapSizePadded", MyTerrain.HeightmapSizePadded);
            Shader.SetGlobalInt("_NormalmapSize", MyTerrain.NormalmapSize);
            Shader.SetGlobalInt("_NormalmapSizePadded", MyTerrain.NormalmapSizePadded);

            Shader.SetGlobalVector("_HeightmapAtlasDimension", new Vector2(m_Terrain.m_HeightmapAtlas.texture.width, m_Terrain.m_HeightmapAtlas.texture.height));
            Shader.SetGlobalVector("_NormalmapAtlasDimension", new Vector2(m_Terrain.m_NormalmapAtlas.texture.width, m_Terrain.m_NormalmapAtlas.texture.height));
        }


        private void UpdateBuffers(List<QuadTreeNode> selection)
        {
            int instanceCount = Mathf.Min(selection.Count, MyTerrain.MAX_NODES_SELECTED);

            uint numIndices = (m_InstanceGridMesh != null) ? m_InstanceGridMesh.GetIndexCount(0) : 0;
            args[0] = numIndices;
            args[1] = (uint)instanceCount;
            m_ArgsBuffer.SetData(args);

            for (int i = 0; i < instanceCount; i++)
            {
                Bounds nodeBounds = selection[i].m_BoundsWorld;

                positions[i] = new Vector4(nodeBounds.min.x, 0, nodeBounds.min.z, nodeBounds.size.x);
                _HeightmapAtlasPos[i] = selection[i].HeightmapDescriptor.tl;
                normalmapAtlasPos[i] = selection[i].NormalmapDescriptor.tl;
            }

            m_PositionBuffer.SetData(positions, 0, 0, instanceCount);
            m_HeightmapAtlasPosBuffer.SetData(_HeightmapAtlasPos, 0, 0, instanceCount);
            m_NormalmapAtlasPosBuffer.SetData(normalmapAtlasPos, 0, 0, instanceCount);

            SetUniforms();
        }


        private Mesh CreateGridMesh(int size)
        {
            Mesh grid = new Mesh();

            // Gen vertices
            Vector3[] vertices = new Vector3[(size + 1) * (size + 1)];
            Vector2[] uvs = new Vector2[vertices.Length];

            for (int i = 0, y = 0; y <= size; y++)
            {
                for (int x = 0; x <= size; x++, i++)
                {
                    uvs[i] = new Vector2(x / (float)size, y / (float)size);

                    vertices[i] = new Vector3(x / (float)size, 0.0f, y / (float)size);
                }
            }

            int[] triangles = new int[size * size * 6];
            for (int ti = 0, vi = 0, y = 0; y < size; y++, vi++)
            {
                for (int x = 0; x < size; x++, ti += 6, vi++)
                {
                    triangles[ti] = vi + size + 1;//vi;
                    triangles[ti + 4] = triangles[ti + 1] = vi + size + 2;//vi + 1;
                    triangles[ti + 3] = triangles[ti + 2] = vi;//vi + size + 1;
                    triangles[ti + 5] = vi + 1;//vi + size + 2;
                }
            }

            grid.vertices = vertices;
            grid.uv = uvs;
            grid.triangles = triangles;
            grid.RecalculateTangents();
            grid.RecalculateNormals();
            grid.RecalculateBounds();
            grid.UploadMeshData(false);

            return grid;
        }

        private void OnDisable()
        {
            m_PositionBuffer?.Release();
            m_PositionBuffer = null;

            m_ArgsBuffer?.Release();
            m_ArgsBuffer = null;
        }

        public void Destroy()
        {
            m_PositionBuffer?.Release();
            m_ArgsBuffer?.Release();
            m_HeightmapAtlasPosBuffer?.Release();
            m_NormalmapAtlasPosBuffer?.Release();

            m_PositionBuffer = null;
            m_ArgsBuffer = null;
            m_HeightmapAtlasPosBuffer = null;
            m_NormalmapAtlasPosBuffer = null;
        }
    }
}