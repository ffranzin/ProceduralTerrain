// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

#ifndef UNITY_BUILTIN_SHADOW_LIBRARY_INCLUDED
#define UNITY_BUILTIN_SHADOW_LIBRARY_INCLUDED

// Shadowmap helpers.
#if defined( SHADOWS_SCREEN ) && defined( LIGHTMAP_ON )
	#define HANDLE_SHADOWS_BLENDING_IN_GI 1
#endif

#if (UNITY_VERSION >= 2017)
#define unityShadowCoord float
#define unityShadowCoord2 float2
#define unityShadowCoord3 float3
#define unityShadowCoord4 float4
#define unityShadowCoord4x4 float4x4
#endif

half    UnitySampleShadowmap_PCF7x7(float4 coord, float3 receiverPlaneDepthBias);   // Samples the shadowmap based on PCF filtering (7x7 kernel)
half    UnitySampleShadowmap_PCF5x5(float4 coord, float3 receiverPlaneDepthBias);   // Samples the shadowmap based on PCF filtering (5x5 kernel)
half    UnitySampleShadowmap_PCF3x3(float4 coord, float3 receiverPlaneDepthBias);   // Samples the shadowmap based on PCF filtering (3x3 kernel)
float3  UnityGetReceiverPlaneDepthBias(float3 shadowCoord, float biasbiasMultiply); // Receiver plane depth bias

//NGSS START --------------------------------------------------------------------------------------------------------------------------------------------------------------

// Tip: To enable a feature uncomment the #define line. To disable a feature comment the #define line.

//Samplers per frag 																//Recommended platforms settings
//#define POISSON_16 																//Mobile
//#define POISSON_25 																//Consoles VR
//#define POISSON_32 																//Desktop VR / Consoles
#define POISSON_64 																	//Desktop

#if (defined(POISSON_32) || defined(POISSON_64))									//We dont need to bail out lower than 32 samplers
#define NGSS_USE_EARLY_BAILOUT_OPTIMIZATION											//Optimize shadows performance by skipping fragments that are either 100% lit or 100% shadowed. Some macro noisy artefacts can be seen if shadows are too soft or sampling amount is below 64.
#endif

#define NGSS_USE_BIAS_FADE															//Bias Fade		
#define NGSS_BIAS_FADE 0.015

#define NGSS_USE_POISSON_SAMPLING 													//Don't turn it off, will point light shadows look ugly as fak
#define NGSS_POISSON_SAMPLING_NOISE 10.0 											//Range between 0 and 10. Example: 0 gives 100 % Banding and 10 gives 100 % Noise. If value is 0 you better disable Poisson sampling completly, saves few instructions
//#define NGSS_USE_STATIC_NOISE 													//Improves noise patterns by sampling a noise texture in world space.

#define NGSS_GLOBAL_SOFTNESS_SPOT 1.0 												//currently does nothing (to be implemented)
#define NGSS_GLOBAL_SOFTNESS_POINT 1.0 												//currently does nothing (to be implemented)

#define NGSS_PCSS_FILTER_POINT_MIN 0.05 											//Close to blocker (If 0.0 == Hard Shadows). Warning: This value cannot be higher than NGSS_PCSS_FILTER_POINT_MAX
#define NGSS_PCSS_FILTER_POINT_MAX 1.0 												//Far from blocker (If 1.0 == Soft Shadows). Warning: This value cannot be smaller than NGSS_PCSS_FILTER_POINT_MIN

uniform sampler2D unity_RandomRotation16;

//NGSS SUPPORT
#if (SHADER_TARGET < 30 || defined(SHADER_API_D3D9) || defined(SHADER_API_GLES) || defined(SHADER_API_PSP2) || defined(SHADER_API_N3DS))
    #define NO_NGSS_SUPPORT
#endif

#if defined(POISSON_64) || defined(POISSON_128)
static const float Shadow_Coef = 0.016;
static const float Samplers_Count = 64;
static const float2 PoissonDisks[64] =
{
	float2 (0.1187053, 0.7951565),
	float2 (0.1173675, 0.6087878),
	float2 (-0.09958518, 0.7248842),
	float2 (0.4259812, 0.6152718),
	float2 (0.3723574, 0.8892787),
	float2 (-0.02289676, 0.9972908),
	float2 (-0.08234791, 0.5048386),
	float2 (0.1821235, 0.9673787),
	float2 (-0.2137264, 0.9011746),
	float2 (0.3115066, 0.4205415),
	float2 (0.1216329, 0.383266),
	float2 (0.5948939, 0.7594361),
	float2 (0.7576465, 0.5336417),
	float2 (-0.521125, 0.7599803),
	float2 (-0.2923127, 0.6545699),
	float2 (0.6782473, 0.22385),
	float2 (-0.3077152, 0.4697627),
	float2 (0.4484913, 0.2619455),
	float2 (-0.5308799, 0.4998215),
	float2 (-0.7379634, 0.5304936),
	float2 (0.02613133, 0.1764302),
	float2 (-0.1461073, 0.3047384),
	float2 (-0.8451027, 0.3249073),
	float2 (-0.4507707, 0.2101997),
	float2 (-0.6137282, 0.3283674),
	float2 (-0.2385868, 0.08716244),
	float2 (0.3386548, 0.01528411),
	float2 (-0.04230833, -0.1494652),
	float2 (0.167115, -0.1098648),
	float2 (-0.525606, 0.01572019),
	float2 (-0.7966855, 0.1318727),
	float2 (0.5704287, 0.4778273),
	float2 (-0.9516637, 0.002725032),
	float2 (-0.7068223, -0.1572321),
	float2 (0.2173306, -0.3494083),
	float2 (0.06100426, -0.4492816),
	float2 (0.2333982, 0.2247189),
	float2 (0.07270987, -0.6396734),
	float2 (0.4670808, -0.2324669),
	float2 (0.3729528, -0.512625),
	float2 (0.5675077, -0.4054544),
	float2 (-0.3691984, -0.128435),
	float2 (0.8752473, 0.2256988),
	float2 (-0.2680127, -0.4684393),
	float2 (-0.1177551, -0.7205751),
	float2 (-0.1270121, -0.3105424),
	float2 (0.5595394, -0.06309237),
	float2 (-0.9299136, -0.1870008),
	float2 (0.974674, 0.03677348),
	float2 (0.7726735, -0.06944724),
	float2 (-0.4995361, -0.3663749),
	float2 (0.6474168, -0.2315787),
	float2 (0.1911449, -0.8858921),
	float2 (0.3671001, -0.7970535),
	float2 (-0.6970353, -0.4449432),
	float2 (-0.417599, -0.7189326),
	float2 (-0.5584748, -0.6026504),
	float2 (-0.02624448, -0.9141423),
	float2 (0.565636, -0.6585149),
	float2 (-0.874976, -0.3997879),
	float2 (0.9177843, -0.2110524),
	float2 (0.8156927, -0.3969557),
	float2 (-0.2833054, -0.8395444),
	float2 (0.799141, -0.5886372)
};

#elif defined(POISSON_32)
static const float Shadow_Coef = 0.031;
static const float Samplers_Count = 32;
static const float2 PoissonDisks[32] =
{
	float2 (0.4873902, -0.8569599),
	float2 (0.3463737, -0.3387939),
	float2 (0.6290055, -0.4735314),
	float2 (0.1855854, -0.8848142),
	float2 (0.7677917, 0.02691162),
	float2 (0.3009142, -0.6365873),
	float2 (0.4268422, -0.006137629),
	float2 (-0.06682982, -0.7833805),
	float2 (0.0347263, -0.3994124),
	float2 (0.4494694, 0.5206614),
	float2 (0.219377, 0.2438844),
	float2 (0.1285765, -0.1215554),
	float2 (0.8907049, 0.4334931),
	float2 (0.2556469, 0.766552),
	float2 (-0.03692406, 0.3629236),
	float2 (0.6651103, 0.7286811),
	float2 (-0.429309, -0.2282262),
	float2 (-0.2730969, -0.4683513),
	float2 (-0.2755986, 0.7327913),
	float2 (-0.3329705, 0.1754638),
	float2 (-0.1731326, -0.1087716),
	float2 (0.9212226, -0.3716638),
	float2 (-0.5388235, 0.4603968),
	float2 (-0.6307321, 0.7615924),
	float2 (-0.7709175, -0.08894937),
	float2 (-0.7205971, -0.3609493),
	float2 (-0.5386202, -0.5847159),
	float2 (-0.6520834, 0.1785284),
	float2 (-0.9310582, 0.2040343),
	float2 (-0.828178, 0.5559599),
	float2 (0.6297836, 0.2946501),
	float2 (-0.05836084, 0.9006807)
};

#elif defined(POISSON_25)
static const float Shadow_Coef = 0.04;
static const float Samplers_Count = 25;
static const float2 PoissonDisks[25] =
{
	float2 (-0.6351818f, 0.2172711f),
	float2 (-0.1499606f, 0.2320675f),
	float2 (-0.67978f, 0.6884924f),
	float2 (-0.7758647f, -0.253409f),
	float2 (-0.4731916f, -0.2832723f),
	float2 (-0.3330079f, 0.6430059f),
	float2 (-0.1384151f, -0.09830225f),
	float2 (-0.8182327f, -0.5645939f),
	float2 (-0.9198472f, 0.06549802f),
	float2 (-0.1422085f, -0.4872109f),
	float2 (-0.4980833f, -0.5885599f),
	float2 (-0.3326159f, -0.8496148f),
	float2 (0.3066736f, -0.1401997f),
	float2 (0.1148317f, 0.374455f),
	float2 (-0.0388568f, 0.8071329f),
	float2 (0.4102885f, 0.6960295f),
	float2 (0.5563877f, 0.3375377f),
	float2 (-0.01786576f, -0.8873765f),
	float2 (0.234991f, -0.4558438f),
	float2 (0.6206775f, -0.1551005f),
	float2 (0.6640642f, -0.5691427f),
	float2 (0.7312726f, 0.5830168f),
	float2 (0.8879707f, 0.05715213f),
	float2 (0.3128296f, -0.830803f),
	float2 (0.8689764f, -0.3397973f)
};

