Shader "Custom/TerrainShader"
{
	Properties 
	{
        _Color("Color", Color) = (1,1,1,1)
        _UVTiling("UVTiling", Range(0,1)) = 1.0
        _SliderTest("SliderTest", Range(0,1)) = 1.0

        // Blending state
        [HideInInspector] _Mode ("__mode", Float) = 0.0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [HideInInspector] _ZWrite ("__zw", Float) = 1.0
	}



	SubShader
	{
		Tags { "RenderType"="Opaque" "PerformanceChecks"="False" }
		LOD 300
		/*
		// ------------------------------------------------------------------
        //  Base forward pass (directional light, emission, lightmaps, ...)
		//  The forward base pass is necessary to render the terrain wireframe in the editor!
		//	It must be declared before the deferred otherwise the wireframe does not work for
		//  some reason. See the Standard shader for the correct order.
        Pass
        {
            Name "FORWARD"
            Tags { "LightMode" = "ForwardBase" }

            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite]

            CGPROGRAM
            #pragma target 5.0
			#pragma only_renderers d3d11

            // -------------------------------------

            #pragma shader_feature _NORMALMAP
            #pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _EMISSION
            #pragma shader_feature _METALLICGLOSSMAP
            #pragma shader_feature ___ _DETAIL_MULX2
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature _ _GLOSSYREFLECTIONS_OFF
            #pragma shader_feature _PARALLAXMAP

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

			#pragma instancing_options procedural:terrain_instancing_setup 

			/// needed for tangent input
			#define _TANGENT_TO_WORLD
			#undef _NORMALMAP

            #include "UnityStandardCoreForward.cginc"
			#include "ASTMTerrainForward.cginc"
			
            #pragma vertex TerrainVertForwardBase
            #pragma fragment fragForwardBase // the built-in
            ENDCG
        }
		*/
		// ------------------------------------------------------------------
		//  Deferred pass
		Pass
		{
			Name "DEFERRED"
			Tags { "LightMode" = "Deferred" }

			CGPROGRAM
			#pragma target 5.0
			#pragma exclude_renderers nomrt
			#pragma only_renderers d3d11

			// -------------------------------------
			#pragma shader_feature _NORMALMAP
			#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
			#pragma shader_feature _EMISSION
			#pragma shader_feature _METALLICGLOSSMAP
			#pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
			#pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
			#pragma shader_feature ___ _DETAIL_MULX2
			#pragma shader_feature _PARALLAXMAP

			#pragma multi_compile_prepassfinal

			#pragma multi_compile_instancing
			#pragma instancing_options procedural:TerrainSetupInstancing 

			/// needed for tangent input
			#define _TANGENT_TO_WORLD

			#pragma vertex TerrainVertexDeferred
			#pragma fragment TerrainFragDeferred

			#include "UnityStandardCore.cginc"

			#include "TerrainInput.cginc"
			#include "TerrainSetupInstancing.cginc"

			#include "TerrainVertexShader.cginc"
			#include "TerrainFragmentShader.cginc"
			ENDCG
		}
	}
	//FallBack "VertexLit"
	FallBack Off
	CustomEditor "ASTMTerrainVFShaderGUI"
}
