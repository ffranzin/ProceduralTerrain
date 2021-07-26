#ifndef TERRAIN_HEIGHTMAP
#define TERRAIN_HEIGHTMAP

#include "Assets/HLSLUtilities/NoiseUtils.cginc"
#include "Assets/HLSLUtilities/MathUtils.cginc"


struct NoiseParams
{
	int noiseType;
	float2 offset;
	int octaves;
	float frequency;
	float lacunarity;
	float gain;
	float amp;
	float heightMultiplier;
	float heightOffset;
};

StructuredBuffer<NoiseParams> _TerrainNoisesParamns;

static float SLOPE_DISTANCE = 1.0;
static float SLOPE_DISTANCE_DIAGONAL = sqrt(2 * SLOPE_DISTANCE * SLOPE_DISTANCE);





float GetHeightBase(float2 worldPos)
{
	uint count, stride;
	_TerrainNoisesParamns.GetDimensions(count, stride);

	float height = 0;

	for (int i = 0; i < count; i++)
	{
		float noise = 0;

		if (_TerrainNoisesParamns[i].noiseType == SIMPLEX)
		{
			noise = simplexfbm2D(worldPos + _TerrainNoisesParamns[i].offset, _TerrainNoisesParamns[i].octaves, _TerrainNoisesParamns[i].frequency, _TerrainNoisesParamns[i].lacunarity, _TerrainNoisesParamns[i].gain, _TerrainNoisesParamns[i].amp);
		}
		else if (_TerrainNoisesParamns[i].noiseType == GRADIENT)
		{
			noise = gradientfbm2D(worldPos + _TerrainNoisesParamns[i].offset, _TerrainNoisesParamns[i].octaves, _TerrainNoisesParamns[i].frequency, _TerrainNoisesParamns[i].lacunarity, _TerrainNoisesParamns[i].gain, _TerrainNoisesParamns[i].amp);
		}
		else if (_TerrainNoisesParamns[i].noiseType == RIDGE_SIMPLEX)
		{
			noise = ridgesimplexfbm2D(worldPos + _TerrainNoisesParamns[i].offset, _TerrainNoisesParamns[i].octaves, _TerrainNoisesParamns[i].frequency, _TerrainNoisesParamns[i].lacunarity, _TerrainNoisesParamns[i].gain, _TerrainNoisesParamns[i].amp);
		}
		else if (_TerrainNoisesParamns[i].noiseType == RIDGE_GRADIENT)
		{
			noise = ridgegradientfbm2D(worldPos + _TerrainNoisesParamns[i].offset, _TerrainNoisesParamns[i].octaves, _TerrainNoisesParamns[i].frequency, _TerrainNoisesParamns[i].lacunarity, _TerrainNoisesParamns[i].gain, _TerrainNoisesParamns[i].amp);
		}

		//noise = min(noise, _TerrainNoisesParamns[i].amplitudeRemap.x);
		//noise = max(noise, _TerrainNoisesParamns[i].amplitudeRemap.x);

		//noise = smoothstep(noise, _TerrainNoisesParamns[i].amplitudeRemap.x, _TerrainNoisesParamns[i].amplitudeRemap.y);

		//noise = Remap(noise, -_TerrainNoisesParamns[i].amplitudeRemap.x, _TerrainNoisesParamns[i].amplitudeRemap.y, 0.0, 1.0);
		height += noise * _TerrainNoisesParamns[i].heightMultiplier + _TerrainNoisesParamns[i].heightOffset;
	}

	return height;
}

#endif