#else
static const float Samplers_Count = 16;
static const float Shadow_Coef = 0.063;
static const float2 PoissonDisks[16] =
{
	float2(0.1232981, -0.03923375),
	float2(-0.5625377, -0.3602428),
	float2(0.6403719, 0.06821123),
	float2(0.2813387, -0.5881588),
	float2(-0.5731218, 0.2700572),
	float2(0.2033166, 0.4197739),
	float2(0.8467958, -0.3545584),
	float2(-0.4230451, -0.797441),
	float2(0.7190253, 0.5693575),
	float2(0.03815468, -0.9914171),
	float2(-0.2236265, 0.5028614),
	float2(0.1722254, 0.983663),
	float2(-0.2912464, 0.8980512),
	float2(-0.8984148, -0.08762786),
	float2(-0.6995085, 0.6734185),
	float2(-0.293196, -0.06289119)
};

#endif

static const float2 PoissonDisksTest[16] =
{
	float2(0.1232981, -0.03923375),
	float2(-0.5625377, -0.3602428),
	float2(0.6403719, 0.06821123),
	float2(0.2813387, -0.5881588),
	float2(-0.5731218, 0.2700572),
	float2(0.2033166, 0.4197739),
	float2(0.8467958, -0.3545584),
	float2(-0.4230451, -0.797441),
	float2(0.7190253, 0.5693575),
	float2(0.03815468, -0.9914171),
	float2(-0.2236265, 0.5028614),
	float2(0.1722254, 0.983663),
	float2(-0.2912464, 0.8980512),
	float2(-0.8984148, -0.08762786),
	float2(-0.6995085, 0.6734185),
	float2(-0.293196, -0.06289119)
};

//Will help store temporary rotations
float3 LocalPoissonDisksOffsets[64];

// Returns a random number based on a float3 and an index.
float LocalRandInd(float3 seed, int i)
{
	float4 seed4 = float4(seed, i);
	float dt = dot(seed4, float4(12.9898, 78.233, 45.164, 94.673));
	return frac(sin(dt) * 43758.5453);
}

float LocalRand01(float3 seed)
{
	float dt = dot(seed, float3(12.9898, 78.233, 45.5432));// project seed on random constant vector   
	return frac(sin(dt) * 43758.5453);// return only fractional part
}

int LocalRandInt(float3 seed, int maxInt)
{
	return int((float(maxInt) * LocalRand01(seed), maxInt) % 16);//fmod() function equivalent as % operator
}

float LocalRandAngle(float3 seed)
{
	return LocalRand01(seed) * NGSS_POISSON_SAMPLING_NOISE;
}

float LocalRandAngle2(float2 seed)
{
	float dt = dot(seed, float2(12.9898, 78.233));// project seed on random constant vector   
	float frc = frac(sin(dt) * 43758.5453);// get only fractional part
	return frc * NGSS_POISSON_SAMPLING_NOISE;
}

float3 LocalRandDir(float3 seed)
{
	return (frac(sin(cross(seed, float3 (12.9898, 78.233, 45.5432))) * 43758.5453)*NGSS_POISSON_SAMPLING_NOISE + 0.0001);
}

// ------------------------------------------------------------------
// Spot light shadows
// ------------------------------------------------------------------

#if defined (SHADOWS_DEPTH) && defined (SPOT)

	//INLINE SAMPLING
	#if (SHADER_TARGET < 30  || UNITY_VERSION <= 570 || defined(SHADER_API_D3D9) || defined(SHADER_API_GLES) || defined(SHADER_API_PSP2) || defined(SHADER_API_N3DS) || defined(SHADER_API_GLCORE))
		//#define NO_INLINE_SAMPLERS_SUPPORT
	#else
		#define NGSS_CAN_USE_PCSS_FILTER
		SamplerState my_point_clamp_smp;
	#endif

	// declare shadowmap
    #if !defined(SHADOWMAPSAMPLER_DEFINED)
        UNITY_DECLARE_SHADOWMAP(_ShadowMapTexture);
        #define SHADOWMAPSAMPLER_DEFINED
    #endif

    // shadow sampling offsets and texel size
    #if defined (SHADOWS_SOFT)
        float4 _ShadowOffsets[4];
        float4 _ShadowMapTexture_TexelSize;
        #define SHADOWMAPSAMPLER_AND_TEXELSIZE_DEFINED
    #endif
	
	#if defined (NGSS_CAN_USE_PCSS_FILTER)
	float2 BLOCKER_SEARCH_SPOT(float4 coord, float diskRadius, float c, float s)
	{
		//BLOCKER SEARCH	
		float blockerCount = 0;
		float avgBlockerDistance = 0.0;
				
		for (int i = 0; i < 16; ++i)
		{
	#if defined(NGSS_USE_POISSON_SAMPLING)
			float2 rotatedOffset = float2(PoissonDisksTest[i].x * c + PoissonDisksTest[i].y * s, PoissonDisksTest[i].x * -s + PoissonDisksTest[i].y * c) * diskRadius;
	#else
			float2 rotatedOffset = PoissonDisksTest[i] * diskRadius;
	#endif
			
	#if defined (SHADOWS_NATIVE)
			//Can speeded up with Gather and GatherRed (they can sample 4 surrounding pixels at the same time at once)
			half closestDepth = _ShadowMapTexture.SampleLevel(my_point_clamp_smp, coord.xy + rotatedOffset, 0.0);
						
	#else
			half closestDepth = SAMPLE_DEPTH_TEXTURE(_ShadowMapTexture, coord.xy + rotatedOffset).r;
	#endif
			
			//blockerCount++;
			//avgBlockerDistance += closestDepth;
			
	#if defined(NGSS_USE_EARLY_BAILOUT_OPTIMIZATION)
				#if defined(UNITY_REVERSED_Z)
				if (closestDepth > coord.z)
				#else
				if (closestDepth < coord.z)
				#endif
				{
	#endif
					blockerCount++;
					avgBlockerDistance += closestDepth;
	#if defined(NGSS_USE_EARLY_BAILOUT_OPTIMIZATION)
				}
	#endif
		
		}

		return float2(avgBlockerDistance / blockerCount, blockerCount);
	}
	#endif//NGSS_CAN_USE_PCSS_FILTER
	
	float PCF_FILTER_SPOT_TEST(float4 coord, float diskRadius, float c, float s)
	{
		float result = 0.0;

		for (int i = 0; i < 16; ++i)
		{
		
	#if defined(NGSS_USE_POISSON_SAMPLING)
			float2 rotatedOffset = float2(PoissonDisksTest[i].x * c + PoissonDisksTest[i].y * s, PoissonDisksTest[i].x * -s + PoissonDisksTest[i].y * c) * diskRadius;
	#else
			float2 rotatedOffset = PoissonDisksTest[i] * diskRadius;
	#endif

	#if defined (SHADOWS_NATIVE)
			result += UNITY_SAMPLE_SHADOW(_ShadowMapTexture, float4(coord.xy + rotatedOffset, coord.zw)).r;	
	#else
			result += SAMPLE_DEPTH_TEXTURE(_ShadowMapTexture, coord.xy + rotatedOffset).r > coord.z ? 1.0 : 0.0;
	#endif
		}
		half shadow = result / 16;

		return shadow;
	}

	float PCF_FILTER_SPOT(float4 coord, float diskRadius, float c, float s)
	{
		float result = 0.0;

		for (int i = 0; i < Samplers_Count; ++i)
		{
		
	#if defined(NGSS_USE_POISSON_SAMPLING)
			float2 rotatedOffset = float2(PoissonDisks[i].x * c + PoissonDisks[i].y * s, PoissonDisks[i].x * -s + PoissonDisks[i].y * c) * diskRadius;
	#else
			float2 rotatedOffset = PoissonDisks[i] * diskRadius;
	#endif

	#if defined (SHADOWS_NATIVE)
			result += UNITY_SAMPLE_SHADOW(_ShadowMapTexture, float4(coord.xy + rotatedOffset, coord.zw)).r;	
	#else			
		#if defined(NGSS_USE_BIAS_FADE)
			float shadowsFade = NGSS_BIAS_FADE * _LightPositionRange.w;
			result += 1 - saturate((coord.z - SAMPLE_DEPTH_TEXTURE(_ShadowMapTexture, coord.xy + rotatedOffset).r) / shadowsFade);
		#else
			result += SAMPLE_DEPTH_TEXTURE(_ShadowMapTexture, coord.xy + rotatedOffset).r > coord.z ? 1.0 : 0.0;
		#endif
	#endif
		}
		half shadow = result / Samplers_Count;

		return shadow;
	}

	inline fixed UnitySampleShadowmap(float4 shadowCoord)//, float4 screenPos)
	{
		// DX11 feature level 9.x shader compiler (d3dcompiler_47 at least)
		// has a bug where trying to do more than one shadowmap sample fails compilation
		// with "inconsistent sampler usage". Until that is fixed, just never compile
		// multi-tap shadow variant on d3d11_9x.
		
		#if defined(NO_NGSS_SUPPORT)
		return 1.0;
		#endif

		//if(shadowCoord.w < 0.0)
		//return 1.0;

		float4 coord = shadowCoord;
		coord.xyz /= coord.w;
		float s = 1.0;
		float c = 1.0;

	//#define NGSS_USE_STATIC_NOISE
	#if defined(NGSS_USE_POISSON_SAMPLING)
	#if defined(NGSS_USE_STATIC_NOISE)
		float4 rotation = tex2D(unity_RandomRotation16, (coord.xy * 1000));
		s = sin(rotation.x);
		c = cos(rotation.y);
	#else
		float4 rotation = tex2D(unity_RandomRotation16, (coord.xy * 10));
		float angle = LocalRandAngle(rotation.xyz);//screenPos.xyy
		s = sin(angle);
		c = cos(angle);
	#endif
	#endif

		//float diskRadius = 0.5 / (1-_LightShadowData.r) / (shadowCoord.z / (_LightShadowData.z + _LightShadowData.w));
		float diskRadius = (1.0 - _LightShadowData.r);
	
	#if defined(SHADOWS_SOFT) && defined (NGSS_CAN_USE_PCSS_FILTER) && !defined (SHADER_API_D3D11_9X)
		
		diskRadius *= 0.05;
		
		float2 distances = BLOCKER_SEARCH_SPOT(coord, diskRadius, c, s);
		 
		#if defined(NGSS_USE_EARLY_BAILOUT_OPTIMIZATION)
		if( distances.y == 0.0 )//There are no occluders so early out (this saves filtering)
			return 1.0;
		else if (distances.y == 16.0)//There are 100% occluders so early out (this saves filtering)
			return 0.0;
		#endif
		 	
		//clamping the kernel size to avoid hard shadows at close ranges
		//diskRadius *= clamp(distances.x, NGSS_PCSS_FILTER_POINT_MIN, NGSS_PCSS_FILTER_POINT_MAX);
		
		diskRadius *= ((coord.z - distances.x)/(distances.x));

		half shadow = PCF_FILTER_SPOT(coord, diskRadius, c, s);
	#else
		diskRadius *= 0.025;
				
		#if defined(NGSS_USE_EARLY_BAILOUT_OPTIMIZATION)
		half shadowTest = PCF_FILTER_SPOT_TEST(coord, diskRadius, c, s);
		if (shadowTest == 0.0)//If all pixels are shadowed early bail out
			return 0.0;
		else if (shadowTest == 1.0)//If all pixels are lit early bail out
			return 1.0;
		#endif
		half shadow = PCF_FILTER_SPOT(coord, diskRadius, c, s);
	#endif

		return shadow;
	}

