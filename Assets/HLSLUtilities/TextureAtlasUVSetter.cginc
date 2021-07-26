#ifndef TEXTURE_ATLAS_UV_SETTER
#define TEXTURE_ATLAS_UV_SETTER

#include "Assets/HLSLUtilities/MathUtils.cginc"

struct TexturesAtlasMinMax
{
	float2 min;
	float2 max;
};

StructuredBuffer<TexturesAtlasMinMax> _TexturesAtlasMinMax;
int _TexturesAtlasTexturesCount;

int TexturesAtlasMinMaxIndex;



inline void CreateUvMinMax(float2 seed)
{
	TexturesAtlasMinMaxIndex = CustomRand(seed, 0, _TexturesAtlasTexturesCount); 
}


inline float2 AdjustTexCoord(float2 uv)
{
	return float2(Remap(uv.x, 0.0, 1.0, _TexturesAtlasMinMax[TexturesAtlasMinMaxIndex].min.x, _TexturesAtlasMinMax[TexturesAtlasMinMaxIndex].max.x),
				  Remap(uv.y, 0.0, 1.0, _TexturesAtlasMinMax[TexturesAtlasMinMaxIndex].min.y, _TexturesAtlasMinMax[TexturesAtlasMinMaxIndex].max.y));
}

#endif