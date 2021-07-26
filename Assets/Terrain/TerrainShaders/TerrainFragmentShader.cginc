#ifndef TERRAIN_FRAGMENT_SHADER
// Upgrade NOTE: excluded shader from OpenGL ES 2.0 because it uses non-square matrices
#pragma exclude_renderers gles
#define TERRAIN_FRAGMENT_SHADER

#include "Assets/HLSLUtilities/MathUtils.cginc"
#include "Assets/Terrain/TerrainShaders/Heightmap.cginc"

float _UVTiling;
float _SliderTest;
SamplerState my_linear_clamp_sampler;


void SnowInfluence(float3 worldPos, inout int textureIndex, inout float textureInfluence)
{
    const float snowMinAltitude = 1000;
    const float snowTransitionsRange = 1000;
    
    float height = worldPos.y + simplexfbm2D(worldPos.xz, 2, 0.0005, 2, 0.5, 3) * snowTransitionsRange;

    textureInfluence = Remap(height, snowMinAltitude, snowMinAltitude + snowTransitionsRange, 0.0, 1.0);
    textureIndex = 5;
}


void GrassInfluence(float3 worldPos, inout int textureIndex, inout float textureInfluence)
{
    const float maxGrassDistance = 1000;

    float cameraDistance = saturate(length(_WorldSpaceCameraPos - worldPos) / maxGrassDistance);
    float amplitude = lerp(1.5, 0.0, cameraDistance);

    textureInfluence = 1.0 - saturate(simplexfbm2D(worldPos.xz, 4, 0.04, 2, 0.5, amplitude));
    textureIndex = 1;
}


void CliffInfluence(float3 worldPos, float3 worldNormal, inout int textureIndex, inout float textureInfluence)
{
    float normalizedSlope = dot(float3(0, 1, 0), worldNormal);

    textureInfluence = Remap(normalizedSlope, 0.1, .5, 1, 0.0);

    textureInfluence = saturate(textureInfluence);
    textureIndex = 4;
}


float3 PerPixelWorldNormalCustom(half3 normalTangent, float4 tangentToWorldAndPackedData[3])
{
    half3 tangent = tangentToWorldAndPackedData[0].xyz;
    half3 binormal = tangentToWorldAndPackedData[1].xyz;
    half3 normal = tangentToWorldAndPackedData[2].xyz;

    float3 normalWorld = NormalizePerPixelNormal(tangent * normalTangent.x + binormal * normalTangent.y + normal * normalTangent.z); // @TODO: see if we can squeeze this normalize on SM2.0 as well

    return normalWorld;
}


void BlendFragmentCommonData(FragmentCommonData s1, FragmentCommonData s2, float influence, inout FragmentCommonData s)
{
    s.diffColor = lerp(s1.diffColor, s2.diffColor, influence);
    s.normalWorld = lerp(s1.normalWorld, s2.normalWorld, influence);
    s.specColor = lerp(s1.specColor, s2.specColor, influence);
    s.smoothness = lerp(s1.smoothness, s2.smoothness, influence);
}