#endif // #if defined (SHADOWS_DEPTH) && defined (SPOT)

// ------------------------------------------------------------------
// Point light shadows
// ------------------------------------------------------------------

#if defined (SHADOWS_CUBE)
	
	//INLINE SAMPLING
	#if (SHADER_TARGET < 30  || UNITY_VERSION <= 570 || defined(SHADER_API_D3D9) || defined(SHADER_API_GLES) || defined(SHADER_API_PSP2) || defined(SHADER_API_N3DS) || defined(SHADER_API_GLCORE))
		//#define NO_INLINE_SAMPLERS_SUPPORT
	#else
		#define NGSS_CAN_USE_PCSS_FILTER
		SamplerState my_point_clamp_smp;
	#endif
	
	#if defined(SHADOWS_CUBE_IN_DEPTH_TEX)
	UNITY_DECLARE_TEXCUBE_SHADOWMAP(_ShadowMapTexture);
	inline half computeShadowDist(float3 vec)
    {
		//_LightPositionRange; // xyz = pos, w = 1/range
		//_LightProjectionParams; // for point light projection: x = zfar / (znear - zfar), y = (znear * zfar) / (znear - zfar), z=shadow bias, w=shadow scale bias
		
        float3 absVec = abs(vec);
		
		//modd
        float3 biasVec = normalize(absVec);
        absVec -= biasVec * _LightProjectionParams.z;
        absVec = max(float3(0.0, 0.0, 0.0), absVec);

        float dominantAxis = max(max(absVec.x, absVec.y), absVec.z); // TODO use max3() instead
        dominantAxis = max(0.0, dominantAxis - max(0.005, _LightProjectionParams.z));// shadow bias from point light is apllied here. 
        //dominantAxis *= _LightProjectionParams.w; // extra bias no needed now
        float mydist = -_LightProjectionParams.x + _LightProjectionParams.y / dominantAxis; // project to shadow map clip space [0; 1]

        #if defined(UNITY_REVERSED_Z)
        mydist = 1.0 - mydist; // depth buffers are reversed! Additionally we can move this to CPP code!
        #endif

        return mydist;        
    }
	#else//NO SHADOWS_CUBE_IN_DEPTH_TEX
	UNITY_DECLARE_TEXCUBE(_ShadowMapTexture);
	inline float SampleCubeDistance(float3 vec)
	{
		// DX9 with SM2.0, and DX11 FL 9.x do not have texture LOD sampling.
	#if ((SHADER_TARGET < 25) && defined(SHADER_API_D3D9)) || defined(SHADER_API_D3D11_9X)
		return UnityDecodeCubeShadowDepth(texCUBE(_ShadowMapTexture, vec));
	#else
		return UnityDecodeCubeShadowDepth(UNITY_SAMPLE_TEXCUBE_LOD(_ShadowMapTexture, vec, 0));
	#endif
	}

	#endif

	float3x3 arbitraryAxisRotation(float3 axis, float angle)
	{
		axis = normalize(axis);
		float s = sin(angle);
		float c = cos(angle);
		float oc = 1.0 - c;

		return float3x3(oc * axis.x * axis.x + c, oc * axis.x * axis.y - axis.z * s, oc * axis.z * axis.x + axis.y * s,
			oc * axis.x * axis.y + axis.z * s, oc * axis.y * axis.y + c, oc * axis.y * axis.z - axis.x * s,
			oc * axis.z * axis.x - axis.y * s, oc * axis.y * axis.z + axis.x * s, oc * axis.z * axis.z + c);
	}

	inline half UnitySampleShadowmap(float3 vec)//, float4 screenPos) //screenPos the same pos as when fetching screen space shadow mask
	{
		
	#if defined(NO_NGSS_SUPPORT)
		return 1.0;
	#endif

	#if defined(SHADOWS_CUBE_IN_DEPTH_TEX)
		//_LightPositionRange; // xyz = pos, w = 1/range
		//_LightProjectionParams; // for point light projection: x = zfar / (znear - zfar), y = (znear * zfar) / (znear - zfar), z=shadow bias, w=shadow scale bias
		float mydist = computeShadowDist(vec);		
	#else
		//To get world pos back, simply add _LightPositionRange.xyz to vec
		//receiver distance in 0-1 range
		float mydist = length(vec) * _LightPositionRange.w;
		//If older than Unity 2017.3
		//#if (UNITY_VERSION <= 570 || UNITY_VERSION == 20171 || UNITY_VERSION == 201711 || UNITY_VERSION == 201712 || UNITY_VERSION == 201713 || UNITY_VERSION == 20172 || UNITY_VERSION == 201721 || UNITY_VERSION == 201722)
		#if (UNITY_VERSION <= 570 || UNITY_VERSION < 201730)
		//mydist *= _LightProjectionParams.w; // bias
		#else
		//mydist *= _LightProjectionParams.w; // bias
		#endif
	#endif//SHADOWS_CUBE_IN_DEPTH_TEX

	#if defined(NGSS_USE_POISSON_SAMPLING)
		float3 wpos = vec + _LightPositionRange.xyz;
		float4 cpos = UnityWorldToClipPos(wpos);
		float4 spos = ComputeScreenPos(cpos);

		//cpos.xyz /= cpos.w;	
		//if( abs(cpos.x) > 1.0 || abs(cpos.y) > 1.0)//if outside screen clip it
		//return 1.0;

		spos.xyz /= spos.w;
		float4 rotation = tex2D(unity_RandomRotation16, spos.xy);// wpos.xy / wpos.z gives static patterns at close range (needs to be scaled with screen depth);
		//float4 rotation = tex2D(NGSS_NOISE_TEXTURE, spos.xy * _ScreenParams.zw);
		//float fragDist = 1.0 - (length(wpos - _WorldSpaceCameraPos.xyz) * _LightPositionRange.w);
		
		float3 randDir = LocalRandDir(rotation.xyz);
	#else
		float3 randDir = frac(vec.xyz);
	#endif
		
		// Tangent plane
		float3 xaxis = normalize(cross(vec, randDir));
		float3 yaxis = normalize(cross(vec, xaxis));
		
		float shadow = 0.0;
		
		float diskRadius = (1 - _LightShadowData.r);
		
	#if defined(SHADOWS_SOFT) && !defined(SHADER_API_GLCORE)// && defined (NGSS_CAN_USE_PCSS_FILTER)

		//Multi-tap Shadows (PCSS)

		//float angle = LocalRandAngle(vec);//gives more stable patterns than previous method
		//float3x3 rotMat = arbitraryAxisRotation(vec, angle);//rotation around arbitrary axis

		//float dist = SampleCubeDistance (vec);
		//float angle = dot(frac(vec),fixed3(360.0, 360.0, 360.0)) * 500000.0;		
		//float3x3 rotMat = float3x3(c, -s, 0,    s, c, 0,    0, 0, 1);//rotation around Z axis
		//float s = sin(angle);
		//float c = cos(angle);
		
		#if defined(NGSS_USE_EARLY_BAILOUT_OPTIMIZATION)
			diskRadius *= 0.25;
		#else
			diskRadius *= 0.5;
		#endif
		
		xaxis *= diskRadius;
		yaxis *= diskRadius;
		
		//BLOCKER SEARCH	
		float blockerCount = 0;
		float avgBlockerDistance = 0.0;
		
		for (int i = 0; i < 16; ++i)
		{
			float3 sampleDir = xaxis * PoissonDisksTest[i].x + yaxis * PoissonDisksTest[i].y;
			float3 vecOffset = vec + sampleDir;
			
		#if defined(SHADOWS_CUBE_IN_DEPTH_TEX) 
			
            half myOffsetDist = computeShadowDist(vecOffset);
			//Can speeded up with Gather and GatherRed (they can sample 4 surrounding pixels at the same time at once)
			half closestDepth = _ShadowMapTexture.SampleLevel(my_point_clamp_smp, vecOffset, 0.0);
			
			#if defined(UNITY_REVERSED_Z)
			//closestDepth = 1.0 - closestDepth;
			#endif
			
			//blockerCount++;
			//avgBlockerDistance += closestDepth;
			
			#if defined(NGSS_USE_EARLY_BAILOUT_OPTIMIZATION)
			#if defined(UNITY_REVERSED_Z)
				if (closestDepth >= myOffsetDist)//mydist)
			#else
				if (closestDepth <= myOffsetDist)//mydist)
			#endif
				{
			#endif
					blockerCount++;
					avgBlockerDistance += closestDepth;
			#if defined(NGSS_USE_EARLY_BAILOUT_OPTIMIZATION)
				}
			#endif
			
		#else// NO SHADOWS_CUBE_IN_DEPTH_TEX		
			half closestDepth = SampleCubeDistance(vecOffset).r;	

			#if defined(NGSS_USE_EARLY_BAILOUT_OPTIMIZATION)
				if (closestDepth < mydist)
				{
			#endif//NGSS_USE_EARLY_BAILOUT_OPTIMIZATION
					blockerCount++;
					avgBlockerDistance += closestDepth;
			#if defined(NGSS_USE_EARLY_BAILOUT_OPTIMIZATION)
				}
			#endif
		#endif//SHADOWS_CUBE_IN_DEPTH_TEX
		
		}
		
		#if defined(NGSS_USE_EARLY_BAILOUT_OPTIMIZATION)
		if( blockerCount == 0.0 )//There are no occluders so early out (this saves filtering)
			return 1.0;
		else if (blockerCount == 16.0)//There are 100% occluders so early out (this saves filtering)
			return 0.0;
		#endif
		
		float dist = avgBlockerDistance / blockerCount;
		
		//dist = 1.0 - dist;
		//dist = _LightProjectionParams.y / (dist + _LightProjectionParams.x);//Convert from light to world space
		//clamping the kernel size to avoid hard shadows at close ranges
		//diskRadius *= clamp(dist, NGSS_PCSS_FILTER_POINT_MIN, NGSS_PCSS_FILTER_POINT_MAX);
		//#if (UNITY_VERSION <= 570 || UNITY_VERSION == 20171 || UNITY_VERSION == 201711 || UNITY_VERSION == 201712 || UNITY_VERSION == 201713 || UNITY_VERSION == 20172 || UNITY_VERSION == 201721 || UNITY_VERSION == 201722)
		#if (UNITY_VERSION <= 570 || UNITY_VERSION < 201730)
		half diskRadiusPCF = ((mydist - dist)/(mydist));
		#else
		half diskRadiusPCF = ((mydist - dist)/(dist));
		#endif
				
		//PCF FILTERING
		for (int j = 0; j < Samplers_Count; ++j)
		{
			float3 sampleDir = xaxis * PoissonDisks[j].x + yaxis * PoissonDisks[j].y;
			
		#if defined(SHADOWS_CUBE_IN_DEPTH_TEX)
			
			float3 vecOffset = vec + sampleDir * diskRadiusPCF;
            half myOffsetDist = computeShadowDist(vecOffset);

			shadow += UNITY_SAMPLE_TEXCUBE_SHADOW(_ShadowMapTexture, float4(vecOffset, myOffsetDist));
			//shadow += UNITY_SAMPLE_TEXCUBE_SHADOW(_ShadowMapTexture, float4(vecOffset, mydist);
			
		#else
			
			float closestDepth = SampleCubeDistance(vec + sampleDir * diskRadiusPCF).r;

			#if defined(NGSS_USE_BIAS_FADE)
			float shadowsFade = NGSS_BIAS_FADE * _LightPositionRange.w;
			shadow += 1 - saturate((mydist - closestDepth) / shadowsFade);
			#else
			shadow += (mydist - closestDepth < 0.0) ? 1.0 : 0.0;
			#endif
			
		#endif//SHADOWS_CUBE_IN_DEPTH_TEX
		}
		
		return shadow / Samplers_Count;

	#else //PCF

		//Multi-tap Shadows (PCF)
		diskRadius *= 0.1;
		
		xaxis *= diskRadius;
		yaxis *= diskRadius;
		
		//EARLY BAILING OUT
		#if defined(NGSS_USE_EARLY_BAILOUT_OPTIMIZATION)		
		float shadowTest = 0.0;
		
		for (int i = 0; i < 16; ++i)
		{
			float3 sampleDir = xaxis * PoissonDisksTest[i].x + yaxis * PoissonDisksTest[i].y;
			
		#if defined(SHADOWS_CUBE_IN_DEPTH_TEX)
			float3 vecOffset = vec + sampleDir;
            half myOffsetDist = computeShadowDist(vecOffset);
    		shadowTest += UNITY_SAMPLE_TEXCUBE_SHADOW(_ShadowMapTexture, float4(vecOffset, myOffsetDist));
			//shadowTest += UNITY_SAMPLE_TEXCUBE_SHADOW(_ShadowMapTexture, float4(vecOffset, mydist));
		#else
			
			float closestDepth = SampleCubeDistance(vec + sampleDir).r;

			shadowTest += (mydist - closestDepth < 0.0) ? 1.0 : 0.0;
			
		#endif//SHADOWS_CUBE_IN_DEPTH_TEX
		
		}
		
		if (shadowTest == 0.0)//If all pixels are shadowed early bail out
			return 0.0;
		else if (shadowTest == 16.0)//If all pixels are lit early bail out
			return 1.0;
			
		#endif//NGSS_USE_EARLY_BAILOUT_OPTIMIZATION
				
		//PCF FILTERING
		for (int j = 0; j < Samplers_Count; ++j)
		{
			float3 sampleDir = xaxis * PoissonDisks[j].x + yaxis * PoissonDisks[j].y;
			
		#if defined(SHADOWS_CUBE_IN_DEPTH_TEX)
			float3 vecOffset = vec + sampleDir;
            half myOffsetDist = computeShadowDist(vecOffset);

			shadow += UNITY_SAMPLE_TEXCUBE_SHADOW(_ShadowMapTexture, float4(vecOffset, myOffsetDist));
			//shadow += UNITY_SAMPLE_TEXCUBE_SHADOW(_ShadowMapTexture, float4(vecOffset, mydist));
			
		#else
			
			float closestDepth = SampleCubeDistance(vec + sampleDir).r;

			#if defined(NGSS_USE_BIAS_FADE)
			float shadowsFade = NGSS_BIAS_FADE * _LightPositionRange.w;
			shadow += 1 - saturate((mydist - closestDepth) / shadowsFade);
			#else
			shadow += (mydist - closestDepth < 0.0) ? 1.0 : 0.0;
			#endif
			
		#endif//SHADOWS_CUBE_IN_DEPTH_TEX
		}
		
		return shadow / Samplers_Count;
		
	#endif
	}

