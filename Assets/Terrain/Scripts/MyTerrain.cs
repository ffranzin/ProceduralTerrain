using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;
using Utils.Cameras;

namespace MyTerrain
{
    public class TerrainSettings
    {
        public const int TERRAIN_SIZE = 524288;
        public const int LEAF_NODE_SIZE = 32;
        public const float TERRAIN_RESOLUTION = 0.5f;
    }

    public class MyTerrain : Singleton<MyTerrain>
    {
        [SerializeField] private bool freezeSelection = false;
        [SerializeField] private bool enableRender = true;
        [SerializeField] private bool drawBounds = false;

        public List<QuadTreeNode> m_LODSelection;
        public QuadTree m_QuadTree;
        public TerrainLODSettings m_TerrainLODSettings;
        public TerrainRenderer m_TerrainRenderer;

        public const int MAX_NODES_SELECTED = 1024;

        public static int GridSize = (int)(TerrainSettings.LEAF_NODE_SIZE / TerrainSettings.TERRAIN_RESOLUTION);
        public static int HeightmapSize = GridSize + 1;
        public static int NormalmapSize = GridSize + 1;
        
        public static int HeightmapSizePadded = HeightmapSize + 2;
        public static int NormalmapSizePadded = NormalmapSize + 2;
        

        public Atlas m_HeightmapAtlas { get; private set; }
        public Atlas m_NormalmapAtlas { get; private set; }

        public int COLLECTION_INTERVAL = 180;
        private int lastCollection = 0;


        [Header("Heightmap Noises")]
        public NoiseParams[] terrainNoiseParameters;
        public ComputeBuffer terrainNoiseParametersOnGPU;

        [Header("Heightmap Debug")]
        [SerializeField] private RenderTexture heightmapDebug;


        [Header("Terrain Material")]
        public Material instanceMaterial;

        private void Awake()
        {
            m_HeightmapAtlas = new Atlas(RenderTextureFormat.RFloat, FilterMode.Bilinear, 8192, HeightmapSizePadded, true, "_HeightmapAtlas");
            m_NormalmapAtlas = new Atlas(RenderTextureFormat.ARGBHalf, FilterMode.Bilinear, 8192, NormalmapSizePadded, true, "NormalmapAtlas");

            QuadTreeNodePool.InitializePool();
            QuadtreeNodeGenerator.Initialize();

            m_QuadTree = new QuadTree(this);
            m_TerrainLODSettings = new TerrainLODSettings(this);
            m_TerrainRenderer = new TerrainRenderer(this);
            m_LODSelection = new List<QuadTreeNode>(MAX_NODES_SELECTED);

            Debug.Assert(instanceMaterial != null, "Material Null");

            heightmapDebug = m_HeightmapAtlas.texture;

            GetComponent<TerrainTexture>().SetTerrainTexturesOnMaterial(instanceMaterial);

            UpdateTerrainNoisesOnGPU();
        }

        private void SetGlobalBuffers()
        {
            Shader.SetGlobalTexture("_HeightmapAtlas", m_HeightmapAtlas.texture);
            Shader.SetGlobalTexture("_NormalmapAtlas", m_NormalmapAtlas.texture);
        }

        private void UpdateTerrainNoisesOnGPU()
        {

            terrainNoiseParametersOnGPU = new ComputeBuffer(terrainNoiseParameters.Length, Marshal.SizeOf<NoiseParams>());
            terrainNoiseParametersOnGPU.SetData(terrainNoiseParameters);
            Shader.SetGlobalBuffer("_TerrainNoisesParamns", terrainNoiseParametersOnGPU);
        }


        private void Reset()
        {
            m_QuadTree?.Reset();
            m_TerrainLODSettings?.GenerateViewRanges();
            UpdateTerrainNoisesOnGPU();
        }


        private void TerrainRender(Camera cam)
        {
            if (!freezeSelection)
            {
                MainCamera.Instance.Camera = cam;
                QuadTreeTraversal.TerrainNodeSelection(m_LODSelection, m_TerrainLODSettings);
            }
            if (enableRender)
            {
                m_TerrainRenderer.Render(cam, m_LODSelection);
            }
        }


        private void Update()
        {
            if (Input.GetKeyUp(KeyCode.N))
            {
                freezeSelection = !freezeSelection;
            }
            if (Input.GetKeyUp(KeyCode.B))
            {
                drawBounds = !drawBounds;
            }
            if (Input.GetKeyUp(KeyCode.Space))
            {
                Reset();
            }

#if UNITY_EDITOR
            GetComponent<TerrainTexture>().SetTerrainTexturesOnMaterial(instanceMaterial);
#endif

            SetGlobalBuffers();

            TerrainRender(Camera.main);
        }


        private void FixedUpdate()
        {
            if (!freezeSelection && Time.frameCount - lastCollection >= COLLECTION_INTERVAL)
            {
                m_QuadTree.CollectOldNodes();
                lastCollection = Time.frameCount;
            }
        }



        private void OnDrawGizmos()
        {
            if (m_LODSelection != null && drawBounds)
            {
                foreach (QuadTreeNode node in m_LODSelection)
                {
                    UnityEngine.Random.InitState(node.m_Depth);
                    Gizmos.color = UnityEngine.Random.ColorHSV();

                    Gizmos.DrawWireCube(node.m_BoundsWorld.center, node.m_BoundsWorld.size);
                }

                Gizmos.color = new Color(1, 0, 0, 0.4f);
                Gizmos.DrawSphere(Camera.main.transform.position, 120);
            }
        }


        private void OnValidate()
        {
            Reset();
        }


        private void OnDestroy()
        {
            m_HeightmapAtlas?.Release();
            m_HeightmapAtlas = null;

            m_NormalmapAtlas?.Release();
            m_NormalmapAtlas = null;

            terrainNoiseParametersOnGPU?.Release();
            terrainNoiseParametersOnGPU = null;

            QuadTreeNodePool.ReleasePool();
            m_TerrainRenderer?.Destroy();
        }
    }
}