void TerrainFragDeferred(
    TerrainVertexOutputDeferred i,
    out half4 outGBuffer0 : SV_Target0,
    out half4 outGBuffer1 : SV_Target1,
    out half4 outGBuffer2 : SV_Target2,
    out half4 outEmission : SV_Target3 // RT3: emission (rgb), --unused-- (a)
#if defined(SHADOWS_SHADOWMASK) && (UNITY_ALLOWED_MRT_COUNT > 4)
    ,out half4 outShadowMask : SV_Target4       // RT4: shadowmask (rgba)
#endif
)
{
#if (SHADER_TARGET < 30)
    outGBuffer0 = 1;
    outGBuffer1 = 1;
    outGBuffer2 = 0;
    outEmission = 0;
#if defined(SHADOWS_SHADOWMASK) && (UNITY_ALLOWED_MRT_COUNT > 4)
            outShadowMask = 1;
#endif
    return;
#endif

    UNITY_APPLY_DITHER_CROSSFADE(i.pos.xy);
    UNITY_SETUP_INSTANCE_ID(i);
	

#ifndef UNITY_PROCEDURAL_INSTANCING_ENABLED
    uint unity_InstanceID = 0;
#endif

    int textureIndex = 0;
    float textureInfluence = 0;
    
	FRAGMENT_SETUP(material_1)
	FRAGMENT_SETUP(material_2)

    float3x3 tbn = float3x3(i.tangentToWorldAndPackedData[0].xyz,
					        i.tangentToWorldAndPackedData[1].xyz,
					        i.tangentToWorldAndPackedData[2].xyz);
    
	
    float2 UV = i.posWorld.xz * _UVTiling;

    float occlusion_1, occlusion_2;

    //Ground------------------------------------------
    textureIndex = 3;
    material_1.diffColor = UNITY_SAMPLE_TEX2DARRAY(_TerrainTextureArrayAlbedo, float3(UV, textureIndex)).rgb;
    material_1.normalWorld = UNITY_SAMPLE_TEX2DARRAY(_TerrainTextureArrayNormal, float3(UV, textureIndex)).rgb;
    material_1.specColor = UNITY_SAMPLE_TEX2DARRAY(_TerrainTextureArraySpecular, float3(UV, textureIndex)).rgb;
    material_1.smoothness = UNITY_SAMPLE_TEX2DARRAY(_TerrainTextureArraySmoothness, float3(UV, textureIndex)).r;
    occlusion_1 = UNITY_SAMPLE_TEX2DARRAY(_TerrainTextureArrayAO, float3(UV, textureIndex)).r;

    //Grass------------------------------------------
    GrassInfluence(i.posWorld, textureIndex, textureInfluence);
    material_2.diffColor = UNITY_SAMPLE_TEX2DARRAY(_TerrainTextureArrayAlbedo, float3(UV, textureIndex)).rgb;
    material_2.normalWorld = UNITY_SAMPLE_TEX2DARRAY(_TerrainTextureArrayNormal, float3(UV, textureIndex)).rgb;
    material_2.specColor = UNITY_SAMPLE_TEX2DARRAY(_TerrainTextureArraySpecular, float3(UV, textureIndex)).rgb;
    material_2.smoothness = UNITY_SAMPLE_TEX2DARRAY(_TerrainTextureArraySmoothness, float3(UV, textureIndex)).r;
    occlusion_2 = UNITY_SAMPLE_TEX2DARRAY(_TerrainTextureArrayAO, float3(UV, textureIndex)).r;

    BlendFragmentCommonData(material_1, material_2, textureInfluence, material_1);
    occlusion_1 = lerp(occlusion_1, occlusion_2, textureInfluence);

    //Snow------------------------------------------
    SnowInfluence(i.posWorld, textureIndex, textureInfluence);
    material_2.diffColor = UNITY_SAMPLE_TEX2DARRAY(_TerrainTextureArrayAlbedo, float3(UV, textureIndex)).rgb;
    material_2.normalWorld = UNITY_SAMPLE_TEX2DARRAY(_TerrainTextureArrayNormal, float3(UV, textureIndex)).rgb;
    material_2.specColor = UNITY_SAMPLE_TEX2DARRAY(_TerrainTextureArraySpecular, float3(UV, textureIndex)).rgb;
    material_2.smoothness = UNITY_SAMPLE_TEX2DARRAY(_TerrainTextureArraySmoothness, float3(UV, textureIndex)).r;
    occlusion_2 = UNITY_SAMPLE_TEX2DARRAY(_TerrainTextureArrayAO, float3(UV, textureIndex)).r;

    BlendFragmentCommonData(material_1, material_2, textureInfluence, material_1);
    occlusion_1 = lerp(occlusion_1, occlusion_2, textureInfluence);

    //Cliff------------------------------------------
    CliffInfluence(i.posWorld, i.tangentToWorldAndPackedData[2].xyz, textureIndex, textureInfluence);
    UV = float2(i.posWorld.xz * 0.0010);

    material_2.diffColor = UNITY_SAMPLE_TEX2DARRAY(_TerrainTextureArrayAlbedo, float3(UV, textureIndex)).rgb * _Color;
    material_2.normalWorld = UNITY_SAMPLE_TEX2DARRAY(_TerrainTextureArrayNormal, float3(UV, textureIndex)).rgb;
    material_2.specColor = UNITY_SAMPLE_TEX2DARRAY(_TerrainTextureArraySpecular, float3(UV, textureIndex)).rgb;
    material_2.smoothness = UNITY_SAMPLE_TEX2DARRAY(_TerrainTextureArraySmoothness, float3(UV, textureIndex)).r;
    occlusion_2 = UNITY_SAMPLE_TEX2DARRAY(_TerrainTextureArrayAO, float3(UV, textureIndex)).r;

    BlendFragmentCommonData(material_1, material_2, textureInfluence, material_1);
    occlusion_1 = lerp(occlusion_1, occlusion_2, textureInfluence);

    UnityLight dummyLight = DummyLight();
    half atten = 1;


    material_1.normalWorld = PerPixelWorldNormalCustom(material_1.normalWorld, i.tangentToWorldAndPackedData);
    material_1.diffColor *= _Color;


#if UNITY_ENABLE_REFLECTION_BUFFERS
    bool sampleReflectionsInDeferred = false;
#else
     bool sampleReflectionsInDeferred = true;
#endif

    UnityGI gi = FragmentGI(material_1, occlusion_1, i.ambientOrLightmapUV, atten, dummyLight, sampleReflectionsInDeferred);
    
    half3 emissiveColor = UNITY_BRDF_PBS(material_1.diffColor, material_1.specColor, material_1.oneMinusReflectivity, material_1.smoothness, material_1.normalWorld, -material_1.eyeVec, gi.light, gi.indirect).rgb;
    

#ifndef UNITY_HDR_ON
    emissiveColor.rgb = exp2(-emissiveColor.rgb);
#endif

    UnityStandardData data;
    data.diffuseColor = material_1.diffColor;
    data.occlusion = occlusion_1;
    data.specularColor = material_1.specColor;
    data.smoothness = material_1.smoothness;
    data.normalWorld = material_1.normalWorld;

    UnityStandardDataToGbuffer(data, outGBuffer0, outGBuffer1, outGBuffer2);

    // Emissive lighting buffer
    outEmission = half4(emissiveColor, 1);

    // Baked direct lighting occlusion if any
#if defined(SHADOWS_SHADOWMASK) && (UNITY_ALLOWED_MRT_COUNT > 4)
        outShadowMask = UnityGetRawBakedOcclusions(i.ambientOrLightmapUV.xy, IN_WORLDPOS(i));
#endif
}

#endif