#endif // #if defined (SHADOWS_CUBE)


// ------------------------------------------------------------------
// Baked shadows
// ------------------------------------------------------------------

#if UNITY_LIGHT_PROBE_PROXY_VOLUME

half4 LPPV_SampleProbeOcclusion(float3 worldPos)
{
    const float transformToLocal = unity_ProbeVolumeParams.y;
    const float texelSizeX = unity_ProbeVolumeParams.z;

    //The SH coefficients textures and probe occlusion are packed into 1 atlas.
    //-------------------------
    //| ShR | ShG | ShB | Occ |
    //-------------------------

    float3 position = (transformToLocal == 1.0f) ? mul(unity_ProbeVolumeWorldToObject, float4(worldPos, 1.0)).xyz : worldPos;

    //Get a tex coord between 0 and 1
    float3 texCoord = (position - unity_ProbeVolumeMin.xyz) * unity_ProbeVolumeSizeInv.xyz;

    // Sample fourth texture in the atlas
    // We need to compute proper U coordinate to sample.
    // Clamp the coordinate otherwize we'll have leaking between ShB coefficients and Probe Occlusion(Occ) info
    texCoord.x = max(texCoord.x * 0.25f + 0.75f, 0.75f + 0.5f * texelSizeX);

    return UNITY_SAMPLE_TEX3D_SAMPLER(unity_ProbeVolumeSH, unity_ProbeVolumeSH, texCoord);
}

#endif //#if UNITY_LIGHT_PROBE_PROXY_VOLUME

