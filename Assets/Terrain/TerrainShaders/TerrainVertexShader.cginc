#ifndef TERRAIN_VERTEX_SHADER
#define TERRAIN_VERTEX_SHADER

TerrainVertexOutputDeferred TerrainVertexDeferred(VertexInput v)
{
    UNITY_SETUP_INSTANCE_ID(v);
    TerrainVertexOutputDeferred o;
    UNITY_INITIALIZE_OUTPUT(TerrainVertexOutputDeferred, o);
    UNITY_TRANSFER_INSTANCE_ID(v, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

	// declare unity_InstanceID in this so we don't need to enclose everything inside UNITY_PROCEDURAL_INSTANCING_ENABLED
#ifndef UNITY_PROCEDURAL_INSTANCING_ENABLED
    uint unity_InstanceID = 0;
#endif
	
    float2 uv = clamp(v.vertex.xz, 0, 1);
	 
    float2 heightmapPixelPos = _HeightmapAtlasPosBuffer[unity_InstanceID] + float2(1, 1) + uv * (_HeightmapSize - 1);
    float2 normalmapPixelPos = _NormalmapAtlasPosBuffer[unity_InstanceID] + float2(1, 1) + uv * (_NormalmapSize - 1);
    v.vertex.y = _HeightmapAtlas.Load(int3(heightmapPixelPos, 0)).x;
    v.normal.xyz = _NormalmapAtlas.Load(int3(normalmapPixelPos, 0)).rgb;

	float4 posWorld = mul(unity_ObjectToWorld, v.vertex);

	o.posWorld = posWorld.xyz; 

	o.pos = UnityObjectToClipPos(v.vertex);
	o.tex = TexCoords(v);
	o.eyeVec = NormalizePerVertexNormal(posWorld.xyz - _WorldSpaceCameraPos);

	float3 normalWorld = UnityObjectToWorldNormal(v.normal);
	float4 tangentWorld = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
	float3x3 tangentToWorld = CreateTangentToWorldPerVertex(normalWorld, tangentWorld.xyz, tangentWorld.w);

	o.tangentToWorldAndPackedData[0].xyz = tangentToWorld[0];
	o.tangentToWorldAndPackedData[1].xyz = tangentToWorld[1];
	o.tangentToWorldAndPackedData[2].xyz = tangentToWorld[2];

    o.ambientOrLightmapUV = 0;
#ifdef LIGHTMAP_ON
        o.ambientOrLightmapUV.xy = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
#elif UNITY_SHOULD_SAMPLE_SH
        o.ambientOrLightmapUV.rgb = ShadeSHPerVertex (normalWorld, o.ambientOrLightmapUV.rgb);
#endif
#ifdef DYNAMICLIGHTMAP_ON
        o.ambientOrLightmapUV.zw = v.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
#endif

#ifdef _PARALLAXMAP
        TANGENT_SPACE_ROTATION;
        half3 viewDirForParallax = mul (rotation, ObjSpaceViewDir(v.vertex));
        o.tangentToWorldAndPackedData[0].w = viewDirForParallax.x;
        o.tangentToWorldAndPackedData[1].w = viewDirForParallax.y;
        o.tangentToWorldAndPackedData[2].w = viewDirForParallax.z;
#endif

    return o;
}


#endif
