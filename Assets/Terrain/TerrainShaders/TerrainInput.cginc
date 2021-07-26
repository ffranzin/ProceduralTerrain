
#ifndef TERRAIN_INPUT
#define TERRAIN_INPUT

struct TerrainVertexOutputDeferred
{
    UNITY_POSITION(pos);
    float4 tex                            : TEXCOORD0;
    float3 eyeVec                         : TEXCOORD1;
    float4 tangentToWorldAndPackedData[3] : TEXCOORD2;    // [3x3:tangentToWorld | 1x3:viewDirForParallax or worldPos]
    half4 ambientOrLightmapUV             : TEXCOORD5;    // SH or Lightmap UVs
    half3 color							  : COLOR;
	float3 posWorld                       : TEXCOORD6;

    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};


UNITY_DECLARE_TEX2DARRAY(_TerrainTextureArrayAlbedo);
UNITY_DECLARE_TEX2DARRAY(_TerrainTextureArrayNormal);
UNITY_DECLARE_TEX2DARRAY(_TerrainTextureArrayAO);
UNITY_DECLARE_TEX2DARRAY(_TerrainTextureArraySpecular);
UNITY_DECLARE_TEX2DARRAY(_TerrainTextureArraySmoothness);


StructuredBuffer<float4> _PositionBuffer;
StructuredBuffer<float2> _HeightmapAtlasPosBuffer;
StructuredBuffer<float2> _NormalmapAtlasPosBuffer;

int2 _NormalmapAtlasDimension; 
int2 _HeightmapAtlasDimension;

UNITY_DECLARE_TEX2D(_HeightmapAtlas);
UNITY_DECLARE_TEX2D(_NormalmapAtlas);

int _HeightmapSizePadded;
int _HeightmapSize;
int _NormalmapSizePadded;
int _NormalmapSize;

#endif