// ------------------------------------------------------------------
// Used by the forward rendering path
fixed UnitySampleBakedOcclusion (float2 lightmapUV, float3 worldPos)
{
    #if defined (SHADOWS_SHADOWMASK)
        #if defined(LIGHTMAP_ON)
			//fixed4 rawOcclusionMask = UNITY_SAMPLE_TEX2D(unity_ShadowMask, lightmapUV.xy);//UNITY 2018
			fixed4 rawOcclusionMask = UNITY_SAMPLE_TEX2D_SAMPLER(unity_ShadowMask, unity_Lightmap, lightmapUV.xy);//Unity 2017 and below
        #else
            fixed4 rawOcclusionMask = fixed4(1.0, 1.0, 1.0, 1.0);
            #if UNITY_LIGHT_PROBE_PROXY_VOLUME
                if (unity_ProbeVolumeParams.x == 1.0)
                    rawOcclusionMask = LPPV_SampleProbeOcclusion(worldPos);
                else
                    rawOcclusionMask = UNITY_SAMPLE_TEX2D(unity_ShadowMask, lightmapUV.xy);
            #else
                rawOcclusionMask = UNITY_SAMPLE_TEX2D(unity_ShadowMask, lightmapUV.xy);
            #endif
        #endif
        return saturate(dot(rawOcclusionMask, unity_OcclusionMaskSelector));

    #else

        //In forward dynamic objects can only get baked occlusion from LPPV, light probe occlusion is done on the CPU by attenuating the light color.
        fixed atten = 1.0f;
        #if defined(UNITY_INSTANCING_ENABLED) && defined(UNITY_USE_SHCOEFFS_ARRAYS)
            // ...unless we are doing instancing, and the attenuation is packed into SHC array's .w component.
            atten = unity_SHC.w;
        #endif

        #if UNITY_LIGHT_PROBE_PROXY_VOLUME && !defined(LIGHTMAP_ON) && !UNITY_STANDARD_SIMPLE
            fixed4 rawOcclusionMask = atten.xxxx;
            if (unity_ProbeVolumeParams.x == 1.0)
                rawOcclusionMask = LPPV_SampleProbeOcclusion(worldPos);
            return saturate(dot(rawOcclusionMask, unity_OcclusionMaskSelector));
        #endif

        return atten;
    #endif
}

// ------------------------------------------------------------------
// Used by the deferred rendering path (in the gbuffer pass)
fixed4 UnityGetRawBakedOcclusions(float2 lightmapUV, float3 worldPos)
{
    #if defined (SHADOWS_SHADOWMASK)
        #if defined(LIGHTMAP_ON)
            //return UNITY_SAMPLE_TEX2D(unity_ShadowMask, lightmapUV.xy);//Unity 2018
			return UNITY_SAMPLE_TEX2D_SAMPLER(unity_ShadowMask, unity_Lightmap, lightmapUV.xy);//Unity 2017 and below
        #else
            half4 probeOcclusion = unity_ProbesOcclusion;

            #if UNITY_LIGHT_PROBE_PROXY_VOLUME
                if (unity_ProbeVolumeParams.x == 1.0)
                    probeOcclusion = LPPV_SampleProbeOcclusion(worldPos);
            #endif

            return probeOcclusion;
        #endif
    #else
        return fixed4(1.0, 1.0, 1.0, 1.0);
    #endif
}

// ------------------------------------------------------------------
// Used by both the forward and the deferred rendering path
half UnityMixRealtimeAndBakedShadows(half realtimeShadowAttenuation, half bakedShadowAttenuation, half fade)
{
    // -- Static objects --
    // FWD BASE PASS
    // ShadowMask mode          = LIGHTMAP_ON + SHADOWS_SHADOWMASK + LIGHTMAP_SHADOW_MIXING
    // Distance shadowmask mode = LIGHTMAP_ON + SHADOWS_SHADOWMASK
    // Subtractive mode         = LIGHTMAP_ON + LIGHTMAP_SHADOW_MIXING
    // Pure realtime direct lit = LIGHTMAP_ON

    // FWD ADD PASS
    // ShadowMask mode          = SHADOWS_SHADOWMASK + LIGHTMAP_SHADOW_MIXING
    // Distance shadowmask mode = SHADOWS_SHADOWMASK
    // Pure realtime direct lit = LIGHTMAP_ON

    // DEFERRED LIGHTING PASS
    // ShadowMask mode          = LIGHTMAP_ON + SHADOWS_SHADOWMASK + LIGHTMAP_SHADOW_MIXING
    // Distance shadowmask mode = LIGHTMAP_ON + SHADOWS_SHADOWMASK
    // Pure realtime direct lit = LIGHTMAP_ON

    // -- Dynamic objects --
    // FWD BASE PASS + FWD ADD ASS
    // ShadowMask mode          = LIGHTMAP_SHADOW_MIXING
    // Distance shadowmask mode = N/A
    // Subtractive mode         = LIGHTMAP_SHADOW_MIXING (only matter for LPPV. Light probes occlusion being done on CPU)
    // Pure realtime direct lit = N/A

    // DEFERRED LIGHTING PASS
    // ShadowMask mode          = SHADOWS_SHADOWMASK + LIGHTMAP_SHADOW_MIXING
    // Distance shadowmask mode = SHADOWS_SHADOWMASK
    // Pure realtime direct lit = N/A

    #if !defined(SHADOWS_DEPTH) && !defined(SHADOWS_SCREEN) && !defined(SHADOWS_CUBE)
        #if defined(LIGHTMAP_ON) && defined (LIGHTMAP_SHADOW_MIXING) && !defined (SHADOWS_SHADOWMASK)
            //In subtractive mode when there is no shadow we kill the light contribution as direct as been baked in the lightmap.
            return 0.0;
        #else
            return bakedShadowAttenuation;
        #endif
    #endif

    #if (SHADER_TARGET <= 20) || UNITY_STANDARD_SIMPLE
        //no fading nor blending on SM 2.0 because of instruction count limit.
        #if defined(SHADOWS_SHADOWMASK) || defined(LIGHTMAP_SHADOW_MIXING)
            return min(realtimeShadowAttenuation, bakedShadowAttenuation);
        #else
            return realtimeShadowAttenuation;
        #endif
    #endif

    #if defined(LIGHTMAP_SHADOW_MIXING)
        //Subtractive or shadowmask mode
        realtimeShadowAttenuation = saturate(realtimeShadowAttenuation + fade);
        return min(realtimeShadowAttenuation, bakedShadowAttenuation);
    #endif

    //In distance shadowmask or realtime shadow fadeout we lerp toward the baked shadows (bakedShadowAttenuation will be 1 if no baked shadows)
    return lerp(realtimeShadowAttenuation, bakedShadowAttenuation, fade);
}

// ------------------------------------------------------------------
// Shadow fade
// ------------------------------------------------------------------

float UnityComputeShadowFadeDistance(float3 wpos, float z)
{
    float sphereDist = distance(wpos, unity_ShadowFadeCenterAndType.xyz);
    return lerp(z, sphereDist, unity_ShadowFadeCenterAndType.w);
}

// ------------------------------------------------------------------
half UnityComputeShadowFade(float fadeDist)
{
    return saturate(fadeDist * _LightShadowData.z + _LightShadowData.w);
}


// ------------------------------------------------------------------
//  Bias
// ------------------------------------------------------------------

/**
* Computes the receiver plane depth bias for the given shadow coord in screen space.
* Inspirations:
*   http://mynameismjp.wordpress.com/2013/09/10/shadow-maps/
*   http://amd-dev.wpengine.netdna-cdn.com/wordpress/media/2012/10/Isidoro-ShadowMapping.pdf
*/
float3 UnityGetReceiverPlaneDepthBias(float3 shadowCoord, float biasMultiply)
{
    // Should receiver plane bias be used? This estimates receiver slope using derivatives,
    // and tries to tilt the PCF kernel along it. However, when doing it in screenspace from the depth texture
    // (ie all light in deferred and directional light in both forward and deferred), the derivatives are wrong
    // on edges or intersections of objects, leading to shadow artifacts. Thus it is disabled by default.
    float3 biasUVZ = 0;

#if defined(UNITY_USE_RECEIVER_PLANE_BIAS) && defined(SHADOWMAPSAMPLER_AND_TEXELSIZE_DEFINED)
    float3 dx = ddx(shadowCoord);
    float3 dy = ddy(shadowCoord);

    biasUVZ.x = dy.y * dx.z - dx.y * dy.z;
    biasUVZ.y = dx.x * dy.z - dy.x * dx.z;
    biasUVZ.xy *= biasMultiply / ((dx.x * dy.y) - (dx.y * dy.x));

    // Static depth biasing to make up for incorrect fractional sampling on the shadow map grid.
    const float UNITY_RECEIVER_PLANE_MIN_FRACTIONAL_ERROR = 0.01f;
    float fractionalSamplingError = dot(_ShadowMapTexture_TexelSize.xy, abs(biasUVZ.xy));
    biasUVZ.z = -min(fractionalSamplingError, UNITY_RECEIVER_PLANE_MIN_FRACTIONAL_ERROR);
    #if defined(UNITY_REVERSED_Z)
        biasUVZ.z *= -1;
    #endif
#endif

    return biasUVZ;
}

/**
* Combines the different components of a shadow coordinate and returns the final coordinate.
* See UnityGetReceiverPlaneDepthBias
*/
float3 UnityCombineShadowcoordComponents(float2 baseUV, float2 deltaUV, float depth, float3 receiverPlaneDepthBias)
{
    float3 uv = float3(baseUV + deltaUV, depth + receiverPlaneDepthBias.z);
    uv.z += dot(deltaUV, receiverPlaneDepthBias.xy);
    return uv;
}

// ------------------------------------------------------------------
//  PCF Filtering helpers
// ------------------------------------------------------------------

/**
* Assuming a isoceles rectangle triangle of height "triangleHeight" (as drawn below).
* This function return the area of the triangle above the first texel.
*
* |\      <-- 45 degree slop isosceles rectangle triangle
* | \
* ----    <-- length of this side is "triangleHeight"
* _ _ _ _ <-- texels
*/
float _UnityInternalGetAreaAboveFirstTexelUnderAIsocelesRectangleTriangle(float triangleHeight)
{
    return triangleHeight - 0.5;
}

