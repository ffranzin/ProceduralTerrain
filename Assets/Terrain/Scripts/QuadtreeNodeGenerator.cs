using UnityEngine;

namespace MyTerrain
{
	public static class QuadtreeNodeGenerator {

		private static ComputeShader heightMapCompute = (ComputeShader)Resources.Load("HeightmapGenerator");
		private static ComputeShader normalMapCompute = (ComputeShader)Resources.Load("NormalmapGenerator");

		private static int heightmapKernel;
		private static int normalmapKernel;
        private static int getHeightKernel;

        private static int[] buff = new int[2];

        public static void Initialize()
		{
			heightmapKernel = heightMapCompute.FindKernel("GenerateHeightmap");
			normalmapKernel = normalMapCompute.FindKernel("GenerateNormalmap");
            getHeightKernel = heightMapCompute.FindKernel("GenerateAndGetHeightmap");
        }


		public static void DispatchHeightmapKernel(QuadTreeNode node)
		{
			node.m_MinMaxBuffer.SetData(new int[] { int.MaxValue, int.MinValue });
			
			heightMapCompute.SetInt("_HeightmapSize", MyTerrain.HeightmapSize);
			heightMapCompute.SetInt("_HeightmapSizePadded", MyTerrain.HeightmapSizePadded);

			heightMapCompute.SetVector("_HeightmapAtlasPos", new Vector2(node.HeightmapDescriptor.tl.x, node.HeightmapDescriptor.tl.y));
			heightMapCompute.SetTexture(heightmapKernel, "_HeightmapAtlas", node.HeightmapDescriptor.atlas.texture);

			heightMapCompute.SetVector("_NodePos", new Vector2(node.m_BoundsWorld.min.x, node.m_BoundsWorld.min.z));
			heightMapCompute.SetFloat("_NodeSize", node.m_BoundsWorld.size.x);

			heightMapCompute.SetBuffer(heightmapKernel, "_MinMaxBuffer", node.m_MinMaxBuffer);
			
			int ngroups = Mathf.CeilToInt(node.HeightmapDescriptor.size / 8.0f);
			
			heightMapCompute.Dispatch(heightmapKernel, ngroups, ngroups, 1);

			node.m_MinMaxBuffer.GetData(buff);

			node.UpdateMinMax(buff[0], buff[1]);
		}


		public static float[,] DispatchAngGetHeightKernel(Rect rect, out float min, out float max)
		{
			int size = (int)(rect.size.x * 2) + 1;

			ComputeBuffer heightsOnGPU = new ComputeBuffer(size * size, sizeof(float));
			ComputeBuffer minMaxOnGPU = new ComputeBuffer(2, sizeof(int));
			
			float[,] heights = new float[size, size];
			int[] minMax = new int[2] { int.MaxValue, int.MinValue};

			minMaxOnGPU.SetData(minMax);

			heightMapCompute.SetBuffer(getHeightKernel, "_GetHeight", heightsOnGPU);
			heightMapCompute.SetBuffer(getHeightKernel, "_MinMaxBuffer", minMaxOnGPU);

			heightMapCompute.SetVector("_NodePos", rect.min);
			heightMapCompute.SetFloat("_NodeSize", rect.size.x);
			heightMapCompute.SetInt("_PixelCount", size);

			int nGroups = Mathf.CeilToInt(size / 8.0f);

			heightMapCompute.Dispatch(getHeightKernel, nGroups, nGroups, 1);

			heightsOnGPU.GetData(heights);

			minMaxOnGPU.GetData(minMax);
			min = (float)minMax[0];
			max = (float)minMax[1];

			return heights;
		}


		public static void DispatchNormalmapKernel(QuadTreeNode node)
		{
			normalMapCompute.SetVector("_HeightmapAtlasPos", new Vector2(node.HeightmapDescriptor.tl.x, node.HeightmapDescriptor.tl.y));
			normalMapCompute.SetVector("_NormalmapAtlasPos", new Vector2(node.NormalmapDescriptor.tl.x, node.NormalmapDescriptor.tl.y));
			
			normalMapCompute.SetInt("_NormalmapSizePadded", MyTerrain.NormalmapSizePadded); 

			normalMapCompute.SetFloat("_NodeSize", node.m_BoundsWorld.size.x);

			normalMapCompute.SetTexture(normalmapKernel, "_HeightmapAtlas", node.HeightmapDescriptor.atlas.texture);
			normalMapCompute.SetTexture(normalmapKernel, "_NormalmapAtlas", node.NormalmapDescriptor.atlas.texture);

			int ngroups = Mathf.CeilToInt(node.NormalmapDescriptor.size / 8.0f);
			normalMapCompute.Dispatch(normalmapKernel, ngroups, ngroups, 1);
		}
	}
}