/**
* Assuming a isoceles triangle of 1.5 texels height and 3 texels wide lying on 4 texels.
* This function return the area of the triangle above each of those texels.
*    |    <-- offset from -0.5 to 0.5, 0 meaning triangle is exactly in the center
*   / \   <-- 45 degree slop isosceles triangle (ie tent projected in 2D)
*  /   \
* _ _ _ _ <-- texels
* X Y Z W <-- result indices (in computedArea.xyzw and computedAreaUncut.xyzw)
*/
void _UnityInternalGetAreaPerTexel_3TexelsWideTriangleFilter(float offset, out float4 computedArea, out float4 computedAreaUncut)
{
    //Compute the exterior areas
    float offset01SquaredHalved = (offset + 0.5) * (offset + 0.5) * 0.5;
    computedAreaUncut.x = computedArea.x = offset01SquaredHalved - offset;
    computedAreaUncut.w = computedArea.w = offset01SquaredHalved;

    //Compute the middle areas
    //For Y : We find the area in Y of as if the left section of the isoceles triangle would
    //intersect the axis between Y and Z (ie where offset = 0).
    computedAreaUncut.y = _UnityInternalGetAreaAboveFirstTexelUnderAIsocelesRectangleTriangle(1.5 - offset);
    //This area is superior to the one we are looking for if (offset < 0) thus we need to
    //subtract the area of the triangle defined by (0,1.5-offset), (0,1.5+offset), (-offset,1.5).
    float clampedOffsetLeft = min(offset,0);
    float areaOfSmallLeftTriangle = clampedOffsetLeft * clampedOffsetLeft;
    computedArea.y = computedAreaUncut.y - areaOfSmallLeftTriangle;

    //We do the same for the Z but with the right part of the isoceles triangle
    computedAreaUncut.z = _UnityInternalGetAreaAboveFirstTexelUnderAIsocelesRectangleTriangle(1.5 + offset);
    float clampedOffsetRight = max(offset,0);
    float areaOfSmallRightTriangle = clampedOffsetRight * clampedOffsetRight;
    computedArea.z = computedAreaUncut.z - areaOfSmallRightTriangle;
}

/**
 * Assuming a isoceles triangle of 1.5 texels height and 3 texels wide lying on 4 texels.
 * This function return the weight of each texels area relative to the full triangle area.
 */
void _UnityInternalGetWeightPerTexel_3TexelsWideTriangleFilter(float offset, out float4 computedWeight)
{
    float4 dummy;
    _UnityInternalGetAreaPerTexel_3TexelsWideTriangleFilter(offset, computedWeight, dummy);
    computedWeight *= 0.44444;//0.44 == 1/(the triangle area)
}

/**
* Assuming a isoceles triangle of 2.5 texel height and 5 texels wide lying on 6 texels.
* This function return the weight of each texels area relative to the full triangle area.
*  /       \
* _ _ _ _ _ _ <-- texels
* 0 1 2 3 4 5 <-- computed area indices (in texelsWeights[])
*/
void _UnityInternalGetWeightPerTexel_5TexelsWideTriangleFilter(float offset, out float3 texelsWeightsA, out float3 texelsWeightsB)
{
    //See _UnityInternalGetAreaPerTexel_3TexelTriangleFilter for details.
    float4 computedArea_From3texelTriangle;
    float4 computedAreaUncut_From3texelTriangle;
    _UnityInternalGetAreaPerTexel_3TexelsWideTriangleFilter(offset, computedArea_From3texelTriangle, computedAreaUncut_From3texelTriangle);

    //Triangle slop is 45 degree thus we can almost reuse the result of the 3 texel wide computation.
    //the 5 texel wide triangle can be seen as the 3 texel wide one but shifted up by one unit/texel.
    //0.16 is 1/(the triangle area)
    texelsWeightsA.x = 0.16 * (computedArea_From3texelTriangle.x);
    texelsWeightsA.y = 0.16 * (computedAreaUncut_From3texelTriangle.y);
    texelsWeightsA.z = 0.16 * (computedArea_From3texelTriangle.y + 1);
    texelsWeightsB.x = 0.16 * (computedArea_From3texelTriangle.z + 1);
    texelsWeightsB.y = 0.16 * (computedAreaUncut_From3texelTriangle.z);
    texelsWeightsB.z = 0.16 * (computedArea_From3texelTriangle.w);
}

/**
* Assuming a isoceles triangle of 3.5 texel height and 7 texels wide lying on 8 texels.
* This function return the weight of each texels area relative to the full triangle area.
*  /           \
* _ _ _ _ _ _ _ _ <-- texels
* 0 1 2 3 4 5 6 7 <-- computed area indices (in texelsWeights[])
*/
void _UnityInternalGetWeightPerTexel_7TexelsWideTriangleFilter(float offset, out float4 texelsWeightsA, out float4 texelsWeightsB)
{
    //See _UnityInternalGetAreaPerTexel_3TexelTriangleFilter for details.
    float4 computedArea_From3texelTriangle;
    float4 computedAreaUncut_From3texelTriangle;
    _UnityInternalGetAreaPerTexel_3TexelsWideTriangleFilter(offset, computedArea_From3texelTriangle, computedAreaUncut_From3texelTriangle);

    //Triangle slop is 45 degree thus we can almost reuse the result of the 3 texel wide computation.
    //the 7 texel wide triangle can be seen as the 3 texel wide one but shifted up by two unit/texel.
    //0.081632 is 1/(the triangle area)
    texelsWeightsA.x = 0.081632 * (computedArea_From3texelTriangle.x);
    texelsWeightsA.y = 0.081632 * (computedAreaUncut_From3texelTriangle.y);
    texelsWeightsA.z = 0.081632 * (computedAreaUncut_From3texelTriangle.y + 1);
    texelsWeightsA.w = 0.081632 * (computedArea_From3texelTriangle.y + 2);
    texelsWeightsB.x = 0.081632 * (computedArea_From3texelTriangle.z + 2);
    texelsWeightsB.y = 0.081632 * (computedAreaUncut_From3texelTriangle.z + 1);
    texelsWeightsB.z = 0.081632 * (computedAreaUncut_From3texelTriangle.z);
    texelsWeightsB.w = 0.081632 * (computedArea_From3texelTriangle.w);
}

// ------------------------------------------------------------------
//  PCF Filtering
// ------------------------------------------------------------------

/**
* PCF gaussian shadowmap filtering based on a 3x3 kernel (9 taps no PCF hardware support)
*/
half UnitySampleShadowmap_PCF3x3NoHardwareSupport(float4 coord, float3 receiverPlaneDepthBias)
{
    half shadow = 1;

#ifdef SHADOWMAPSAMPLER_AND_TEXELSIZE_DEFINED
    // when we don't have hardware PCF sampling, then the above 5x5 optimized PCF really does not work.
    // Fallback to a simple 3x3 sampling with averaged results.
    float2 base_uv = coord.xy;
    float2 ts = _ShadowMapTexture_TexelSize.xy;
    shadow = 0;
    shadow += UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(base_uv, float2(-ts.x, -ts.y), coord.z, receiverPlaneDepthBias));
    shadow += UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(base_uv, float2(0, -ts.y), coord.z, receiverPlaneDepthBias));
    shadow += UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(base_uv, float2(ts.x, -ts.y), coord.z, receiverPlaneDepthBias));
    shadow += UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(base_uv, float2(-ts.x, 0), coord.z, receiverPlaneDepthBias));
    shadow += UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(base_uv, float2(0, 0), coord.z, receiverPlaneDepthBias));
    shadow += UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(base_uv, float2(ts.x, 0), coord.z, receiverPlaneDepthBias));
    shadow += UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(base_uv, float2(-ts.x, ts.y), coord.z, receiverPlaneDepthBias));
    shadow += UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(base_uv, float2(0, ts.y), coord.z, receiverPlaneDepthBias));
    shadow += UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(base_uv, float2(ts.x, ts.y), coord.z, receiverPlaneDepthBias));
    shadow /= 9.0;
#endif

    return shadow;
}

/**
* PCF tent shadowmap filtering based on a 3x3 kernel (optimized with 4 taps)
*/
half UnitySampleShadowmap_PCF3x3Tent(float4 coord, float3 receiverPlaneDepthBias)
{
    half shadow = 1;

#ifdef SHADOWMAPSAMPLER_AND_TEXELSIZE_DEFINED

    #ifndef SHADOWS_NATIVE
        // when we don't have hardware PCF sampling, fallback to a simple 3x3 sampling with averaged results.
        return UnitySampleShadowmap_PCF3x3NoHardwareSupport(coord, receiverPlaneDepthBias);
    #endif

    // tent base is 3x3 base thus covering from 9 to 12 texels, thus we need 4 bilinear PCF fetches
    float2 tentCenterInTexelSpace = coord.xy * _ShadowMapTexture_TexelSize.zw;
    float2 centerOfFetchesInTexelSpace = floor(tentCenterInTexelSpace + 0.5);
    float2 offsetFromTentCenterToCenterOfFetches = tentCenterInTexelSpace - centerOfFetchesInTexelSpace;

    // find the weight of each texel based
    float4 texelsWeightsU, texelsWeightsV;
    _UnityInternalGetWeightPerTexel_3TexelsWideTriangleFilter(offsetFromTentCenterToCenterOfFetches.x, texelsWeightsU);
    _UnityInternalGetWeightPerTexel_3TexelsWideTriangleFilter(offsetFromTentCenterToCenterOfFetches.y, texelsWeightsV);

    // each fetch will cover a group of 2x2 texels, the weight of each group is the sum of the weights of the texels
    float2 fetchesWeightsU = texelsWeightsU.xz + texelsWeightsU.yw;
    float2 fetchesWeightsV = texelsWeightsV.xz + texelsWeightsV.yw;

    // move the PCF bilinear fetches to respect texels weights
    float2 fetchesOffsetsU = texelsWeightsU.yw / fetchesWeightsU.xy + float2(-1.5,0.5);
    float2 fetchesOffsetsV = texelsWeightsV.yw / fetchesWeightsV.xy + float2(-1.5,0.5);
    fetchesOffsetsU *= _ShadowMapTexture_TexelSize.xx;
    fetchesOffsetsV *= _ShadowMapTexture_TexelSize.yy;

    // fetch !
    float2 bilinearFetchOrigin = centerOfFetchesInTexelSpace * _ShadowMapTexture_TexelSize.xy;
    shadow =  fetchesWeightsU.x * fetchesWeightsV.x * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(bilinearFetchOrigin, float2(fetchesOffsetsU.x, fetchesOffsetsV.x), coord.z, receiverPlaneDepthBias));
    shadow += fetchesWeightsU.y * fetchesWeightsV.x * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(bilinearFetchOrigin, float2(fetchesOffsetsU.y, fetchesOffsetsV.x), coord.z, receiverPlaneDepthBias));
    shadow += fetchesWeightsU.x * fetchesWeightsV.y * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(bilinearFetchOrigin, float2(fetchesOffsetsU.x, fetchesOffsetsV.y), coord.z, receiverPlaneDepthBias));
    shadow += fetchesWeightsU.y * fetchesWeightsV.y * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(bilinearFetchOrigin, float2(fetchesOffsetsU.y, fetchesOffsetsV.y), coord.z, receiverPlaneDepthBias));
#endif

    return shadow;
}

/**
* PCF tent shadowmap filtering based on a 5x5 kernel (optimized with 9 taps)
*/
half UnitySampleShadowmap_PCF5x5Tent(float4 coord, float3 receiverPlaneDepthBias)
{
    half shadow = 1;

#ifdef SHADOWMAPSAMPLER_AND_TEXELSIZE_DEFINED

    #ifndef SHADOWS_NATIVE
        // when we don't have hardware PCF sampling, fallback to a simple 3x3 sampling with averaged results.
        return UnitySampleShadowmap_PCF3x3NoHardwareSupport(coord, receiverPlaneDepthBias);
    #endif

    // tent base is 5x5 base thus covering from 25 to 36 texels, thus we need 9 bilinear PCF fetches
    float2 tentCenterInTexelSpace = coord.xy * _ShadowMapTexture_TexelSize.zw;
    float2 centerOfFetchesInTexelSpace = floor(tentCenterInTexelSpace + 0.5);
    float2 offsetFromTentCenterToCenterOfFetches = tentCenterInTexelSpace - centerOfFetchesInTexelSpace;

    // find the weight of each texel based on the area of a 45 degree slop tent above each of them.
    float3 texelsWeightsU_A, texelsWeightsU_B;
    float3 texelsWeightsV_A, texelsWeightsV_B;
    _UnityInternalGetWeightPerTexel_5TexelsWideTriangleFilter(offsetFromTentCenterToCenterOfFetches.x, texelsWeightsU_A, texelsWeightsU_B);
    _UnityInternalGetWeightPerTexel_5TexelsWideTriangleFilter(offsetFromTentCenterToCenterOfFetches.y, texelsWeightsV_A, texelsWeightsV_B);

    // each fetch will cover a group of 2x2 texels, the weight of each group is the sum of the weights of the texels
    float3 fetchesWeightsU = float3(texelsWeightsU_A.xz, texelsWeightsU_B.y) + float3(texelsWeightsU_A.y, texelsWeightsU_B.xz);
    float3 fetchesWeightsV = float3(texelsWeightsV_A.xz, texelsWeightsV_B.y) + float3(texelsWeightsV_A.y, texelsWeightsV_B.xz);

    // move the PCF bilinear fetches to respect texels weights
    float3 fetchesOffsetsU = float3(texelsWeightsU_A.y, texelsWeightsU_B.xz) / fetchesWeightsU.xyz + float3(-2.5,-0.5,1.5);
    float3 fetchesOffsetsV = float3(texelsWeightsV_A.y, texelsWeightsV_B.xz) / fetchesWeightsV.xyz + float3(-2.5,-0.5,1.5);
    fetchesOffsetsU *= _ShadowMapTexture_TexelSize.xxx;
    fetchesOffsetsV *= _ShadowMapTexture_TexelSize.yyy;

    // fetch !
    float2 bilinearFetchOrigin = centerOfFetchesInTexelSpace * _ShadowMapTexture_TexelSize.xy;
    shadow  = fetchesWeightsU.x * fetchesWeightsV.x * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(bilinearFetchOrigin, float2(fetchesOffsetsU.x, fetchesOffsetsV.x), coord.z, receiverPlaneDepthBias));
    shadow += fetchesWeightsU.y * fetchesWeightsV.x * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(bilinearFetchOrigin, float2(fetchesOffsetsU.y, fetchesOffsetsV.x), coord.z, receiverPlaneDepthBias));
    shadow += fetchesWeightsU.z * fetchesWeightsV.x * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(bilinearFetchOrigin, float2(fetchesOffsetsU.z, fetchesOffsetsV.x), coord.z, receiverPlaneDepthBias));
    shadow += fetchesWeightsU.x * fetchesWeightsV.y * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(bilinearFetchOrigin, float2(fetchesOffsetsU.x, fetchesOffsetsV.y), coord.z, receiverPlaneDepthBias));
    shadow += fetchesWeightsU.y * fetchesWeightsV.y * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(bilinearFetchOrigin, float2(fetchesOffsetsU.y, fetchesOffsetsV.y), coord.z, receiverPlaneDepthBias));
    shadow += fetchesWeightsU.z * fetchesWeightsV.y * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(bilinearFetchOrigin, float2(fetchesOffsetsU.z, fetchesOffsetsV.y), coord.z, receiverPlaneDepthBias));
    shadow += fetchesWeightsU.x * fetchesWeightsV.z * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(bilinearFetchOrigin, float2(fetchesOffsetsU.x, fetchesOffsetsV.z), coord.z, receiverPlaneDepthBias));
    shadow += fetchesWeightsU.y * fetchesWeightsV.z * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(bilinearFetchOrigin, float2(fetchesOffsetsU.y, fetchesOffsetsV.z), coord.z, receiverPlaneDepthBias));
    shadow += fetchesWeightsU.z * fetchesWeightsV.z * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(bilinearFetchOrigin, float2(fetchesOffsetsU.z, fetchesOffsetsV.z), coord.z, receiverPlaneDepthBias));
#endif

    return shadow;
}

/**
* PCF tent shadowmap filtering based on a 7x7 kernel (optimized with 16 taps)
*/
half UnitySampleShadowmap_PCF7x7Tent(float4 coord, float3 receiverPlaneDepthBias)
{
    half shadow = 1;

#ifdef SHADOWMAPSAMPLER_AND_TEXELSIZE_DEFINED

    #ifndef SHADOWS_NATIVE
        // when we don't have hardware PCF sampling, fallback to a simple 3x3 sampling with averaged results.
        return UnitySampleShadowmap_PCF3x3NoHardwareSupport(coord, receiverPlaneDepthBias);
    #endif

    // tent base is 7x7 base thus covering from 49 to 64 texels, thus we need 16 bilinear PCF fetches
    float2 tentCenterInTexelSpace = coord.xy * _ShadowMapTexture_TexelSize.zw;
    float2 centerOfFetchesInTexelSpace = floor(tentCenterInTexelSpace + 0.5);
    float2 offsetFromTentCenterToCenterOfFetches = tentCenterInTexelSpace - centerOfFetchesInTexelSpace;

    // find the weight of each texel based on the area of a 45 degree slop tent above each of them.
    float4 texelsWeightsU_A, texelsWeightsU_B;
    float4 texelsWeightsV_A, texelsWeightsV_B;
    _UnityInternalGetWeightPerTexel_7TexelsWideTriangleFilter(offsetFromTentCenterToCenterOfFetches.x, texelsWeightsU_A, texelsWeightsU_B);
    _UnityInternalGetWeightPerTexel_7TexelsWideTriangleFilter(offsetFromTentCenterToCenterOfFetches.y, texelsWeightsV_A, texelsWeightsV_B);

    // each fetch will cover a group of 2x2 texels, the weight of each group is the sum of the weights of the texels
    float4 fetchesWeightsU = float4(texelsWeightsU_A.xz, texelsWeightsU_B.xz) + float4(texelsWeightsU_A.yw, texelsWeightsU_B.yw);
    float4 fetchesWeightsV = float4(texelsWeightsV_A.xz, texelsWeightsV_B.xz) + float4(texelsWeightsV_A.yw, texelsWeightsV_B.yw);

    // move the PCF bilinear fetches to respect texels weights
    float4 fetchesOffsetsU = float4(texelsWeightsU_A.yw, texelsWeightsU_B.yw) / fetchesWeightsU.xyzw + float4(-3.5,-1.5,0.5,2.5);
    float4 fetchesOffsetsV = float4(texelsWeightsV_A.yw, texelsWeightsV_B.yw) / fetchesWeightsV.xyzw + float4(-3.5,-1.5,0.5,2.5);
    fetchesOffsetsU *= _ShadowMapTexture_TexelSize.xxxx;
    fetchesOffsetsV *= _ShadowMapTexture_TexelSize.yyyy;

    // fetch !
    float2 bilinearFetchOrigin = centerOfFetchesInTexelSpace * _ShadowMapTexture_TexelSize.xy;
    shadow  = fetchesWeightsU.x * fetchesWeightsV.x * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(bilinearFetchOrigin, float2(fetchesOffsetsU.x, fetchesOffsetsV.x), coord.z, receiverPlaneDepthBias));
    shadow += fetchesWeightsU.y * fetchesWeightsV.x * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(bilinearFetchOrigin, float2(fetchesOffsetsU.y, fetchesOffsetsV.x), coord.z, receiverPlaneDepthBias));
    shadow += fetchesWeightsU.z * fetchesWeightsV.x * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(bilinearFetchOrigin, float2(fetchesOffsetsU.z, fetchesOffsetsV.x), coord.z, receiverPlaneDepthBias));
    shadow += fetchesWeightsU.w * fetchesWeightsV.x * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(bilinearFetchOrigin, float2(fetchesOffsetsU.w, fetchesOffsetsV.x), coord.z, receiverPlaneDepthBias));
    shadow += fetchesWeightsU.x * fetchesWeightsV.y * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(bilinearFetchOrigin, float2(fetchesOffsetsU.x, fetchesOffsetsV.y), coord.z, receiverPlaneDepthBias));
    shadow += fetchesWeightsU.y * fetchesWeightsV.y * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(bilinearFetchOrigin, float2(fetchesOffsetsU.y, fetchesOffsetsV.y), coord.z, receiverPlaneDepthBias));
    shadow += fetchesWeightsU.z * fetchesWeightsV.y * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(bilinearFetchOrigin, float2(fetchesOffsetsU.z, fetchesOffsetsV.y), coord.z, receiverPlaneDepthBias));
    shadow += fetchesWeightsU.w * fetchesWeightsV.y * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(bilinearFetchOrigin, float2(fetchesOffsetsU.w, fetchesOffsetsV.y), coord.z, receiverPlaneDepthBias));
    shadow += fetchesWeightsU.x * fetchesWeightsV.z * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(bilinearFetchOrigin, float2(fetchesOffsetsU.x, fetchesOffsetsV.z), coord.z, receiverPlaneDepthBias));
    shadow += fetchesWeightsU.y * fetchesWeightsV.z * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(bilinearFetchOrigin, float2(fetchesOffsetsU.y, fetchesOffsetsV.z), coord.z, receiverPlaneDepthBias));
    shadow += fetchesWeightsU.z * fetchesWeightsV.z * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(bilinearFetchOrigin, float2(fetchesOffsetsU.z, fetchesOffsetsV.z), coord.z, receiverPlaneDepthBias));
    shadow += fetchesWeightsU.w * fetchesWeightsV.z * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(bilinearFetchOrigin, float2(fetchesOffsetsU.w, fetchesOffsetsV.z), coord.z, receiverPlaneDepthBias));
    shadow += fetchesWeightsU.x * fetchesWeightsV.w * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(bilinearFetchOrigin, float2(fetchesOffsetsU.x, fetchesOffsetsV.w), coord.z, receiverPlaneDepthBias));
    shadow += fetchesWeightsU.y * fetchesWeightsV.w * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(bilinearFetchOrigin, float2(fetchesOffsetsU.y, fetchesOffsetsV.w), coord.z, receiverPlaneDepthBias));
    shadow += fetchesWeightsU.z * fetchesWeightsV.w * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(bilinearFetchOrigin, float2(fetchesOffsetsU.z, fetchesOffsetsV.w), coord.z, receiverPlaneDepthBias));
    shadow += fetchesWeightsU.w * fetchesWeightsV.w * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(bilinearFetchOrigin, float2(fetchesOffsetsU.w, fetchesOffsetsV.w), coord.z, receiverPlaneDepthBias));
#endif

    return shadow;
}

/**
* PCF gaussian shadowmap filtering based on a 3x3 kernel (optimized with 4 taps)
*
* Algorithm: http://the-witness.net/news/2013/09/shadow-mapping-summary-part-1/
* Implementation example: http://mynameismjp.wordpress.com/2013/09/10/shadow-maps/
*/
half UnitySampleShadowmap_PCF3x3Gaussian(float4 coord, float3 receiverPlaneDepthBias)
{
    half shadow = 1;

#ifdef SHADOWMAPSAMPLER_AND_TEXELSIZE_DEFINED

    #ifndef SHADOWS_NATIVE
        // when we don't have hardware PCF sampling, fallback to a simple 3x3 sampling with averaged results.
        return UnitySampleShadowmap_PCF3x3NoHardwareSupport(coord, receiverPlaneDepthBias);
    #endif

    const float2 offset = float2(0.5, 0.5);
    float2 uv = (coord.xy * _ShadowMapTexture_TexelSize.zw) + offset;
    float2 base_uv = (floor(uv) - offset) * _ShadowMapTexture_TexelSize.xy;
    float2 st = frac(uv);

    float2 uw = float2(3 - 2 * st.x, 1 + 2 * st.x);
    float2 u = float2((2 - st.x) / uw.x - 1, (st.x) / uw.y + 1);
    u *= _ShadowMapTexture_TexelSize.x;

    float2 vw = float2(3 - 2 * st.y, 1 + 2 * st.y);
    float2 v = float2((2 - st.y) / vw.x - 1, (st.y) / vw.y + 1);
    v *= _ShadowMapTexture_TexelSize.y;

    half sum = 0;

    sum += uw[0] * vw[0] * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(base_uv, float2(u[0], v[0]), coord.z, receiverPlaneDepthBias));
    sum += uw[1] * vw[0] * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(base_uv, float2(u[1], v[0]), coord.z, receiverPlaneDepthBias));
    sum += uw[0] * vw[1] * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(base_uv, float2(u[0], v[1]), coord.z, receiverPlaneDepthBias));
    sum += uw[1] * vw[1] * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(base_uv, float2(u[1], v[1]), coord.z, receiverPlaneDepthBias));

    shadow = sum / 16.0f;
#endif

    return shadow;
}

/**
* PCF gaussian shadowmap filtering based on a 5x5 kernel (optimized with 9 taps)
*
* Algorithm: http://the-witness.net/news/2013/09/shadow-mapping-summary-part-1/
* Implementation example: http://mynameismjp.wordpress.com/2013/09/10/shadow-maps/
*/
half UnitySampleShadowmap_PCF5x5Gaussian(float4 coord, float3 receiverPlaneDepthBias)
{
    half shadow = 1;

#ifdef SHADOWMAPSAMPLER_AND_TEXELSIZE_DEFINED

    #ifndef SHADOWS_NATIVE
        // when we don't have hardware PCF sampling, fallback to a simple 3x3 sampling with averaged results.
        return UnitySampleShadowmap_PCF3x3NoHardwareSupport(coord, receiverPlaneDepthBias);
    #endif

    const float2 offset = float2(0.5, 0.5);
    float2 uv = (coord.xy * _ShadowMapTexture_TexelSize.zw) + offset;
    float2 base_uv = (floor(uv) - offset) * _ShadowMapTexture_TexelSize.xy;
    float2 st = frac(uv);

    float3 uw = float3(4 - 3 * st.x, 7, 1 + 3 * st.x);
    float3 u = float3((3 - 2 * st.x) / uw.x - 2, (3 + st.x) / uw.y, st.x / uw.z + 2);
    u *= _ShadowMapTexture_TexelSize.x;

    float3 vw = float3(4 - 3 * st.y, 7, 1 + 3 * st.y);
    float3 v = float3((3 - 2 * st.y) / vw.x - 2, (3 + st.y) / vw.y, st.y / vw.z + 2);
    v *= _ShadowMapTexture_TexelSize.y;

    half sum = 0.0f;

    half3 accum = uw * vw.x;
    sum += accum.x * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(base_uv, float2(u.x, v.x), coord.z, receiverPlaneDepthBias));
    sum += accum.y * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(base_uv, float2(u.y, v.x), coord.z, receiverPlaneDepthBias));
    sum += accum.z * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(base_uv, float2(u.z, v.x), coord.z, receiverPlaneDepthBias));

    accum = uw * vw.y;
    sum += accum.x *  UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(base_uv, float2(u.x, v.y), coord.z, receiverPlaneDepthBias));
    sum += accum.y *  UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(base_uv, float2(u.y, v.y), coord.z, receiverPlaneDepthBias));
    sum += accum.z *  UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(base_uv, float2(u.z, v.y), coord.z, receiverPlaneDepthBias));

    accum = uw * vw.z;
    sum += accum.x * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(base_uv, float2(u.x, v.z), coord.z, receiverPlaneDepthBias));
    sum += accum.y * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(base_uv, float2(u.y, v.z), coord.z, receiverPlaneDepthBias));
    sum += accum.z * UNITY_SAMPLE_SHADOW(_ShadowMapTexture, UnityCombineShadowcoordComponents(base_uv, float2(u.z, v.z), coord.z, receiverPlaneDepthBias));
    shadow = sum / 144.0f;

#endif

    return shadow;
}

half UnitySampleShadowmap_PCF3x3(float4 coord, float3 receiverPlaneDepthBias)
{
    return UnitySampleShadowmap_PCF3x3Tent(coord, receiverPlaneDepthBias);
}

half UnitySampleShadowmap_PCF5x5(float4 coord, float3 receiverPlaneDepthBias)
{
    return UnitySampleShadowmap_PCF5x5Tent(coord, receiverPlaneDepthBias);
}

half UnitySampleShadowmap_PCF7x7(float4 coord, float3 receiverPlaneDepthBias)
{
    return UnitySampleShadowmap_PCF7x7Tent(coord, receiverPlaneDepthBias);
}

#endif // UNITY_BUILTIN_SHADOW_LIBRARY_INCLUDED
