// Made with Amplify Shader Editor v1.9.9.12
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Vefects/SH_Vefects_URP_VFX_Ambient_Sand_MV_New"
{
	Properties
	{
		[Space(33)][Header(MDC)][Space(13)] _MDC( "MDC", 2D ) = "white" {}
		[Space(33)][Header(AO Alpha)][Space(13)] _AOAlpha1( "AO Alpha", 2D ) = "white" {}
		[Space(33)][Header(Lighting)][Space(13)] _LitBySun( "Lit By Sun", Range( 0, 1 ) ) = 1
		_LightContribution( "Light Contribution", Range( 0, 1 ) ) = 1
		_HorizontalFlip( "Horizontal Flip", Float ) = 0
		_Color01( "Color 01", Color ) = ( 0.945098, 0.7137255, 0.427451, 1 )
		_Color02( "Color 02", Color ) = ( 0.6588235, 0.3803922, 0.227451, 1 )
		_Specular( "Specular", Float ) = 0
		_Smoothness( "Smoothness", Float ) = 0
		_Emission( "Emission", Float ) = 0.1
		_DepthFade( "Depth Fade", Float ) = 1
		[Space(33)][Header(Motion Vector Frame Blending)][Space(13)] _MotionVectors( "Motion Vectors", 2D ) = "white" {}
		_Rows( "Rows", Float ) = 8
		_Columns( "Columns", Float ) = 8
		_EncodedMotionIntensity( "Encoded Motion Intensity", Float ) = 1
		_MotionIntensity( "Motion Intensity", Range( 0, 1 ) ) = 0
		[Space(33)][Header(Opacity Cutout)][Space(13)] _OpacityCutout( "Opacity Cutout", 2D ) = "white" {}
		_OpacityCutoutEro( "Opacity Cutout Ero", Float ) = 0
		_OpacityCutoutSmoothness( "Opacity Cutout Smoothness", Float ) = 0.01
		[Space(33)][Header(Cam Depth Fade)][Space(13)] _CamDepthFadeLength( "Cam Depth Fade Length", Float ) = 1
		_CamDepthFadeOffset( "Cam Depth Fade Offset", Float ) = 0
		_UseSideFade( "Use Side Fade", Float ) = 1
		_SideFadeMultiply( "Side Fade Multiply", Float ) = 1.15
		_SideFadeMin( "Side Fade Min", Float ) = 0
		_SideFadeMax( "Side Fade Max", Float ) = 1
		[Space(13)][Header(AR)][Space(13)] _Cull1( "Cull", Float ) = 2
		_Src1( "Src", Float ) = 5
		_Dst1( "Dst", Float ) = 10
		_ZWrite1( "ZWrite", Float ) = 0
		_ZTest1( "ZTest", Float ) = 2


		//_TransmissionShadow( "Transmission Shadow", Range( 0, 1 ) ) = 0.5
		//_TransStrength( "Trans Strength", Range( 0, 50 ) ) = 1
		//_TransNormal( "Trans Normal Distortion", Range( 0, 1 ) ) = 0.5
		//_TransScattering( "Trans Scattering", Range( 1, 50 ) ) = 2
		//_TransDirect( "Trans Direct", Range( 0, 1 ) ) = 0.9
		//_TransAmbient( "Trans Ambient", Range( 0, 1 ) ) = 0.1
		//_TransShadow( "Trans Shadow", Range( 0, 1 ) ) = 0.5

		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25

		//_InstancedTerrainNormals("Instanced Terrain Normals", Float) = 1.0

		[ToggleOff(_SPECULARHIGHLIGHTS_OFF)] _SpecularHighlights("Specular Highlights", Float) = 1.0
		[ToggleOff] _EnvironmentReflections("Environment Reflections", Float) = 1.0
		//[HideInInspector][ToggleUI] _ReceiveShadows("Receive Shadows", Float) = 1.0

		[HideInInspector] _QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector] _QueueControl("_QueueControl", Float) = -1

        [HideInInspector][NoScaleOffset] unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}

		//[HideInInspector] _AlphaClip("__clip", Float) = 0.0
	}

	SubShader
	{
		PackageRequirements
		{
			"com.unity.render-pipelines.universal": "[14.0,15.0]"
		}

		

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" "UniversalMaterialType"="Lit" }

	LOD 0

		Cull [_Cull1]
		ZWrite [_ZWrite1]
		ZTest [_ZTest1]
		Offset 0 , 0
		AlphaToMask Off

		

		HLSLINCLUDE
		#pragma target 4.0
		#pragma prefer_hlslcc gles
		// ensure rendering platforms toggle list is visible

		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"

		#define ASE_ADJUST_CLIP_POSITION( x ) x

		#ifndef ASE_TESS_FUNCS
		#define ASE_TESS_FUNCS
		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}

		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
							(( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		#endif //ASE_TESS_FUNCS
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }

			Blend [_Src1] [_Dst1], SrcAlpha OneMinusSrcAlpha
			ZWrite [_ZWrite1]
			ZTest [_ZTest1]
			Offset 0 , 0
			ColorMask RGBA

			

			HLSLPROGRAM

			

			#define ASE_GEOMETRY
			#define _NORMAL_DROPOFF_TS 1
			#pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
			#pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
			#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
			#pragma multi_compile_instancing
			#pragma instancing_options renderinglayer
			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _SPECULAR_SETUP 1
			#define _EMISSION
			#define ASE_VERSION 19912
			#define ASE_SRP_VERSION 140007
			#define REQUIRE_DEPTH_TEXTURE 1


			

			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS

			
            #pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
		

			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION

			
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
           

			

			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile _ _LIGHT_LAYERS
			#pragma multi_compile_fragment _ _LIGHT_COOKIES
			#pragma multi_compile _ _FORWARD_PLUS

			

			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DYNAMICLIGHTMAP_ON

			#pragma vertex vert
			#pragma fragment frag

			#if defined( _SPECULAR_SETUP ) && defined( ASE_LIGHTING_SIMPLE )
				#if defined( _SPECULARHIGHLIGHTS_OFF )
					#undef _SPECULAR_COLOR
				#else
					#define _SPECULAR_COLOR
				#endif
			#endif

			#define SHADERPASS SHADERPASS_FORWARD

			
            #if ASE_SRP_VERSION >=140007
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#endif
		

			
			#if ASE_SRP_VERSION >=140007
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
			#endif
		

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"

			

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#if defined( UNITY_INSTANCING_ENABLED ) && defined( ASE_INSTANCED_TERRAIN ) && ( defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL) || defined(_INSTANCEDTERRAINNORMALS_PIXEL) )
				#define ENABLE_TERRAIN_PERPIXEL_NORMAL
			#endif

			#include "../../../Shared/Shaders/MotionVectorFrameBlending.hlsl"
			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES1
			#define ASE_NEEDS_WORLD_TANGENT
			#define ASE_NEEDS_FRAG_WORLD_TANGENT
			#define ASE_NEEDS_WORLD_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_BITANGENT
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_WORLD_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_SCREEN_POSITION_NORMALIZED


			#if defined(ASE_WRITE_DEPTH_CONSERVATIVE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				#if defined(LIGHTMAP_ON) || defined(ASE_NEEDS_TEXTURE_COORDINATES1)
					float4 texcoord1 : TEXCOORD1;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON) || defined(ASE_NEEDS_TEXTURE_COORDINATES2)
					float4 texcoord2 : TEXCOORD2;
				#endif
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float3 positionWS : TEXCOORD0;
				half3 normalWS : TEXCOORD1;
				float4 tangentWS : TEXCOORD2; // holds terrainUV ifdef ENABLE_TERRAIN_PERPIXEL_NORMAL
				float4 lightmapUVOrVertexSH : TEXCOORD3;
				#if defined(ASE_FOG) || defined(_ADDITIONAL_LIGHTS_VERTEX)
					half4 fogFactorAndVertexLight : TEXCOORD4;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON)
					float2 dynamicLightmapUV : TEXCOORD5;
				#endif
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_texcoord7 : TEXCOORD7;
				float4 ase_color : COLOR;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord8 : TEXCOORD8;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Color02;
			float4 _Color01;
			float _Cull1;
			float _CamDepthFadeLength;
			float _UseSideFade;
			float _SideFadeMultiply;
			float _SideFadeMax;
			float _SideFadeMin;
			float _OpacityCutoutSmoothness;
			float _OpacityCutoutEro;
			float _Emission;
			float _Smoothness;
			float _Specular;
			float _LightContribution;
			float _CamDepthFadeOffset;
			float _HorizontalFlip;
			float _MotionIntensity;
			float _EncodedMotionIntensity;
			float _Rows;
			float _Columns;
			float _ZWrite1;
			float _ZTest1;
			float _Dst1;
			float _Src1;
			float _LitBySun;
			float _DepthFade;
			float _AlphaClip;
			float _Cutoff;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _AOAlpha1;
			sampler2D _MotionVectors;
			sampler2D _MDC;
			sampler2D _OpacityCutout;


			
			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float3 objectToViewPos = TransformWorldToView( TransformObjectToWorld( input.positionOS.xyz ) );
				float eyeDepth = -objectToViewPos.z;
				output.ase_texcoord8.x = eyeDepth;
				
				output.ase_texcoord6 = input.texcoord;
				output.ase_texcoord7 = input.texcoord1;
				output.ase_color = input.ase_color;
				output.ase_normal = input.normalOS;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord8.yzw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif
				input.normalOS = input.normalOS;
				input.tangentOS = input.tangentOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );
				VertexNormalInputs normalInput = GetVertexNormalInputs( input.normalOS, input.tangentOS );

				#if defined(LIGHTMAP_ON)
					OUTPUT_LIGHTMAP_UV(input.texcoord1, unity_LightmapST, output.lightmapUVOrVertexSH.xy);
				#else
					OUTPUT_SH(normalInput.normalWS.xyz, output.lightmapUVOrVertexSH.xyz);
				#endif
				#if defined(DYNAMICLIGHTMAP_ON)
					output.dynamicLightmapUV.xy = input.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				#endif

				#if defined(ASE_FOG) || defined(_ADDITIONAL_LIGHTS_VERTEX)
					output.fogFactorAndVertexLight = 0;
					#if defined(ASE_FOG) && !defined(_FOG_FRAGMENT)
						output.fogFactorAndVertexLight.x = ComputeFogFactor(vertexInput.positionCS.z);
					#endif
					#ifdef _ADDITIONAL_LIGHTS_VERTEX
						half3 vertexLight = VertexLighting( vertexInput.positionWS, normalInput.normalWS );
						output.fogFactorAndVertexLight.yzw = vertexLight;
					#endif
				#endif

				output.positionCS = ASE_ADJUST_CLIP_POSITION( vertexInput.positionCS );
				output.positionWS = vertexInput.positionWS;
				output.normalWS = normalInput.normalWS;
				output.tangentWS = float4( normalInput.tangentWS, ( input.tangentOS.w > 0.0 ? 1.0 : -1.0 ) * GetOddNegativeScale() );

				#if defined( ENABLE_TERRAIN_PERPIXEL_NORMAL )
					output.tangentWS.zw = input.texcoord.xy;
					output.tangentWS.xy = input.texcoord.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				#if defined(LIGHTMAP_ON) || defined(ASE_NEEDS_TEXTURE_COORDINATES1)
					float4 texcoord1 : TEXCOORD1;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON) || defined(ASE_NEEDS_TEXTURE_COORDINATES2)
					float4 texcoord2 : TEXCOORD2;
				#endif
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.positionOS = input.positionOS;
				output.normalOS = input.normalOS;
				output.tangentOS = input.tangentOS;
				output.texcoord = input.texcoord;
				#if defined(LIGHTMAP_ON) || defined(ASE_NEEDS_TEXTURE_COORDINATES1)
					output.texcoord1 = input.texcoord1;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON) || defined(ASE_NEEDS_TEXTURE_COORDINATES2)
					output.texcoord2 = input.texcoord2;
				#endif
				output.ase_color = input.ase_color;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.tangentOS = patch[0].tangentOS * bary.x + patch[1].tangentOS * bary.y + patch[2].tangentOS * bary.z;
				output.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
				#if defined(LIGHTMAP_ON) || defined(ASE_NEEDS_TEXTURE_COORDINATES1)
					output.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON) || defined(ASE_NEEDS_TEXTURE_COORDINATES2)
					output.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				#endif
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].positionOS.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			half4 frag ( PackedVaryings input
						#if defined( ASE_WRITE_DEPTH )
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						#ifdef _WRITE_RENDERING_LAYERS
						, out float4 outRenderingLayers : SV_Target1
						#endif
						 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

				#if defined( _SURFACE_TYPE_TRANSPARENT )
					const bool isTransparent = true;
				#else
					const bool isTransparent = false;
				#endif

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				#if defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					float4 shadowCoord = TransformWorldToShadowCoord( input.positionWS );
				#else
					float4 shadowCoord = float4(0, 0, 0, 0);
				#endif

				// @diogo: mikktspace compliant
				float renormFactor = 1.0 / max( FLT_MIN, length( input.normalWS ) );

				float3 PositionWS = input.positionWS;
				float3 PositionRWS = GetCameraRelativePositionWS( PositionWS );
				float3 ViewDirWS = GetWorldSpaceNormalizeViewDir( PositionWS );
				float4 ShadowCoord = shadowCoord;
				float4 ScreenPosNorm = float4( GetNormalizedScreenSpaceUV( input.positionCS ), input.positionCS.zw );
				float4 ClipPos = ComputeClipSpacePosition( ScreenPosNorm.xy, input.positionCS.z ) * input.positionCS.w;
				float4 ScreenPos = ComputeScreenPos( ClipPos );
				float3 TangentWS = input.tangentWS.xyz * renormFactor;
				float3 BitangentWS = cross( input.normalWS, input.tangentWS.xyz ) * input.tangentWS.w * renormFactor;
				float3 NormalWS = input.normalWS * renormFactor;

				#if defined( ENABLE_TERRAIN_PERPIXEL_NORMAL )
					float2 sampleCoords = (input.tangentWS.zw / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
					NormalWS = TransformObjectToWorldNormal(normalize(SAMPLE_TEXTURE2D(_TerrainNormalmapTexture, sampler_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1));
					TangentWS = -cross(GetObjectToWorldMatrix()._13_23_33, NormalWS);
					BitangentWS = cross(NormalWS, -TangentWS);
				#endif

				float localComputeMotionFlow451 = ( 0.0 );
				float4 appendResult423 = (float4(input.ase_texcoord6.x , input.ase_texcoord6.y , 0.0 , 0.0));
				float4 ShurikenCurrentFrame431 = appendResult423;
				float2 currentFrameUV451 = ShurikenCurrentFrame431.xy;
				float ShurikenFrameIndex424 = input.ase_texcoord6.w;
				float FlipbookSize421 = ( _Columns * _Rows );
				float4 appendResult428 = (float4(input.ase_texcoord7.x , input.ase_texcoord7.y , 0.0 , 0.0));
				float4 ifLocalVar432 = 0;
				if( ShurikenFrameIndex424 >= ( FlipbookSize421 - 1.0 ) )
				ifLocalVar432 = ShurikenCurrentFrame431;
				else
				ifLocalVar432 = appendResult428;
				float4 ShurikenNextFrame435 = ifLocalVar432;
				float2 nextFrameUV451 = ShurikenNextFrame435.xy;
				float4 currentMV451 = tex2D( _MotionVectors, ShurikenCurrentFrame431.xy );
				float4 tex2DNode438 = tex2D( _MotionVectors, ShurikenNextFrame435.xy );
				float2 appendResult445 = (float2(tex2DNode438.r , tex2DNode438.g));
				float2 nextMV451 = appendResult445;
				float isIntensityEncoded451 = _EncodedMotionIntensity;
				float motionIntensity451 = _MotionIntensity;
				float columns451 = _Columns;
				float rows451 = _Rows;
				float ShurikenBlendFactor440 = input.ase_texcoord6.z;
				float blendFactor451 = ShurikenBlendFactor440;
				float2 currentFrameMVUV451 = float2( 0,0 );
				float2 nextFrameMVUV451 = float2( 0,0 );
				ComputeMotionFlow_float( currentFrameUV451 , nextFrameUV451 , currentMV451 , nextMV451 , isIntensityEncoded451 , motionIntensity451 , columns451 , rows451 , blendFactor451 , currentFrameMVUV451 , nextFrameMVUV451 );
				float4 lerpResult455 = lerp( tex2D( _AOAlpha1, currentFrameMVUV451 ) , tex2D( _AOAlpha1, nextFrameMVUV451 ) , ShurikenBlendFactor440);
				float4 TextureAlpha457 = lerpResult455;
				float4 break462 = TextureAlpha457;
				float3x3 ase_worldToTangent = float3x3( TangentWS, BitangentWS, NormalWS );
				float3 worldToTangentDir518 = normalize( mul( ase_worldToTangent, SafeNormalize( _MainLightPosition.xyz ) ) );
				float3 break499 = worldToTangentDir518;
				float4 lerpResult545 = lerp( tex2D( _MDC, currentFrameMVUV451 ) , tex2D( _MDC, nextFrameMVUV451 ) , ShurikenBlendFactor440);
				float4 TextureColor547 = lerpResult545;
				float4 break536 = TextureColor547;
				float ifLocalVar542 = 0;
				if( _HorizontalFlip > 0.0 )
				ifLocalVar542 = break536.r;
				else if( _HorizontalFlip < 0.0 )
				ifLocalVar542 = break536.g;
				float left541 = ifLocalVar542;
				float ifLocalVar543 = 0;
				if( _HorizontalFlip > 0.0 )
				ifLocalVar543 = break536.g;
				else if( _HorizontalFlip < 0.0 )
				ifLocalVar543 = break536.r;
				float right538 = ifLocalVar543;
				float ifLocalVar505 = 0;
				if( break499.x > 0.0 )
				ifLocalVar505 = left541;
				else if( break499.x < 0.0 )
				ifLocalVar505 = right538;
				float top540 = break536.b;
				float bottom539 = break536.a;
				float ifLocalVar508 = 0;
				if( break499.y > 0.0 )
				ifLocalVar508 = top540;
				else if( break499.y < 0.0 )
				ifLocalVar508 = bottom539;
				float saferPower530 = abs( ( ( ( right538 + left541 ) + ( top540 + bottom539 ) ) / 4.0 ) );
				float front529 = pow( saferPower530 , 0.625 );
				float temp_output_525_0 = ( front529 * front529 );
				float temp_output_521_0 = ( temp_output_525_0 * temp_output_525_0 );
				float temp_output_522_0 = ( temp_output_521_0 * temp_output_521_0 );
				float back519 = ( ( ( temp_output_522_0 * temp_output_522_0 ) / 2.0 ) + saturate( ( ( 1.0 - front529 ) / 4.0 ) ) );
				float ifLocalVar513 = 0;
				if( break499.z > 0.0 )
				ifLocalVar513 = front529;
				else if( break499.z < 0.0 )
				ifLocalVar513 = back519;
				float lightmap504 = ( ( ( ( break499.x * break499.x ) * ifLocalVar505 ) + ( ( break499.y * break499.y ) * ifLocalVar508 ) ) + ( ( break499.z * break499.z ) * ifLocalVar513 ) );
				float lerpResult488 = lerp( 1.0 , lightmap504 , saturate( _LightContribution ));
				float lerpResult490 = lerp( break462.g , lerpResult488 , saturate( _LitBySun ));
				float3 lerpResult483 = lerp( _Color01.rgb , _Color02.rgb , lerpResult490);
				float3 lerpResult482 = lerp( _Color02.rgb , lerpResult483 , break462.a);
				float4 temp_output_486_0 = ( float4( lerpResult482 , 0.0 ) * input.ase_color );
				
				float3 temp_cast_7 = (_Specular).xxx;
				
				float2 texCoord459 = input.ase_texcoord6.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult456 = (float2(_Columns , _Rows));
				float2 Flipbook_Tile458 = appendResult456;
				float smoothstepResult471 = smoothstep( _OpacityCutoutEro , ( _OpacityCutoutEro + _OpacityCutoutSmoothness ) , tex2D( _OpacityCutout, ( texCoord459 * Flipbook_Tile458 ) ).g);
				float temp_output_231_0 = saturate( saturate( ( saturate( ( input.ase_color.a * break462.a ) ) * smoothstepResult471 ) ) );
				float3 normalizeResult244 = normalize( ( _WorldSpaceCameraPos - PositionWS ) );
				float dotResult249 = dot( input.ase_normal , normalizeResult244 );
				float lerpResult254 = lerp( _SideFadeMin , _SideFadeMax , saturate( ( ( 1.0 - abs( dotResult249 ) ) * _SideFadeMultiply ) ));
				float lerpResult236 = lerp( temp_output_231_0 , saturate( ( temp_output_231_0 * saturate( ( 1.0 - saturate( lerpResult254 ) ) ) ) ) , _UseSideFade);
				float eyeDepth = input.ase_texcoord8.x;
				float cameraDepthFade206 = (( eyeDepth -_ProjectionParams.y - _CamDepthFadeOffset ) / _CamDepthFadeLength);
				float camFade208 = saturate( cameraDepthFade206 );
				float screenDepth474 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ScreenPosNorm.xy ),_ZBufferParams);
				float distanceDepth474 = saturate( ( screenDepth474 - LinearEyeDepth( ScreenPosNorm.z,_ZBufferParams ) ) / ( _DepthFade ) );
				

				float3 BaseColor = temp_output_486_0.rgb;
				float3 Normal = float3(0, 0, 1);
				float3 Specular = temp_cast_7;
				float Metallic = 0;
				float Smoothness = _Smoothness;
				float Occlusion = 1;
				float3 Emission = ( temp_output_486_0 * _Emission ).rgb;
				float Alpha = saturate( ( saturate( ( saturate( lerpResult236 ) * camFade208 ) ) * distanceDepth474 ) );
				#if defined( _ALPHATEST_ON )
					float AlphaClipThreshold = _Cutoff;
					float AlphaClipThresholdShadow = 0.5;
				#endif
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;

				#if defined( ASE_WRITE_DEPTH )
					input.positionCS.z = input.positionCS.z;
				#endif

				#ifdef _CLEARCOAT
					float CoatMask = 0;
					float CoatSmoothness = 0;
				#endif

				#if defined( _ALPHATEST_ON )
					AlphaDiscard( Alpha, AlphaClipThreshold );
				#endif

				#if defined(MAIN_LIGHT_CALCULATE_SHADOWS) && defined(ASE_CHANGES_WORLD_POS)
					ShadowCoord = TransformWorldToShadowCoord( PositionWS );
				#endif

				InputData inputData = (InputData)0;
				inputData.positionWS = PositionWS;
				inputData.positionCS = input.positionCS;
				inputData.normalizedScreenSpaceUV = ScreenPosNorm.xy;
				inputData.viewDirectionWS = ViewDirWS;
				inputData.shadowCoord = ShadowCoord;

				#ifdef _NORMALMAP
						#if _NORMAL_DROPOFF_TS
							inputData.normalWS = TransformTangentToWorld(Normal, half3x3(TangentWS, BitangentWS, NormalWS));
						#elif _NORMAL_DROPOFF_OS
							inputData.normalWS = TransformObjectToWorldNormal(Normal);
						#elif _NORMAL_DROPOFF_WS
							inputData.normalWS = Normal;
						#endif
					inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
				#else
					inputData.normalWS = NormalWS;
				#endif

				#ifdef ASE_FOG
					inputData.fogCoord = InitializeInputDataFog(float4(inputData.positionWS, 1.0), input.fogFactorAndVertexLight.x);
				#endif
				#ifdef _ADDITIONAL_LIGHTS_VERTEX
					inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
				#endif

				#if defined( ENABLE_TERRAIN_PERPIXEL_NORMAL )
					float3 SH = SampleSH(inputData.normalWS.xyz);
				#else
					float3 SH = input.lightmapUVOrVertexSH.xyz;
				#endif

				#if defined(DYNAMICLIGHTMAP_ON)
					inputData.bakedGI = SAMPLE_GI(input.lightmapUVOrVertexSH.xy, input.dynamicLightmapUV.xy, SH, inputData.normalWS);
				#else
					inputData.bakedGI = SAMPLE_GI(input.lightmapUVOrVertexSH.xy, SH, inputData.normalWS);
				#endif

				#ifdef ASE_BAKEDGI
					inputData.bakedGI = BakedGI;
				#endif

				inputData.shadowMask = SAMPLE_SHADOWMASK(input.lightmapUVOrVertexSH.xy);

				#if defined(DEBUG_DISPLAY)
					#if defined(DYNAMICLIGHTMAP_ON)
						inputData.dynamicLightmapUV = input.dynamicLightmapUV.xy;
					#endif
					#if defined(LIGHTMAP_ON)
						inputData.staticLightmapUV = input.lightmapUVOrVertexSH.xy;
					#else
						inputData.vertexSH = SH;
					#endif
				#endif

				SurfaceData surfaceData;
				surfaceData.albedo              = BaseColor;
				surfaceData.metallic            = saturate(Metallic);
				surfaceData.specular            = Specular;
				surfaceData.smoothness          = saturate(Smoothness),
				surfaceData.occlusion           = Occlusion,
				surfaceData.emission            = Emission,
				surfaceData.alpha               = saturate(Alpha);
				surfaceData.normalTS            = Normal;
				surfaceData.clearCoatMask       = 0;
				surfaceData.clearCoatSmoothness = 1;

				#ifdef _CLEARCOAT
					surfaceData.clearCoatMask       = saturate(CoatMask);
					surfaceData.clearCoatSmoothness = saturate(CoatSmoothness);
				#endif

				#if defined(_DBUFFER)
					ApplyDecalToSurfaceData(input.positionCS, surfaceData, inputData);
				#endif

				#ifdef ASE_LIGHTING_SIMPLE
					half4 color = UniversalFragmentBlinnPhong( inputData, surfaceData);
				#else
					half4 color = UniversalFragmentPBR( inputData, surfaceData);
				#endif

				#ifdef ASE_TRANSMISSION
				{
					float shadow = _TransmissionShadow;

					#define SUM_LIGHT_TRANSMISSION(Light)\
						float3 atten = Light.color * Light.distanceAttenuation;\
						atten = lerp( atten, atten * Light.shadowAttenuation, shadow );\
						half3 transmission = max( 0, -dot( inputData.normalWS, Light.direction ) ) * atten * Transmission;\
						color.rgb += BaseColor * transmission;

					SUM_LIGHT_TRANSMISSION( GetMainLight( inputData.shadowCoord ) );

					#if defined(_ADDITIONAL_LIGHTS)
						uint meshRenderingLayers = GetMeshRenderingLayer();
						uint pixelLightCount = GetAdditionalLightsCount();
						#if USE_FORWARD_PLUS
							for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
							{
								FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK

								Light light = GetAdditionalLight(lightIndex, inputData.positionWS, inputData.shadowMask);
								#ifdef _LIGHT_LAYERS
								if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
								#endif
								{
									SUM_LIGHT_TRANSMISSION( light );
								}
							}
						#endif
						LIGHT_LOOP_BEGIN( pixelLightCount )
							Light light = GetAdditionalLight(lightIndex, inputData.positionWS, inputData.shadowMask);
							#ifdef _LIGHT_LAYERS
							if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
							#endif
							{
								SUM_LIGHT_TRANSMISSION( light );
							}
						LIGHT_LOOP_END
					#endif
				}
				#endif

				#ifdef ASE_TRANSLUCENCY
				{
					float shadow = _TransShadow;
					float normal = _TransNormal;
					float scattering = _TransScattering;
					float direct = _TransDirect;
					float ambient = _TransAmbient;
					float strength = _TransStrength;

					#define SUM_LIGHT_TRANSLUCENCY(Light)\
						float3 atten = Light.color * Light.distanceAttenuation;\
						atten = lerp( atten, atten * Light.shadowAttenuation, shadow );\
						half3 lightDir = Light.direction + inputData.normalWS * normal;\
						half VdotL = pow( saturate( dot( inputData.viewDirectionWS, -lightDir ) ), scattering );\
						half3 translucency = atten * ( VdotL * direct + inputData.bakedGI * ambient ) * Translucency;\
						color.rgb += BaseColor * translucency * strength;

					SUM_LIGHT_TRANSLUCENCY( GetMainLight( inputData.shadowCoord ) );

					#if defined(_ADDITIONAL_LIGHTS)
						uint meshRenderingLayers = GetMeshRenderingLayer();
						uint pixelLightCount = GetAdditionalLightsCount();
						#if USE_FORWARD_PLUS
							for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
							{
								FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK

								Light light = GetAdditionalLight(lightIndex, inputData.positionWS, inputData.shadowMask);
								#ifdef _LIGHT_LAYERS
								if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
								#endif
								{
									SUM_LIGHT_TRANSLUCENCY( light );
								}
							}
						#endif
						LIGHT_LOOP_BEGIN( pixelLightCount )
							Light light = GetAdditionalLight(lightIndex, inputData.positionWS, inputData.shadowMask);
							#ifdef _LIGHT_LAYERS
							if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
							#endif
							{
								SUM_LIGHT_TRANSLUCENCY( light );
							}
						LIGHT_LOOP_END
					#endif
				}
				#endif

				#ifdef ASE_REFRACTION
					float4 projScreenPos = ScreenPos / ScreenPos.w;
					float3 refractionOffset = ( RefractionIndex - 1.0 ) * mul( UNITY_MATRIX_V, float4( NormalWS,0 ) ).xyz * ( 1.0 - dot( NormalWS, ViewDirWS ) );
					projScreenPos.xy += refractionOffset.xy;
					float3 refraction = SHADERGRAPH_SAMPLE_SCENE_COLOR( projScreenPos.xy ) * RefractionColor;
					color.rgb = lerp( refraction, color.rgb, color.a );
					color.a = 1;
				#endif

				#ifdef ASE_FINAL_COLOR_ALPHA_MULTIPLY
					color.rgb *= color.a;
				#endif

				#ifdef ASE_FOG
					#ifdef TERRAIN_SPLAT_ADDPASS
						color.rgb = MixFogColor(color.rgb, half3(0,0,0), inputData.fogCoord);
					#else
						color.rgb = MixFog(color.rgb, inputData.fogCoord);
					#endif
				#endif

				#if defined( ASE_WRITE_DEPTH )
					outputDepth = input.positionCS.z;
				#endif

				#ifdef _WRITE_RENDERING_LAYERS
					uint renderingLayers = GetMeshRenderingLayer();
					outRenderingLayers = float4( EncodeMeshRenderingLayer( renderingLayers ), 0, 0, 0 );
				#endif

				#if defined( ASE_OPAQUE_KEEP_ALPHA )
					return half4( color.rgb, color.a );
				#else
					return half4( color.rgb, OutputAlpha( color.a, isTransparent ) );
				#endif
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off
			ColorMask 0

			HLSLPROGRAM

			

			#define ASE_GEOMETRY
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			#define ASE_FOG 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _SPECULAR_SETUP 1
			#define _EMISSION
			#define ASE_VERSION 19912
			#define ASE_SRP_VERSION 140007
			#define REQUIRE_DEPTH_TEXTURE 1


			

			#pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW // @diogo: removed _vertex for POM node

			#pragma vertex vert
			#pragma fragment frag

			#if defined( _SPECULAR_SETUP ) && defined( ASE_LIGHTING_SIMPLE )
				#if defined( _SPECULARHIGHLIGHTS_OFF )
					#undef _SPECULAR_COLOR
				#else
					#define _SPECULAR_COLOR
				#endif
			#endif

			#define SHADERPASS SHADERPASS_SHADOWCASTER

			
            #if ASE_SRP_VERSION >=140007
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#endif
		

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"

			

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#include "../../../Shared/Shaders/MotionVectorFrameBlending.hlsl"
			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES1
			#define ASE_NEEDS_WORLD_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_SCREEN_POSITION_NORMALIZED


			#if defined(ASE_WRITE_DEPTH_CONSERVATIVE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float3 positionWS : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Color02;
			float4 _Color01;
			float _Cull1;
			float _CamDepthFadeLength;
			float _UseSideFade;
			float _SideFadeMultiply;
			float _SideFadeMax;
			float _SideFadeMin;
			float _OpacityCutoutSmoothness;
			float _OpacityCutoutEro;
			float _Emission;
			float _Smoothness;
			float _Specular;
			float _LightContribution;
			float _CamDepthFadeOffset;
			float _HorizontalFlip;
			float _MotionIntensity;
			float _EncodedMotionIntensity;
			float _Rows;
			float _Columns;
			float _ZWrite1;
			float _ZTest1;
			float _Dst1;
			float _Src1;
			float _LitBySun;
			float _DepthFade;
			float _AlphaClip;
			float _Cutoff;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _AOAlpha1;
			sampler2D _MotionVectors;
			sampler2D _OpacityCutout;


			float3 _LightDirection;
			float3 _LightPosition;

			
			PackedVaryings VertexFunction( Attributes input )
			{
				PackedVaryings output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( output );

				float3 objectToViewPos = TransformWorldToView( TransformObjectToWorld( input.positionOS.xyz ) );
				float eyeDepth = -objectToViewPos.z;
				output.ase_texcoord3.x = eyeDepth;
				
				output.ase_color = input.ase_color;
				output.ase_texcoord1 = input.ase_texcoord;
				output.ase_texcoord2 = input.ase_texcoord1;
				output.ase_normal = input.normalOS;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord3.yzw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;
				input.tangentOS = input.tangentOS;

				float3 positionWS = TransformObjectToWorld( input.positionOS.xyz );
				float3 normalWS = TransformObjectToWorldDir(input.normalOS);

				#if _CASTING_PUNCTUAL_LIGHT_SHADOW
					float3 lightDirectionWS = normalize(_LightPosition - positionWS);
				#else
					float3 lightDirectionWS = _LightDirection;
				#endif

				float4 positionCS = ASE_ADJUST_CLIP_POSITION( TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS)) );

				#if UNITY_REVERSED_Z
					positionCS.z = min(positionCS.z, UNITY_NEAR_CLIP_VALUE);
				#else
					positionCS.z = max(positionCS.z, UNITY_NEAR_CLIP_VALUE);
				#endif

				output.positionCS = positionCS;
				output.positionWS = positionWS;
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.positionOS = input.positionOS;
				output.normalOS = input.normalOS;
				output.tangentOS = input.tangentOS;
				output.ase_color = input.ase_color;
				output.ase_texcoord = input.ase_texcoord;
				output.ase_texcoord1 = input.ase_texcoord1;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.tangentOS = patch[0].tangentOS * bary.x + patch[1].tangentOS * bary.y + patch[2].tangentOS * bary.z;
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				output.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				output.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].positionOS.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			half4 frag(	PackedVaryings input
						#if defined( ASE_WRITE_DEPTH )
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( input );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input );

				#if defined(MAIN_LIGHT_CALCULATE_SHADOWS) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
				#else
					float4 shadowCoord = float4(0, 0, 0, 0);
				#endif

				float3 PositionWS = input.positionWS;
				float3 PositionRWS = GetCameraRelativePositionWS( input.positionWS );
				float4 ShadowCoord = shadowCoord;
				float4 ScreenPosNorm = float4( GetNormalizedScreenSpaceUV( input.positionCS ), input.positionCS.zw );
				float4 ClipPos = ComputeClipSpacePosition( ScreenPosNorm.xy, input.positionCS.z ) * input.positionCS.w;
				float4 ScreenPos = ComputeScreenPos( ClipPos );

				float localComputeMotionFlow451 = ( 0.0 );
				float4 appendResult423 = (float4(input.ase_texcoord1.x , input.ase_texcoord1.y , 0.0 , 0.0));
				float4 ShurikenCurrentFrame431 = appendResult423;
				float2 currentFrameUV451 = ShurikenCurrentFrame431.xy;
				float ShurikenFrameIndex424 = input.ase_texcoord1.w;
				float FlipbookSize421 = ( _Columns * _Rows );
				float4 appendResult428 = (float4(input.ase_texcoord2.x , input.ase_texcoord2.y , 0.0 , 0.0));
				float4 ifLocalVar432 = 0;
				if( ShurikenFrameIndex424 >= ( FlipbookSize421 - 1.0 ) )
				ifLocalVar432 = ShurikenCurrentFrame431;
				else
				ifLocalVar432 = appendResult428;
				float4 ShurikenNextFrame435 = ifLocalVar432;
				float2 nextFrameUV451 = ShurikenNextFrame435.xy;
				float4 currentMV451 = tex2D( _MotionVectors, ShurikenCurrentFrame431.xy );
				float4 tex2DNode438 = tex2D( _MotionVectors, ShurikenNextFrame435.xy );
				float2 appendResult445 = (float2(tex2DNode438.r , tex2DNode438.g));
				float2 nextMV451 = appendResult445;
				float isIntensityEncoded451 = _EncodedMotionIntensity;
				float motionIntensity451 = _MotionIntensity;
				float columns451 = _Columns;
				float rows451 = _Rows;
				float ShurikenBlendFactor440 = input.ase_texcoord1.z;
				float blendFactor451 = ShurikenBlendFactor440;
				float2 currentFrameMVUV451 = float2( 0,0 );
				float2 nextFrameMVUV451 = float2( 0,0 );
				ComputeMotionFlow_float( currentFrameUV451 , nextFrameUV451 , currentMV451 , nextMV451 , isIntensityEncoded451 , motionIntensity451 , columns451 , rows451 , blendFactor451 , currentFrameMVUV451 , nextFrameMVUV451 );
				float4 lerpResult455 = lerp( tex2D( _AOAlpha1, currentFrameMVUV451 ) , tex2D( _AOAlpha1, nextFrameMVUV451 ) , ShurikenBlendFactor440);
				float4 TextureAlpha457 = lerpResult455;
				float4 break462 = TextureAlpha457;
				float2 texCoord459 = input.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult456 = (float2(_Columns , _Rows));
				float2 Flipbook_Tile458 = appendResult456;
				float smoothstepResult471 = smoothstep( _OpacityCutoutEro , ( _OpacityCutoutEro + _OpacityCutoutSmoothness ) , tex2D( _OpacityCutout, ( texCoord459 * Flipbook_Tile458 ) ).g);
				float temp_output_231_0 = saturate( saturate( ( saturate( ( input.ase_color.a * break462.a ) ) * smoothstepResult471 ) ) );
				float3 normalizeResult244 = normalize( ( _WorldSpaceCameraPos - PositionWS ) );
				float dotResult249 = dot( input.ase_normal , normalizeResult244 );
				float lerpResult254 = lerp( _SideFadeMin , _SideFadeMax , saturate( ( ( 1.0 - abs( dotResult249 ) ) * _SideFadeMultiply ) ));
				float lerpResult236 = lerp( temp_output_231_0 , saturate( ( temp_output_231_0 * saturate( ( 1.0 - saturate( lerpResult254 ) ) ) ) ) , _UseSideFade);
				float eyeDepth = input.ase_texcoord3.x;
				float cameraDepthFade206 = (( eyeDepth -_ProjectionParams.y - _CamDepthFadeOffset ) / _CamDepthFadeLength);
				float camFade208 = saturate( cameraDepthFade206 );
				float screenDepth474 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ScreenPosNorm.xy ),_ZBufferParams);
				float distanceDepth474 = saturate( ( screenDepth474 - LinearEyeDepth( ScreenPosNorm.z,_ZBufferParams ) ) / ( _DepthFade ) );
				

				float Alpha = saturate( ( saturate( ( saturate( lerpResult236 ) * camFade208 ) ) * distanceDepth474 ) );
				#if defined( _ALPHATEST_ON )
					float AlphaClipThreshold = _Cutoff;
					float AlphaClipThresholdShadow = 0.5;
				#endif

				#if defined( ASE_WRITE_DEPTH )
					input.positionCS.z = input.positionCS.z;
				#endif

				#if defined( _ALPHATEST_ON )
					#if defined( _ALPHATEST_SHADOW_ON )
						AlphaDiscard( Alpha, AlphaClipThresholdShadow );
					#else
						AlphaDiscard( Alpha, AlphaClipThreshold );
					#endif
				#endif

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				#if defined( ASE_WRITE_DEPTH )
					outputDepth = input.positionCS.z;
				#endif

				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM

			

			#define ASE_GEOMETRY
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			#define ASE_FOG 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _SPECULAR_SETUP 1
			#define _EMISSION
			#define ASE_VERSION 19912
			#define ASE_SRP_VERSION 140007
			#define REQUIRE_DEPTH_TEXTURE 1


			

			#pragma vertex vert
			#pragma fragment frag

			#if defined( _SPECULAR_SETUP ) && defined( ASE_LIGHTING_SIMPLE )
				#if defined( _SPECULARHIGHLIGHTS_OFF )
					#undef _SPECULAR_COLOR
				#else
					#define _SPECULAR_COLOR
				#endif
			#endif

			#define SHADERPASS SHADERPASS_DEPTHONLY

			
            #if ASE_SRP_VERSION >=140007
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#endif
		

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"

			

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#include "../../../Shared/Shaders/MotionVectorFrameBlending.hlsl"
			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES1
			#define ASE_NEEDS_WORLD_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_SCREEN_POSITION_NORMALIZED


			#if defined(ASE_WRITE_DEPTH_CONSERVATIVE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float3 positionWS : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Color02;
			float4 _Color01;
			float _Cull1;
			float _CamDepthFadeLength;
			float _UseSideFade;
			float _SideFadeMultiply;
			float _SideFadeMax;
			float _SideFadeMin;
			float _OpacityCutoutSmoothness;
			float _OpacityCutoutEro;
			float _Emission;
			float _Smoothness;
			float _Specular;
			float _LightContribution;
			float _CamDepthFadeOffset;
			float _HorizontalFlip;
			float _MotionIntensity;
			float _EncodedMotionIntensity;
			float _Rows;
			float _Columns;
			float _ZWrite1;
			float _ZTest1;
			float _Dst1;
			float _Src1;
			float _LitBySun;
			float _DepthFade;
			float _AlphaClip;
			float _Cutoff;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _AOAlpha1;
			sampler2D _MotionVectors;
			sampler2D _OpacityCutout;


			
			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float3 objectToViewPos = TransformWorldToView( TransformObjectToWorld( input.positionOS.xyz ) );
				float eyeDepth = -objectToViewPos.z;
				output.ase_texcoord3.x = eyeDepth;
				
				output.ase_color = input.ase_color;
				output.ase_texcoord1 = input.ase_texcoord;
				output.ase_texcoord2 = input.ase_texcoord1;
				output.ase_normal = input.normalOS;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord3.yzw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;
				input.tangentOS = input.tangentOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );

				output.positionCS = ASE_ADJUST_CLIP_POSITION( vertexInput.positionCS );
				output.positionWS = vertexInput.positionWS;
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.positionOS = input.positionOS;
				output.normalOS = input.normalOS;
				output.tangentOS = input.tangentOS;
				output.ase_color = input.ase_color;
				output.ase_texcoord = input.ase_texcoord;
				output.ase_texcoord1 = input.ase_texcoord1;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.tangentOS = patch[0].tangentOS * bary.x + patch[1].tangentOS * bary.y + patch[2].tangentOS * bary.z;
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				output.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				output.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].positionOS.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			half4 frag(	PackedVaryings input
						#if defined( ASE_WRITE_DEPTH )
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input );

				#if defined(MAIN_LIGHT_CALCULATE_SHADOWS) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
				#else
					float4 shadowCoord = float4(0, 0, 0, 0);
				#endif

				float3 PositionWS = input.positionWS;
				float3 PositionRWS = GetCameraRelativePositionWS( input.positionWS );
				float4 ShadowCoord = shadowCoord;
				float4 ScreenPosNorm = float4( GetNormalizedScreenSpaceUV( input.positionCS ), input.positionCS.zw );
				float4 ClipPos = ComputeClipSpacePosition( ScreenPosNorm.xy, input.positionCS.z ) * input.positionCS.w;
				float4 ScreenPos = ComputeScreenPos( ClipPos );

				float localComputeMotionFlow451 = ( 0.0 );
				float4 appendResult423 = (float4(input.ase_texcoord1.x , input.ase_texcoord1.y , 0.0 , 0.0));
				float4 ShurikenCurrentFrame431 = appendResult423;
				float2 currentFrameUV451 = ShurikenCurrentFrame431.xy;
				float ShurikenFrameIndex424 = input.ase_texcoord1.w;
				float FlipbookSize421 = ( _Columns * _Rows );
				float4 appendResult428 = (float4(input.ase_texcoord2.x , input.ase_texcoord2.y , 0.0 , 0.0));
				float4 ifLocalVar432 = 0;
				if( ShurikenFrameIndex424 >= ( FlipbookSize421 - 1.0 ) )
				ifLocalVar432 = ShurikenCurrentFrame431;
				else
				ifLocalVar432 = appendResult428;
				float4 ShurikenNextFrame435 = ifLocalVar432;
				float2 nextFrameUV451 = ShurikenNextFrame435.xy;
				float4 currentMV451 = tex2D( _MotionVectors, ShurikenCurrentFrame431.xy );
				float4 tex2DNode438 = tex2D( _MotionVectors, ShurikenNextFrame435.xy );
				float2 appendResult445 = (float2(tex2DNode438.r , tex2DNode438.g));
				float2 nextMV451 = appendResult445;
				float isIntensityEncoded451 = _EncodedMotionIntensity;
				float motionIntensity451 = _MotionIntensity;
				float columns451 = _Columns;
				float rows451 = _Rows;
				float ShurikenBlendFactor440 = input.ase_texcoord1.z;
				float blendFactor451 = ShurikenBlendFactor440;
				float2 currentFrameMVUV451 = float2( 0,0 );
				float2 nextFrameMVUV451 = float2( 0,0 );
				ComputeMotionFlow_float( currentFrameUV451 , nextFrameUV451 , currentMV451 , nextMV451 , isIntensityEncoded451 , motionIntensity451 , columns451 , rows451 , blendFactor451 , currentFrameMVUV451 , nextFrameMVUV451 );
				float4 lerpResult455 = lerp( tex2D( _AOAlpha1, currentFrameMVUV451 ) , tex2D( _AOAlpha1, nextFrameMVUV451 ) , ShurikenBlendFactor440);
				float4 TextureAlpha457 = lerpResult455;
				float4 break462 = TextureAlpha457;
				float2 texCoord459 = input.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult456 = (float2(_Columns , _Rows));
				float2 Flipbook_Tile458 = appendResult456;
				float smoothstepResult471 = smoothstep( _OpacityCutoutEro , ( _OpacityCutoutEro + _OpacityCutoutSmoothness ) , tex2D( _OpacityCutout, ( texCoord459 * Flipbook_Tile458 ) ).g);
				float temp_output_231_0 = saturate( saturate( ( saturate( ( input.ase_color.a * break462.a ) ) * smoothstepResult471 ) ) );
				float3 normalizeResult244 = normalize( ( _WorldSpaceCameraPos - PositionWS ) );
				float dotResult249 = dot( input.ase_normal , normalizeResult244 );
				float lerpResult254 = lerp( _SideFadeMin , _SideFadeMax , saturate( ( ( 1.0 - abs( dotResult249 ) ) * _SideFadeMultiply ) ));
				float lerpResult236 = lerp( temp_output_231_0 , saturate( ( temp_output_231_0 * saturate( ( 1.0 - saturate( lerpResult254 ) ) ) ) ) , _UseSideFade);
				float eyeDepth = input.ase_texcoord3.x;
				float cameraDepthFade206 = (( eyeDepth -_ProjectionParams.y - _CamDepthFadeOffset ) / _CamDepthFadeLength);
				float camFade208 = saturate( cameraDepthFade206 );
				float screenDepth474 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ScreenPosNorm.xy ),_ZBufferParams);
				float distanceDepth474 = saturate( ( screenDepth474 - LinearEyeDepth( ScreenPosNorm.z,_ZBufferParams ) ) / ( _DepthFade ) );
				

				float Alpha = saturate( ( saturate( ( saturate( lerpResult236 ) * camFade208 ) ) * distanceDepth474 ) );
				#if defined( _ALPHATEST_ON )
					float AlphaClipThreshold = _Cutoff;
				#endif

				#if defined( ASE_WRITE_DEPTH )
					input.positionCS.z = input.positionCS.z;
				#endif

				#if defined( _ALPHATEST_ON )
					AlphaDiscard( Alpha, AlphaClipThreshold );
				#endif

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				#if defined( ASE_WRITE_DEPTH )
					outputDepth = input.positionCS.z;
				#endif

				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Meta"
			Tags { "LightMode"="Meta" }

			Cull Off

			HLSLPROGRAM
			#define ASE_GEOMETRY
			#define _NORMAL_DROPOFF_TS 1
			#define ASE_FOG 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _SPECULAR_SETUP 1
			#define _EMISSION
			#define ASE_VERSION 19912
			#define ASE_SRP_VERSION 140007
			#define REQUIRE_DEPTH_TEXTURE 1

			#pragma shader_feature EDITOR_VISUALIZATION

			#pragma vertex vert
			#pragma fragment frag

			#if defined( _SPECULAR_SETUP ) && defined( ASE_LIGHTING_SIMPLE )
				#if defined( _SPECULARHIGHLIGHTS_OFF )
					#undef _SPECULAR_COLOR
				#else
					#define _SPECULAR_COLOR
				#endif
			#endif

			#define SHADERPASS SHADERPASS_META

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"

			

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "../../../Shared/Shaders/MotionVectorFrameBlending.hlsl"
			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES1
			#define ASE_NEEDS_VERT_TANGENT
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_WORLD_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_POSITION


			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float3 positionWS : TEXCOORD0;
				#ifdef EDITOR_VISUALIZATION
					float4 VizUV : TEXCOORD1;
					float4 LightCoord : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_texcoord7 : TEXCOORD7;
				float4 ase_color : COLOR;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord8 : TEXCOORD8;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Color02;
			float4 _Color01;
			float _Cull1;
			float _CamDepthFadeLength;
			float _UseSideFade;
			float _SideFadeMultiply;
			float _SideFadeMax;
			float _SideFadeMin;
			float _OpacityCutoutSmoothness;
			float _OpacityCutoutEro;
			float _Emission;
			float _Smoothness;
			float _Specular;
			float _LightContribution;
			float _CamDepthFadeOffset;
			float _HorizontalFlip;
			float _MotionIntensity;
			float _EncodedMotionIntensity;
			float _Rows;
			float _Columns;
			float _ZWrite1;
			float _ZTest1;
			float _Dst1;
			float _Src1;
			float _LitBySun;
			float _DepthFade;
			float _AlphaClip;
			float _Cutoff;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _AOAlpha1;
			sampler2D _MotionVectors;
			sampler2D _MDC;
			sampler2D _OpacityCutout;


			
			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float3 ase_tangentWS = TransformObjectToWorldDir( input.tangentOS.xyz );
				output.ase_texcoord5.xyz = ase_tangentWS;
				float3 ase_normalWS = TransformObjectToWorldNormal( input.normalOS );
				output.ase_texcoord6.xyz = ase_normalWS;
				float ase_tangentSign = input.tangentOS.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_bitangentWS = cross( ase_normalWS, ase_tangentWS ) * ase_tangentSign;
				output.ase_texcoord7.xyz = ase_bitangentWS;
				
				float3 objectToViewPos = TransformWorldToView( TransformObjectToWorld( input.positionOS.xyz ) );
				float eyeDepth = -objectToViewPos.z;
				output.ase_texcoord5.w = eyeDepth;
				float4 ase_positionCS = TransformObjectToHClip( ( input.positionOS ).xyz );
				float4 screenPos = ComputeScreenPos( ase_positionCS );
				output.ase_texcoord8 = screenPos;
				
				output.ase_texcoord3 = input.texcoord;
				output.ase_texcoord4 = input.texcoord1;
				output.ase_color = input.ase_color;
				output.ase_normal = input.normalOS;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord6.w = 0;
				output.ase_texcoord7.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;
				input.tangentOS = input.tangentOS;

				#ifdef EDITOR_VISUALIZATION
					float2 VizUV = 0;
					float4 LightCoord = 0;
					UnityEditorVizData(input.positionOS.xyz, input.texcoord.xy, input.texcoord1.xy, input.texcoord2.xy, VizUV, LightCoord);
					output.VizUV = float4(VizUV, 0, 0);
					output.LightCoord = LightCoord;
				#endif

				output.positionCS = MetaVertexPosition( input.positionOS, input.texcoord1.xy, input.texcoord1.xy, unity_LightmapST, unity_DynamicLightmapST );
				output.positionWS = TransformObjectToWorld( input.positionOS.xyz );
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.positionOS = input.positionOS;
				output.normalOS = input.normalOS;
				output.tangentOS = input.tangentOS;
				output.texcoord = input.texcoord;
				output.texcoord1 = input.texcoord1;
				output.texcoord2 = input.texcoord2;
				output.ase_color = input.ase_color;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.tangentOS = patch[0].tangentOS * bary.x + patch[1].tangentOS * bary.y + patch[2].tangentOS * bary.z;
				output.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
				output.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				output.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].positionOS.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			half4 frag(PackedVaryings input  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input );

				#if defined(MAIN_LIGHT_CALCULATE_SHADOWS) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
				#else
					float4 shadowCoord = float4(0, 0, 0, 0);
				#endif

				float3 PositionWS = input.positionWS;
				float3 PositionRWS = GetCameraRelativePositionWS( input.positionWS );
				float4 ShadowCoord = shadowCoord;

				float localComputeMotionFlow451 = ( 0.0 );
				float4 appendResult423 = (float4(input.ase_texcoord3.x , input.ase_texcoord3.y , 0.0 , 0.0));
				float4 ShurikenCurrentFrame431 = appendResult423;
				float2 currentFrameUV451 = ShurikenCurrentFrame431.xy;
				float ShurikenFrameIndex424 = input.ase_texcoord3.w;
				float FlipbookSize421 = ( _Columns * _Rows );
				float4 appendResult428 = (float4(input.ase_texcoord4.x , input.ase_texcoord4.y , 0.0 , 0.0));
				float4 ifLocalVar432 = 0;
				if( ShurikenFrameIndex424 >= ( FlipbookSize421 - 1.0 ) )
				ifLocalVar432 = ShurikenCurrentFrame431;
				else
				ifLocalVar432 = appendResult428;
				float4 ShurikenNextFrame435 = ifLocalVar432;
				float2 nextFrameUV451 = ShurikenNextFrame435.xy;
				float4 currentMV451 = tex2D( _MotionVectors, ShurikenCurrentFrame431.xy );
				float4 tex2DNode438 = tex2D( _MotionVectors, ShurikenNextFrame435.xy );
				float2 appendResult445 = (float2(tex2DNode438.r , tex2DNode438.g));
				float2 nextMV451 = appendResult445;
				float isIntensityEncoded451 = _EncodedMotionIntensity;
				float motionIntensity451 = _MotionIntensity;
				float columns451 = _Columns;
				float rows451 = _Rows;
				float ShurikenBlendFactor440 = input.ase_texcoord3.z;
				float blendFactor451 = ShurikenBlendFactor440;
				float2 currentFrameMVUV451 = float2( 0,0 );
				float2 nextFrameMVUV451 = float2( 0,0 );
				ComputeMotionFlow_float( currentFrameUV451 , nextFrameUV451 , currentMV451 , nextMV451 , isIntensityEncoded451 , motionIntensity451 , columns451 , rows451 , blendFactor451 , currentFrameMVUV451 , nextFrameMVUV451 );
				float4 lerpResult455 = lerp( tex2D( _AOAlpha1, currentFrameMVUV451 ) , tex2D( _AOAlpha1, nextFrameMVUV451 ) , ShurikenBlendFactor440);
				float4 TextureAlpha457 = lerpResult455;
				float4 break462 = TextureAlpha457;
				float3 ase_tangentWS = input.ase_texcoord5.xyz;
				float3 ase_normalWS = input.ase_texcoord6.xyz;
				float3 ase_bitangentWS = input.ase_texcoord7.xyz;
				float3x3 ase_worldToTangent = float3x3( ase_tangentWS, ase_bitangentWS, ase_normalWS );
				float3 worldToTangentDir518 = normalize( mul( ase_worldToTangent, SafeNormalize( _MainLightPosition.xyz ) ) );
				float3 break499 = worldToTangentDir518;
				float4 lerpResult545 = lerp( tex2D( _MDC, currentFrameMVUV451 ) , tex2D( _MDC, nextFrameMVUV451 ) , ShurikenBlendFactor440);
				float4 TextureColor547 = lerpResult545;
				float4 break536 = TextureColor547;
				float ifLocalVar542 = 0;
				if( _HorizontalFlip > 0.0 )
				ifLocalVar542 = break536.r;
				else if( _HorizontalFlip < 0.0 )
				ifLocalVar542 = break536.g;
				float left541 = ifLocalVar542;
				float ifLocalVar543 = 0;
				if( _HorizontalFlip > 0.0 )
				ifLocalVar543 = break536.g;
				else if( _HorizontalFlip < 0.0 )
				ifLocalVar543 = break536.r;
				float right538 = ifLocalVar543;
				float ifLocalVar505 = 0;
				if( break499.x > 0.0 )
				ifLocalVar505 = left541;
				else if( break499.x < 0.0 )
				ifLocalVar505 = right538;
				float top540 = break536.b;
				float bottom539 = break536.a;
				float ifLocalVar508 = 0;
				if( break499.y > 0.0 )
				ifLocalVar508 = top540;
				else if( break499.y < 0.0 )
				ifLocalVar508 = bottom539;
				float saferPower530 = abs( ( ( ( right538 + left541 ) + ( top540 + bottom539 ) ) / 4.0 ) );
				float front529 = pow( saferPower530 , 0.625 );
				float temp_output_525_0 = ( front529 * front529 );
				float temp_output_521_0 = ( temp_output_525_0 * temp_output_525_0 );
				float temp_output_522_0 = ( temp_output_521_0 * temp_output_521_0 );
				float back519 = ( ( ( temp_output_522_0 * temp_output_522_0 ) / 2.0 ) + saturate( ( ( 1.0 - front529 ) / 4.0 ) ) );
				float ifLocalVar513 = 0;
				if( break499.z > 0.0 )
				ifLocalVar513 = front529;
				else if( break499.z < 0.0 )
				ifLocalVar513 = back519;
				float lightmap504 = ( ( ( ( break499.x * break499.x ) * ifLocalVar505 ) + ( ( break499.y * break499.y ) * ifLocalVar508 ) ) + ( ( break499.z * break499.z ) * ifLocalVar513 ) );
				float lerpResult488 = lerp( 1.0 , lightmap504 , saturate( _LightContribution ));
				float lerpResult490 = lerp( break462.g , lerpResult488 , saturate( _LitBySun ));
				float3 lerpResult483 = lerp( _Color01.rgb , _Color02.rgb , lerpResult490);
				float3 lerpResult482 = lerp( _Color02.rgb , lerpResult483 , break462.a);
				float4 temp_output_486_0 = ( float4( lerpResult482 , 0.0 ) * input.ase_color );
				
				float2 texCoord459 = input.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult456 = (float2(_Columns , _Rows));
				float2 Flipbook_Tile458 = appendResult456;
				float smoothstepResult471 = smoothstep( _OpacityCutoutEro , ( _OpacityCutoutEro + _OpacityCutoutSmoothness ) , tex2D( _OpacityCutout, ( texCoord459 * Flipbook_Tile458 ) ).g);
				float temp_output_231_0 = saturate( saturate( ( saturate( ( input.ase_color.a * break462.a ) ) * smoothstepResult471 ) ) );
				float3 normalizeResult244 = normalize( ( _WorldSpaceCameraPos - PositionWS ) );
				float dotResult249 = dot( input.ase_normal , normalizeResult244 );
				float lerpResult254 = lerp( _SideFadeMin , _SideFadeMax , saturate( ( ( 1.0 - abs( dotResult249 ) ) * _SideFadeMultiply ) ));
				float lerpResult236 = lerp( temp_output_231_0 , saturate( ( temp_output_231_0 * saturate( ( 1.0 - saturate( lerpResult254 ) ) ) ) ) , _UseSideFade);
				float eyeDepth = input.ase_texcoord5.w;
				float cameraDepthFade206 = (( eyeDepth -_ProjectionParams.y - _CamDepthFadeOffset ) / _CamDepthFadeLength);
				float camFade208 = saturate( cameraDepthFade206 );
				float4 screenPos = input.ase_texcoord8;
				float4 ase_positionSSNorm = screenPos / screenPos.w;
				ase_positionSSNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_positionSSNorm.z : ase_positionSSNorm.z * 0.5 + 0.5;
				float screenDepth474 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_positionSSNorm.xy ),_ZBufferParams);
				float distanceDepth474 = saturate( ( screenDepth474 - LinearEyeDepth( ase_positionSSNorm.z,_ZBufferParams ) ) / ( _DepthFade ) );
				

				float3 BaseColor = temp_output_486_0.rgb;
				float3 Emission = ( temp_output_486_0 * _Emission ).rgb;
				float Alpha = saturate( ( saturate( ( saturate( lerpResult236 ) * camFade208 ) ) * distanceDepth474 ) );
				#if defined( _ALPHATEST_ON )
					float AlphaClipThreshold = _Cutoff;
				#endif

				#if defined( _ALPHATEST_ON )
					AlphaDiscard( Alpha, AlphaClipThreshold );
				#endif

				MetaInput metaInput = (MetaInput)0;
				metaInput.Albedo = BaseColor;
				metaInput.Emission = Emission;
				#ifdef EDITOR_VISUALIZATION
					metaInput.VizUV = input.VizUV.xy;
					metaInput.LightCoord = input.LightCoord;
				#endif

				return UnityMetaFragment(metaInput);
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Universal2D"
			Tags { "LightMode"="Universal2D" }

			Blend [_Src1] [_Dst1], SrcAlpha OneMinusSrcAlpha
			ZWrite [_ZWrite1]
			ZTest [_ZTest1]
			Offset 0 , 0
			ColorMask RGBA

			HLSLPROGRAM

			#define ASE_GEOMETRY
			#define _NORMAL_DROPOFF_TS 1
			#define ASE_FOG 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _SPECULAR_SETUP 1
			#define _EMISSION
			#define ASE_VERSION 19912
			#define ASE_SRP_VERSION 140007
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma vertex vert
			#pragma fragment frag

			#if defined( _SPECULAR_SETUP ) && defined( ASE_LIGHTING_SIMPLE )
				#if defined( _SPECULARHIGHLIGHTS_OFF )
					#undef _SPECULAR_COLOR
				#else
					#define _SPECULAR_COLOR
				#endif
			#endif

			#define SHADERPASS SHADERPASS_2D

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"

			

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "../../../Shared/Shaders/MotionVectorFrameBlending.hlsl"
			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES1
			#define ASE_NEEDS_VERT_TANGENT
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_WORLD_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_POSITION


			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				float3 positionWS : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_color : COLOR;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Color02;
			float4 _Color01;
			float _Cull1;
			float _CamDepthFadeLength;
			float _UseSideFade;
			float _SideFadeMultiply;
			float _SideFadeMax;
			float _SideFadeMin;
			float _OpacityCutoutSmoothness;
			float _OpacityCutoutEro;
			float _Emission;
			float _Smoothness;
			float _Specular;
			float _LightContribution;
			float _CamDepthFadeOffset;
			float _HorizontalFlip;
			float _MotionIntensity;
			float _EncodedMotionIntensity;
			float _Rows;
			float _Columns;
			float _ZWrite1;
			float _ZTest1;
			float _Dst1;
			float _Src1;
			float _LitBySun;
			float _DepthFade;
			float _AlphaClip;
			float _Cutoff;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _AOAlpha1;
			sampler2D _MotionVectors;
			sampler2D _MDC;
			sampler2D _OpacityCutout;


			
			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float3 ase_tangentWS = TransformObjectToWorldDir( input.tangentOS.xyz );
				output.ase_texcoord3.xyz = ase_tangentWS;
				float3 ase_normalWS = TransformObjectToWorldNormal( input.normalOS );
				output.ase_texcoord4.xyz = ase_normalWS;
				float ase_tangentSign = input.tangentOS.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_bitangentWS = cross( ase_normalWS, ase_tangentWS ) * ase_tangentSign;
				output.ase_texcoord5.xyz = ase_bitangentWS;
				
				float3 objectToViewPos = TransformWorldToView( TransformObjectToWorld( input.positionOS.xyz ) );
				float eyeDepth = -objectToViewPos.z;
				output.ase_texcoord3.w = eyeDepth;
				float4 ase_positionCS = TransformObjectToHClip( ( input.positionOS ).xyz );
				float4 screenPos = ComputeScreenPos( ase_positionCS );
				output.ase_texcoord6 = screenPos;
				
				output.ase_texcoord1 = input.ase_texcoord;
				output.ase_texcoord2 = input.ase_texcoord1;
				output.ase_color = input.ase_color;
				output.ase_normal = input.normalOS;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord4.w = 0;
				output.ase_texcoord5.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;
				input.tangentOS = input.tangentOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );

				output.positionCS = vertexInput.positionCS;
				output.positionWS = vertexInput.positionWS;
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.positionOS = input.positionOS;
				output.normalOS = input.normalOS;
				output.tangentOS = input.tangentOS;
				output.ase_texcoord = input.ase_texcoord;
				output.ase_texcoord1 = input.ase_texcoord1;
				output.ase_color = input.ase_color;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.tangentOS = patch[0].tangentOS * bary.x + patch[1].tangentOS * bary.y + patch[2].tangentOS * bary.z;
				output.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				output.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].positionOS.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			half4 frag(PackedVaryings input  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( input );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input );

				#if defined(MAIN_LIGHT_CALCULATE_SHADOWS) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
				#else
					float4 shadowCoord = float4(0, 0, 0, 0);
				#endif

				float3 PositionWS = input.positionWS;
				float3 PositionRWS = GetCameraRelativePositionWS( input.positionWS );
				float4 ShadowCoord = shadowCoord;

				float localComputeMotionFlow451 = ( 0.0 );
				float4 appendResult423 = (float4(input.ase_texcoord1.x , input.ase_texcoord1.y , 0.0 , 0.0));
				float4 ShurikenCurrentFrame431 = appendResult423;
				float2 currentFrameUV451 = ShurikenCurrentFrame431.xy;
				float ShurikenFrameIndex424 = input.ase_texcoord1.w;
				float FlipbookSize421 = ( _Columns * _Rows );
				float4 appendResult428 = (float4(input.ase_texcoord2.x , input.ase_texcoord2.y , 0.0 , 0.0));
				float4 ifLocalVar432 = 0;
				if( ShurikenFrameIndex424 >= ( FlipbookSize421 - 1.0 ) )
				ifLocalVar432 = ShurikenCurrentFrame431;
				else
				ifLocalVar432 = appendResult428;
				float4 ShurikenNextFrame435 = ifLocalVar432;
				float2 nextFrameUV451 = ShurikenNextFrame435.xy;
				float4 currentMV451 = tex2D( _MotionVectors, ShurikenCurrentFrame431.xy );
				float4 tex2DNode438 = tex2D( _MotionVectors, ShurikenNextFrame435.xy );
				float2 appendResult445 = (float2(tex2DNode438.r , tex2DNode438.g));
				float2 nextMV451 = appendResult445;
				float isIntensityEncoded451 = _EncodedMotionIntensity;
				float motionIntensity451 = _MotionIntensity;
				float columns451 = _Columns;
				float rows451 = _Rows;
				float ShurikenBlendFactor440 = input.ase_texcoord1.z;
				float blendFactor451 = ShurikenBlendFactor440;
				float2 currentFrameMVUV451 = float2( 0,0 );
				float2 nextFrameMVUV451 = float2( 0,0 );
				ComputeMotionFlow_float( currentFrameUV451 , nextFrameUV451 , currentMV451 , nextMV451 , isIntensityEncoded451 , motionIntensity451 , columns451 , rows451 , blendFactor451 , currentFrameMVUV451 , nextFrameMVUV451 );
				float4 lerpResult455 = lerp( tex2D( _AOAlpha1, currentFrameMVUV451 ) , tex2D( _AOAlpha1, nextFrameMVUV451 ) , ShurikenBlendFactor440);
				float4 TextureAlpha457 = lerpResult455;
				float4 break462 = TextureAlpha457;
				float3 ase_tangentWS = input.ase_texcoord3.xyz;
				float3 ase_normalWS = input.ase_texcoord4.xyz;
				float3 ase_bitangentWS = input.ase_texcoord5.xyz;
				float3x3 ase_worldToTangent = float3x3( ase_tangentWS, ase_bitangentWS, ase_normalWS );
				float3 worldToTangentDir518 = normalize( mul( ase_worldToTangent, SafeNormalize( _MainLightPosition.xyz ) ) );
				float3 break499 = worldToTangentDir518;
				float4 lerpResult545 = lerp( tex2D( _MDC, currentFrameMVUV451 ) , tex2D( _MDC, nextFrameMVUV451 ) , ShurikenBlendFactor440);
				float4 TextureColor547 = lerpResult545;
				float4 break536 = TextureColor547;
				float ifLocalVar542 = 0;
				if( _HorizontalFlip > 0.0 )
				ifLocalVar542 = break536.r;
				else if( _HorizontalFlip < 0.0 )
				ifLocalVar542 = break536.g;
				float left541 = ifLocalVar542;
				float ifLocalVar543 = 0;
				if( _HorizontalFlip > 0.0 )
				ifLocalVar543 = break536.g;
				else if( _HorizontalFlip < 0.0 )
				ifLocalVar543 = break536.r;
				float right538 = ifLocalVar543;
				float ifLocalVar505 = 0;
				if( break499.x > 0.0 )
				ifLocalVar505 = left541;
				else if( break499.x < 0.0 )
				ifLocalVar505 = right538;
				float top540 = break536.b;
				float bottom539 = break536.a;
				float ifLocalVar508 = 0;
				if( break499.y > 0.0 )
				ifLocalVar508 = top540;
				else if( break499.y < 0.0 )
				ifLocalVar508 = bottom539;
				float saferPower530 = abs( ( ( ( right538 + left541 ) + ( top540 + bottom539 ) ) / 4.0 ) );
				float front529 = pow( saferPower530 , 0.625 );
				float temp_output_525_0 = ( front529 * front529 );
				float temp_output_521_0 = ( temp_output_525_0 * temp_output_525_0 );
				float temp_output_522_0 = ( temp_output_521_0 * temp_output_521_0 );
				float back519 = ( ( ( temp_output_522_0 * temp_output_522_0 ) / 2.0 ) + saturate( ( ( 1.0 - front529 ) / 4.0 ) ) );
				float ifLocalVar513 = 0;
				if( break499.z > 0.0 )
				ifLocalVar513 = front529;
				else if( break499.z < 0.0 )
				ifLocalVar513 = back519;
				float lightmap504 = ( ( ( ( break499.x * break499.x ) * ifLocalVar505 ) + ( ( break499.y * break499.y ) * ifLocalVar508 ) ) + ( ( break499.z * break499.z ) * ifLocalVar513 ) );
				float lerpResult488 = lerp( 1.0 , lightmap504 , saturate( _LightContribution ));
				float lerpResult490 = lerp( break462.g , lerpResult488 , saturate( _LitBySun ));
				float3 lerpResult483 = lerp( _Color01.rgb , _Color02.rgb , lerpResult490);
				float3 lerpResult482 = lerp( _Color02.rgb , lerpResult483 , break462.a);
				float4 temp_output_486_0 = ( float4( lerpResult482 , 0.0 ) * input.ase_color );
				
				float2 texCoord459 = input.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult456 = (float2(_Columns , _Rows));
				float2 Flipbook_Tile458 = appendResult456;
				float smoothstepResult471 = smoothstep( _OpacityCutoutEro , ( _OpacityCutoutEro + _OpacityCutoutSmoothness ) , tex2D( _OpacityCutout, ( texCoord459 * Flipbook_Tile458 ) ).g);
				float temp_output_231_0 = saturate( saturate( ( saturate( ( input.ase_color.a * break462.a ) ) * smoothstepResult471 ) ) );
				float3 normalizeResult244 = normalize( ( _WorldSpaceCameraPos - PositionWS ) );
				float dotResult249 = dot( input.ase_normal , normalizeResult244 );
				float lerpResult254 = lerp( _SideFadeMin , _SideFadeMax , saturate( ( ( 1.0 - abs( dotResult249 ) ) * _SideFadeMultiply ) ));
				float lerpResult236 = lerp( temp_output_231_0 , saturate( ( temp_output_231_0 * saturate( ( 1.0 - saturate( lerpResult254 ) ) ) ) ) , _UseSideFade);
				float eyeDepth = input.ase_texcoord3.w;
				float cameraDepthFade206 = (( eyeDepth -_ProjectionParams.y - _CamDepthFadeOffset ) / _CamDepthFadeLength);
				float camFade208 = saturate( cameraDepthFade206 );
				float4 screenPos = input.ase_texcoord6;
				float4 ase_positionSSNorm = screenPos / screenPos.w;
				ase_positionSSNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_positionSSNorm.z : ase_positionSSNorm.z * 0.5 + 0.5;
				float screenDepth474 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_positionSSNorm.xy ),_ZBufferParams);
				float distanceDepth474 = saturate( ( screenDepth474 - LinearEyeDepth( ase_positionSSNorm.z,_ZBufferParams ) ) / ( _DepthFade ) );
				

				float3 BaseColor = temp_output_486_0.rgb;
				float Alpha = saturate( ( saturate( ( saturate( lerpResult236 ) * camFade208 ) ) * distanceDepth474 ) );
				#if defined( _ALPHATEST_ON )
					float AlphaClipThreshold = _Cutoff;
				#endif

				half4 color = half4(BaseColor, Alpha );

				#if defined( _ALPHATEST_ON )
					AlphaDiscard( Alpha, AlphaClipThreshold );
				#endif

				return color;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthNormals"
			Tags { "LightMode"="DepthNormals" }

			ZWrite On
			Blend One Zero
			ZTest LEqual
			ZWrite On

			HLSLPROGRAM

			

			

			#define ASE_GEOMETRY
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			#define ASE_FOG 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _SPECULAR_SETUP 1
			#define _EMISSION
			#define ASE_VERSION 19912
			#define ASE_SRP_VERSION 140007
			#define REQUIRE_DEPTH_TEXTURE 1


			

			

			#pragma vertex vert
			#pragma fragment frag

			#if defined( _SPECULAR_SETUP ) && defined( ASE_LIGHTING_SIMPLE )
				#if defined( _SPECULARHIGHLIGHTS_OFF )
					#undef _SPECULAR_COLOR
				#else
					#define _SPECULAR_COLOR
				#endif
			#endif

			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
			//#define SHADERPASS SHADERPASS_DEPTHNORMALS

			
            #if ASE_SRP_VERSION >=140007
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#endif
		

			
			#if ASE_SRP_VERSION >=140007
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
			#endif
		

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"

			

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#if defined( UNITY_INSTANCING_ENABLED ) && defined( ASE_INSTANCED_TERRAIN ) && ( defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL) || defined(_INSTANCEDTERRAINNORMALS_PIXEL) )
				#define ENABLE_TERRAIN_PERPIXEL_NORMAL
			#endif

			#include "../../../Shared/Shaders/MotionVectorFrameBlending.hlsl"
			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES1
			#define ASE_NEEDS_WORLD_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_SCREEN_POSITION_NORMALIZED


			#if defined(ASE_WRITE_DEPTH_CONSERVATIVE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				half4 texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float3 positionWS : TEXCOORD0;
				half3 normalWS : TEXCOORD1;
				float4 tangentWS : TEXCOORD2; // holds terrainUV ifdef ENABLE_TERRAIN_PERPIXEL_NORMAL
				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Color02;
			float4 _Color01;
			float _Cull1;
			float _CamDepthFadeLength;
			float _UseSideFade;
			float _SideFadeMultiply;
			float _SideFadeMax;
			float _SideFadeMin;
			float _OpacityCutoutSmoothness;
			float _OpacityCutoutEro;
			float _Emission;
			float _Smoothness;
			float _Specular;
			float _LightContribution;
			float _CamDepthFadeOffset;
			float _HorizontalFlip;
			float _MotionIntensity;
			float _EncodedMotionIntensity;
			float _Rows;
			float _Columns;
			float _ZWrite1;
			float _ZTest1;
			float _Dst1;
			float _Src1;
			float _LitBySun;
			float _DepthFade;
			float _AlphaClip;
			float _Cutoff;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _AOAlpha1;
			sampler2D _MotionVectors;
			sampler2D _OpacityCutout;


			
			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float3 objectToViewPos = TransformWorldToView( TransformObjectToWorld( input.positionOS.xyz ) );
				float eyeDepth = -objectToViewPos.z;
				output.ase_texcoord5.x = eyeDepth;
				
				output.ase_color = input.ase_color;
				output.ase_texcoord3 = input.texcoord;
				output.ase_texcoord4 = input.ase_texcoord1;
				output.ase_normal = input.normalOS;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord5.yzw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;
				input.tangentOS = input.tangentOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );
				VertexNormalInputs normalInput = GetVertexNormalInputs( input.normalOS, input.tangentOS );

				output.positionCS = ASE_ADJUST_CLIP_POSITION( vertexInput.positionCS );
				output.positionWS = vertexInput.positionWS;
				output.normalWS = normalInput.normalWS;
				output.tangentWS = float4( normalInput.tangentWS, ( input.tangentOS.w > 0.0 ? 1.0 : -1.0 ) * GetOddNegativeScale() );

				#if defined( ENABLE_TERRAIN_PERPIXEL_NORMAL )
					output.tangentWS.zw = input.texcoord.xy;
					output.tangentWS.xy = input.texcoord.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.positionOS = input.positionOS;
				output.normalOS = input.normalOS;
				output.tangentOS = input.tangentOS;
				output.texcoord = input.texcoord;
				output.texcoord = input.texcoord;
				output.ase_color = input.ase_color;
				output.ase_texcoord1 = input.ase_texcoord1;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.tangentOS = patch[0].tangentOS * bary.x + patch[1].tangentOS * bary.y + patch[2].tangentOS * bary.z;
				output.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
				output.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				output.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].positionOS.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			void frag(	PackedVaryings input
						, out half4 outNormalWS : SV_Target0
						#if defined( ASE_WRITE_DEPTH )
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						#ifdef _WRITE_RENDERING_LAYERS
						, out float4 outRenderingLayers : SV_Target1
						#endif
						 )
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( input );

				#if defined(MAIN_LIGHT_CALCULATE_SHADOWS) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
				#else
					float4 shadowCoord = float4(0, 0, 0, 0);
				#endif

				// @diogo: mikktspace compliant
				float renormFactor = 1.0 / max( FLT_MIN, length( input.normalWS ) );

				float3 PositionWS = input.positionWS;
				float3 PositionRWS = GetCameraRelativePositionWS( input.positionWS );
				float4 ShadowCoord = shadowCoord;
				float4 ScreenPosNorm = float4( GetNormalizedScreenSpaceUV( input.positionCS ), input.positionCS.zw );
				float4 ClipPos = ComputeClipSpacePosition( ScreenPosNorm.xy, input.positionCS.z ) * input.positionCS.w;
				float4 ScreenPos = ComputeScreenPos( ClipPos );
				float3 TangentWS = input.tangentWS.xyz * renormFactor;
				float3 BitangentWS = cross( input.normalWS, input.tangentWS.xyz ) * input.tangentWS.w * renormFactor;
				float3 NormalWS = input.normalWS * renormFactor;

				#if defined( ENABLE_TERRAIN_PERPIXEL_NORMAL )
					float2 sampleCoords = (input.tangentWS.zw / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
					NormalWS = TransformObjectToWorldNormal(normalize(SAMPLE_TEXTURE2D(_TerrainNormalmapTexture, sampler_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1));
					TangentWS = -cross(GetObjectToWorldMatrix()._13_23_33, NormalWS);
					BitangentWS = cross(NormalWS, -TangentWS);
				#endif

				float localComputeMotionFlow451 = ( 0.0 );
				float4 appendResult423 = (float4(input.ase_texcoord3.x , input.ase_texcoord3.y , 0.0 , 0.0));
				float4 ShurikenCurrentFrame431 = appendResult423;
				float2 currentFrameUV451 = ShurikenCurrentFrame431.xy;
				float ShurikenFrameIndex424 = input.ase_texcoord3.w;
				float FlipbookSize421 = ( _Columns * _Rows );
				float4 appendResult428 = (float4(input.ase_texcoord4.x , input.ase_texcoord4.y , 0.0 , 0.0));
				float4 ifLocalVar432 = 0;
				if( ShurikenFrameIndex424 >= ( FlipbookSize421 - 1.0 ) )
				ifLocalVar432 = ShurikenCurrentFrame431;
				else
				ifLocalVar432 = appendResult428;
				float4 ShurikenNextFrame435 = ifLocalVar432;
				float2 nextFrameUV451 = ShurikenNextFrame435.xy;
				float4 currentMV451 = tex2D( _MotionVectors, ShurikenCurrentFrame431.xy );
				float4 tex2DNode438 = tex2D( _MotionVectors, ShurikenNextFrame435.xy );
				float2 appendResult445 = (float2(tex2DNode438.r , tex2DNode438.g));
				float2 nextMV451 = appendResult445;
				float isIntensityEncoded451 = _EncodedMotionIntensity;
				float motionIntensity451 = _MotionIntensity;
				float columns451 = _Columns;
				float rows451 = _Rows;
				float ShurikenBlendFactor440 = input.ase_texcoord3.z;
				float blendFactor451 = ShurikenBlendFactor440;
				float2 currentFrameMVUV451 = float2( 0,0 );
				float2 nextFrameMVUV451 = float2( 0,0 );
				ComputeMotionFlow_float( currentFrameUV451 , nextFrameUV451 , currentMV451 , nextMV451 , isIntensityEncoded451 , motionIntensity451 , columns451 , rows451 , blendFactor451 , currentFrameMVUV451 , nextFrameMVUV451 );
				float4 lerpResult455 = lerp( tex2D( _AOAlpha1, currentFrameMVUV451 ) , tex2D( _AOAlpha1, nextFrameMVUV451 ) , ShurikenBlendFactor440);
				float4 TextureAlpha457 = lerpResult455;
				float4 break462 = TextureAlpha457;
				float2 texCoord459 = input.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult456 = (float2(_Columns , _Rows));
				float2 Flipbook_Tile458 = appendResult456;
				float smoothstepResult471 = smoothstep( _OpacityCutoutEro , ( _OpacityCutoutEro + _OpacityCutoutSmoothness ) , tex2D( _OpacityCutout, ( texCoord459 * Flipbook_Tile458 ) ).g);
				float temp_output_231_0 = saturate( saturate( ( saturate( ( input.ase_color.a * break462.a ) ) * smoothstepResult471 ) ) );
				float3 normalizeResult244 = normalize( ( _WorldSpaceCameraPos - PositionWS ) );
				float dotResult249 = dot( input.ase_normal , normalizeResult244 );
				float lerpResult254 = lerp( _SideFadeMin , _SideFadeMax , saturate( ( ( 1.0 - abs( dotResult249 ) ) * _SideFadeMultiply ) ));
				float lerpResult236 = lerp( temp_output_231_0 , saturate( ( temp_output_231_0 * saturate( ( 1.0 - saturate( lerpResult254 ) ) ) ) ) , _UseSideFade);
				float eyeDepth = input.ase_texcoord5.x;
				float cameraDepthFade206 = (( eyeDepth -_ProjectionParams.y - _CamDepthFadeOffset ) / _CamDepthFadeLength);
				float camFade208 = saturate( cameraDepthFade206 );
				float screenDepth474 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ScreenPosNorm.xy ),_ZBufferParams);
				float distanceDepth474 = saturate( ( screenDepth474 - LinearEyeDepth( ScreenPosNorm.z,_ZBufferParams ) ) / ( _DepthFade ) );
				

				float3 Normal = float3(0, 0, 1);
				float Alpha = saturate( ( saturate( ( saturate( lerpResult236 ) * camFade208 ) ) * distanceDepth474 ) );
				#if defined( _ALPHATEST_ON )
					float AlphaClipThreshold = _Cutoff;
				#endif

				#if defined( ASE_WRITE_DEPTH )
					input.positionCS.z = input.positionCS.z;
				#endif

				#if defined( _ALPHATEST_ON )
					AlphaDiscard( Alpha, AlphaClipThreshold );
				#endif

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				#if defined( ASE_WRITE_DEPTH )
					outputDepth = input.positionCS.z;
				#endif

				#if defined(_GBUFFER_NORMALS_OCT)
					float2 octNormalWS = PackNormalOctQuadEncode(NormalWS);
					float2 remappedOctNormalWS = saturate(octNormalWS * 0.5 + 0.5);
					half3 packedNormalWS = PackFloat2To888(remappedOctNormalWS);
					outNormalWS = half4(packedNormalWS, 0.0);
				#else
					#if defined(_NORMALMAP)
						#if _NORMAL_DROPOFF_TS
							float3 normalWS = TransformTangentToWorld(Normal, half3x3(TangentWS, BitangentWS, NormalWS));
						#elif _NORMAL_DROPOFF_OS
							float3 normalWS = TransformObjectToWorldNormal(Normal);
						#elif _NORMAL_DROPOFF_WS
							float3 normalWS = Normal;
						#endif
					#else
						float3 normalWS = NormalWS;
					#endif
					outNormalWS = half4(NormalizeNormalPerPixel(normalWS), 0.0);
				#endif

				#ifdef _WRITE_RENDERING_LAYERS
					uint renderingLayers = GetMeshRenderingLayer();
					outRenderingLayers = float4(EncodeMeshRenderingLayer(renderingLayers), 0, 0, 0);
				#endif
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "GBuffer"
			Tags { "LightMode"="UniversalGBuffer" }

			Blend [_Src1] [_Dst1], SrcAlpha OneMinusSrcAlpha
			ZWrite [_ZWrite1]
			ZTest [_ZTest1]
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM

			#define ASE_GEOMETRY
			#define _NORMAL_DROPOFF_TS 1
			#pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
			#pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
			#pragma multi_compile_instancing
			#pragma instancing_options renderinglayer
			#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _SPECULAR_SETUP 1
			#define _EMISSION
			#define ASE_VERSION 19912
			#define ASE_SRP_VERSION 140007
			#define REQUIRE_DEPTH_TEXTURE 1


			// Deferred Rendering Path does not support the OpenGL-based graphics API:
			// Desktop OpenGL, OpenGL ES 3.0, WebGL 2.0.
			#pragma exclude_renderers glcore gles3 

			

			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
			#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION

			
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
           

			

			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
			#pragma multi_compile_fragment _ _RENDER_PASS_ENABLED

			

			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DYNAMICLIGHTMAP_ON

			#pragma vertex vert
			#pragma fragment frag

			#if defined( _SPECULAR_SETUP ) && defined( ASE_LIGHTING_SIMPLE )
				#if defined( _SPECULARHIGHLIGHTS_OFF )
					#undef _SPECULAR_COLOR
				#else
					#define _SPECULAR_COLOR
				#endif
			#endif

			#define SHADERPASS SHADERPASS_GBUFFER

			
            #if ASE_SRP_VERSION >=140007
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#endif
		

			
			#if ASE_SRP_VERSION >=140007
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
			#endif
		

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"

			

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

			#if defined( UNITY_INSTANCING_ENABLED ) && defined( ASE_INSTANCED_TERRAIN ) && ( defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL) || defined(_INSTANCEDTERRAINNORMALS_PIXEL) )
				#define ENABLE_TERRAIN_PERPIXEL_NORMAL
			#endif

			#include "../../../Shared/Shaders/MotionVectorFrameBlending.hlsl"
			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES1
			#define ASE_NEEDS_WORLD_TANGENT
			#define ASE_NEEDS_FRAG_WORLD_TANGENT
			#define ASE_NEEDS_WORLD_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_BITANGENT
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_WORLD_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_SCREEN_POSITION_NORMALIZED


			#if defined(ASE_WRITE_DEPTH_CONSERVATIVE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				#if defined(LIGHTMAP_ON) || defined(ASE_NEEDS_TEXTURE_COORDINATES1)
					float4 texcoord1 : TEXCOORD1;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON) || defined(ASE_NEEDS_TEXTURE_COORDINATES2)
					float4 texcoord2 : TEXCOORD2;
				#endif
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float3 positionWS : TEXCOORD0;
				half3 normalWS : TEXCOORD1;
				float4 tangentWS : TEXCOORD2; // holds terrainUV ifdef ENABLE_TERRAIN_PERPIXEL_NORMAL
				float4 lightmapUVOrVertexSH : TEXCOORD3;
				#if defined(ASE_FOG) || defined(_ADDITIONAL_LIGHTS_VERTEX)
					half4 fogFactorAndVertexLight : TEXCOORD4;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON)
					float2 dynamicLightmapUV : TEXCOORD5;
				#endif
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_texcoord7 : TEXCOORD7;
				float4 ase_color : COLOR;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord8 : TEXCOORD8;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Color02;
			float4 _Color01;
			float _Cull1;
			float _CamDepthFadeLength;
			float _UseSideFade;
			float _SideFadeMultiply;
			float _SideFadeMax;
			float _SideFadeMin;
			float _OpacityCutoutSmoothness;
			float _OpacityCutoutEro;
			float _Emission;
			float _Smoothness;
			float _Specular;
			float _LightContribution;
			float _CamDepthFadeOffset;
			float _HorizontalFlip;
			float _MotionIntensity;
			float _EncodedMotionIntensity;
			float _Rows;
			float _Columns;
			float _ZWrite1;
			float _ZTest1;
			float _Dst1;
			float _Src1;
			float _LitBySun;
			float _DepthFade;
			float _AlphaClip;
			float _Cutoff;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _AOAlpha1;
			sampler2D _MotionVectors;
			sampler2D _MDC;
			sampler2D _OpacityCutout;


			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"

			
			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float3 objectToViewPos = TransformWorldToView( TransformObjectToWorld( input.positionOS.xyz ) );
				float eyeDepth = -objectToViewPos.z;
				output.ase_texcoord8.x = eyeDepth;
				
				output.ase_texcoord6 = input.texcoord;
				output.ase_texcoord7 = input.texcoord1;
				output.ase_color = input.ase_color;
				output.ase_normal = input.normalOS;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord8.yzw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;
				input.tangentOS = input.tangentOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );
				VertexNormalInputs normalInput = GetVertexNormalInputs( input.normalOS, input.tangentOS );

				#if defined(LIGHTMAP_ON)
					OUTPUT_LIGHTMAP_UV(input.texcoord1, unity_LightmapST, output.lightmapUVOrVertexSH.xy);
				#else
					OUTPUT_SH(normalInput.normalWS.xyz, output.lightmapUVOrVertexSH.xyz);
				#endif
				#if defined(DYNAMICLIGHTMAP_ON)
					output.dynamicLightmapUV.xy = input.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				#endif

				#if defined(ASE_FOG) || defined(_ADDITIONAL_LIGHTS_VERTEX)
					output.fogFactorAndVertexLight = 0;
					#if defined(ASE_FOG) && !defined(_FOG_FRAGMENT)
						// @diogo: no fog applied in GBuffer
					#endif
					#ifdef _ADDITIONAL_LIGHTS_VERTEX
						half3 vertexLight = VertexLighting( vertexInput.positionWS, normalInput.normalWS );
						output.fogFactorAndVertexLight.yzw = vertexLight;
					#endif
				#endif

				output.positionCS = ASE_ADJUST_CLIP_POSITION( vertexInput.positionCS );
				output.positionWS = vertexInput.positionWS;
				output.normalWS = normalInput.normalWS;
				output.tangentWS = float4( normalInput.tangentWS, ( input.tangentOS.w > 0.0 ? 1.0 : -1.0 ) * GetOddNegativeScale() );

				#if defined( ENABLE_TERRAIN_PERPIXEL_NORMAL )
					output.tangentWS.zw = input.texcoord.xy;
					output.tangentWS.xy = input.texcoord.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				#if defined(LIGHTMAP_ON) || defined(ASE_NEEDS_TEXTURE_COORDINATES1)
					float4 texcoord1 : TEXCOORD1;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON) || defined(ASE_NEEDS_TEXTURE_COORDINATES2)
					float4 texcoord2 : TEXCOORD2;
				#endif
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.positionOS = input.positionOS;
				output.normalOS = input.normalOS;
				output.tangentOS = input.tangentOS;
				output.texcoord = input.texcoord;
				#if defined(LIGHTMAP_ON) || defined(ASE_NEEDS_TEXTURE_COORDINATES1)
					output.texcoord1 = input.texcoord1;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON) || defined(ASE_NEEDS_TEXTURE_COORDINATES2)
					output.texcoord2 = input.texcoord2;
				#endif
				output.ase_color = input.ase_color;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.tangentOS = patch[0].tangentOS * bary.x + patch[1].tangentOS * bary.y + patch[2].tangentOS * bary.z;
				output.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
				#if defined(LIGHTMAP_ON) || defined(ASE_NEEDS_TEXTURE_COORDINATES1)
					output.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				#endif
				#if defined(DYNAMICLIGHTMAP_ON) || defined(ASE_NEEDS_TEXTURE_COORDINATES2)
					output.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				#endif
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].positionOS.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			FragmentOutput frag ( PackedVaryings input
								#if defined( ASE_WRITE_DEPTH )
								,out float outputDepth : ASE_SV_DEPTH
								#endif
								 )
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

				#if defined(LOD_FADE_CROSSFADE)
					LODFadeCrossFade( input.positionCS );
				#endif

				#if defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					float4 shadowCoord = TransformWorldToShadowCoord( input.positionWS );
				#else
					float4 shadowCoord = float4(0, 0, 0, 0);
				#endif

				// @diogo: mikktspace compliant
				float renormFactor = 1.0 / max( FLT_MIN, length( input.normalWS ) );

				float3 PositionWS = input.positionWS;
				float3 PositionRWS = GetCameraRelativePositionWS( PositionWS );
				float3 ViewDirWS = GetWorldSpaceNormalizeViewDir( PositionWS );
				float4 ShadowCoord = shadowCoord;
				float4 ScreenPosNorm = float4( GetNormalizedScreenSpaceUV( input.positionCS ), input.positionCS.zw );
				float4 ClipPos = ComputeClipSpacePosition( ScreenPosNorm.xy, input.positionCS.z ) * input.positionCS.w;
				float4 ScreenPos = ComputeScreenPos( ClipPos );
				float3 TangentWS = input.tangentWS.xyz * renormFactor;
				float3 BitangentWS = cross( input.normalWS, input.tangentWS.xyz ) * input.tangentWS.w * renormFactor;
				float3 NormalWS = input.normalWS * renormFactor;

				#if defined( ENABLE_TERRAIN_PERPIXEL_NORMAL )
					float2 sampleCoords = (input.tangentWS.zw / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
					NormalWS = TransformObjectToWorldNormal(normalize(SAMPLE_TEXTURE2D(_TerrainNormalmapTexture, sampler_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1));
					TangentWS = -cross(GetObjectToWorldMatrix()._13_23_33, NormalWS);
					BitangentWS = cross(NormalWS, -TangentWS);
				#endif

				float localComputeMotionFlow451 = ( 0.0 );
				float4 appendResult423 = (float4(input.ase_texcoord6.x , input.ase_texcoord6.y , 0.0 , 0.0));
				float4 ShurikenCurrentFrame431 = appendResult423;
				float2 currentFrameUV451 = ShurikenCurrentFrame431.xy;
				float ShurikenFrameIndex424 = input.ase_texcoord6.w;
				float FlipbookSize421 = ( _Columns * _Rows );
				float4 appendResult428 = (float4(input.ase_texcoord7.x , input.ase_texcoord7.y , 0.0 , 0.0));
				float4 ifLocalVar432 = 0;
				if( ShurikenFrameIndex424 >= ( FlipbookSize421 - 1.0 ) )
				ifLocalVar432 = ShurikenCurrentFrame431;
				else
				ifLocalVar432 = appendResult428;
				float4 ShurikenNextFrame435 = ifLocalVar432;
				float2 nextFrameUV451 = ShurikenNextFrame435.xy;
				float4 currentMV451 = tex2D( _MotionVectors, ShurikenCurrentFrame431.xy );
				float4 tex2DNode438 = tex2D( _MotionVectors, ShurikenNextFrame435.xy );
				float2 appendResult445 = (float2(tex2DNode438.r , tex2DNode438.g));
				float2 nextMV451 = appendResult445;
				float isIntensityEncoded451 = _EncodedMotionIntensity;
				float motionIntensity451 = _MotionIntensity;
				float columns451 = _Columns;
				float rows451 = _Rows;
				float ShurikenBlendFactor440 = input.ase_texcoord6.z;
				float blendFactor451 = ShurikenBlendFactor440;
				float2 currentFrameMVUV451 = float2( 0,0 );
				float2 nextFrameMVUV451 = float2( 0,0 );
				ComputeMotionFlow_float( currentFrameUV451 , nextFrameUV451 , currentMV451 , nextMV451 , isIntensityEncoded451 , motionIntensity451 , columns451 , rows451 , blendFactor451 , currentFrameMVUV451 , nextFrameMVUV451 );
				float4 lerpResult455 = lerp( tex2D( _AOAlpha1, currentFrameMVUV451 ) , tex2D( _AOAlpha1, nextFrameMVUV451 ) , ShurikenBlendFactor440);
				float4 TextureAlpha457 = lerpResult455;
				float4 break462 = TextureAlpha457;
				float3x3 ase_worldToTangent = float3x3( TangentWS, BitangentWS, NormalWS );
				float3 worldToTangentDir518 = normalize( mul( ase_worldToTangent, SafeNormalize( _MainLightPosition.xyz ) ) );
				float3 break499 = worldToTangentDir518;
				float4 lerpResult545 = lerp( tex2D( _MDC, currentFrameMVUV451 ) , tex2D( _MDC, nextFrameMVUV451 ) , ShurikenBlendFactor440);
				float4 TextureColor547 = lerpResult545;
				float4 break536 = TextureColor547;
				float ifLocalVar542 = 0;
				if( _HorizontalFlip > 0.0 )
				ifLocalVar542 = break536.r;
				else if( _HorizontalFlip < 0.0 )
				ifLocalVar542 = break536.g;
				float left541 = ifLocalVar542;
				float ifLocalVar543 = 0;
				if( _HorizontalFlip > 0.0 )
				ifLocalVar543 = break536.g;
				else if( _HorizontalFlip < 0.0 )
				ifLocalVar543 = break536.r;
				float right538 = ifLocalVar543;
				float ifLocalVar505 = 0;
				if( break499.x > 0.0 )
				ifLocalVar505 = left541;
				else if( break499.x < 0.0 )
				ifLocalVar505 = right538;
				float top540 = break536.b;
				float bottom539 = break536.a;
				float ifLocalVar508 = 0;
				if( break499.y > 0.0 )
				ifLocalVar508 = top540;
				else if( break499.y < 0.0 )
				ifLocalVar508 = bottom539;
				float saferPower530 = abs( ( ( ( right538 + left541 ) + ( top540 + bottom539 ) ) / 4.0 ) );
				float front529 = pow( saferPower530 , 0.625 );
				float temp_output_525_0 = ( front529 * front529 );
				float temp_output_521_0 = ( temp_output_525_0 * temp_output_525_0 );
				float temp_output_522_0 = ( temp_output_521_0 * temp_output_521_0 );
				float back519 = ( ( ( temp_output_522_0 * temp_output_522_0 ) / 2.0 ) + saturate( ( ( 1.0 - front529 ) / 4.0 ) ) );
				float ifLocalVar513 = 0;
				if( break499.z > 0.0 )
				ifLocalVar513 = front529;
				else if( break499.z < 0.0 )
				ifLocalVar513 = back519;
				float lightmap504 = ( ( ( ( break499.x * break499.x ) * ifLocalVar505 ) + ( ( break499.y * break499.y ) * ifLocalVar508 ) ) + ( ( break499.z * break499.z ) * ifLocalVar513 ) );
				float lerpResult488 = lerp( 1.0 , lightmap504 , saturate( _LightContribution ));
				float lerpResult490 = lerp( break462.g , lerpResult488 , saturate( _LitBySun ));
				float3 lerpResult483 = lerp( _Color01.rgb , _Color02.rgb , lerpResult490);
				float3 lerpResult482 = lerp( _Color02.rgb , lerpResult483 , break462.a);
				float4 temp_output_486_0 = ( float4( lerpResult482 , 0.0 ) * input.ase_color );
				
				float3 temp_cast_7 = (_Specular).xxx;
				
				float2 texCoord459 = input.ase_texcoord6.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult456 = (float2(_Columns , _Rows));
				float2 Flipbook_Tile458 = appendResult456;
				float smoothstepResult471 = smoothstep( _OpacityCutoutEro , ( _OpacityCutoutEro + _OpacityCutoutSmoothness ) , tex2D( _OpacityCutout, ( texCoord459 * Flipbook_Tile458 ) ).g);
				float temp_output_231_0 = saturate( saturate( ( saturate( ( input.ase_color.a * break462.a ) ) * smoothstepResult471 ) ) );
				float3 normalizeResult244 = normalize( ( _WorldSpaceCameraPos - PositionWS ) );
				float dotResult249 = dot( input.ase_normal , normalizeResult244 );
				float lerpResult254 = lerp( _SideFadeMin , _SideFadeMax , saturate( ( ( 1.0 - abs( dotResult249 ) ) * _SideFadeMultiply ) ));
				float lerpResult236 = lerp( temp_output_231_0 , saturate( ( temp_output_231_0 * saturate( ( 1.0 - saturate( lerpResult254 ) ) ) ) ) , _UseSideFade);
				float eyeDepth = input.ase_texcoord8.x;
				float cameraDepthFade206 = (( eyeDepth -_ProjectionParams.y - _CamDepthFadeOffset ) / _CamDepthFadeLength);
				float camFade208 = saturate( cameraDepthFade206 );
				float screenDepth474 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ScreenPosNorm.xy ),_ZBufferParams);
				float distanceDepth474 = saturate( ( screenDepth474 - LinearEyeDepth( ScreenPosNorm.z,_ZBufferParams ) ) / ( _DepthFade ) );
				

				float3 BaseColor = temp_output_486_0.rgb;
				float3 Normal = float3(0, 0, 1);
				float3 Specular = temp_cast_7;
				float Metallic = 0;
				float Smoothness = _Smoothness;
				float Occlusion = 1;
				float3 Emission = ( temp_output_486_0 * _Emission ).rgb;
				float Alpha = saturate( ( saturate( ( saturate( lerpResult236 ) * camFade208 ) ) * distanceDepth474 ) );
				#if defined( _ALPHATEST_ON )
					float AlphaClipThreshold = _Cutoff;
					float AlphaClipThresholdShadow = 0.5;
				#endif
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;

				#if defined( ASE_WRITE_DEPTH )
					input.positionCS.z = input.positionCS.z;
				#endif

				#if defined( _ALPHATEST_ON )
					AlphaDiscard( Alpha, AlphaClipThreshold );
				#endif

				#if defined(MAIN_LIGHT_CALCULATE_SHADOWS) && defined(ASE_CHANGES_WORLD_POS)
					ShadowCoord = TransformWorldToShadowCoord( PositionWS );
				#endif

				InputData inputData = (InputData)0;
				inputData.positionWS = PositionWS;
				inputData.positionCS = input.positionCS;
				inputData.normalizedScreenSpaceUV = ScreenPosNorm.xy;
				inputData.shadowCoord = ShadowCoord;

				#ifdef _NORMALMAP
					#if _NORMAL_DROPOFF_TS
						inputData.normalWS = TransformTangentToWorld(Normal, half3x3( TangentWS, BitangentWS, NormalWS ));
					#elif _NORMAL_DROPOFF_OS
						inputData.normalWS = TransformObjectToWorldNormal(Normal);
					#elif _NORMAL_DROPOFF_WS
						inputData.normalWS = Normal;
					#endif
				#else
					inputData.normalWS = NormalWS;
				#endif

				inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
				inputData.viewDirectionWS = SafeNormalize( ViewDirWS );

				#ifdef ASE_FOG
					// @diogo: no fog applied in GBuffer
				#endif
				#ifdef _ADDITIONAL_LIGHTS_VERTEX
					inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
				#endif

				#if defined( ENABLE_TERRAIN_PERPIXEL_NORMAL )
					float3 SH = SampleSH(inputData.normalWS.xyz);
				#else
					float3 SH = input.lightmapUVOrVertexSH.xyz;
				#endif

				#if defined(DYNAMICLIGHTMAP_ON)
					inputData.bakedGI = SAMPLE_GI(input.lightmapUVOrVertexSH.xy, input.dynamicLightmapUV.xy, SH, inputData.normalWS);
				#else
					inputData.bakedGI = SAMPLE_GI(input.lightmapUVOrVertexSH.xy, SH, inputData.normalWS);
				#endif

				#ifdef ASE_BAKEDGI
					inputData.bakedGI = BakedGI;
				#endif

				inputData.shadowMask = SAMPLE_SHADOWMASK(input.lightmapUVOrVertexSH.xy);

				#if defined(DEBUG_DISPLAY)
					#if defined(DYNAMICLIGHTMAP_ON)
						inputData.dynamicLightmapUV = input.dynamicLightmapUV.xy;
						#endif
					#if defined(LIGHTMAP_ON)
						inputData.staticLightmapUV = input.lightmapUVOrVertexSH.xy;
					#else
						inputData.vertexSH = SH;
					#endif
				#endif

				#ifdef _DBUFFER
					ApplyDecal(input.positionCS,
						BaseColor,
						Specular,
						inputData.normalWS,
						Metallic,
						Occlusion,
						Smoothness);
				#endif

				BRDFData brdfData;
				InitializeBRDFData(BaseColor, Metallic, Specular, Smoothness, Alpha, brdfData);

				Light mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, inputData.shadowMask);
				half4 color;
				MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI, inputData.shadowMask);
				color.rgb = GlobalIllumination(brdfData, inputData.bakedGI, Occlusion, inputData.positionWS, inputData.normalWS, inputData.viewDirectionWS);
				color.a = Alpha;

				#ifdef ASE_FINAL_COLOR_ALPHA_MULTIPLY
					color.rgb *= color.a;
				#endif

				#if defined( ASE_WRITE_DEPTH )
					outputDepth = input.positionCS.z;
				#endif

				return BRDFDataToGbuffer(brdfData, inputData, Smoothness, Emission + color.rgb, Occlusion);
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "SceneSelectionPass"
			Tags { "LightMode"="SceneSelectionPass" }

			Cull Off
			AlphaToMask Off

			HLSLPROGRAM

			

			#define ASE_GEOMETRY
			#define _NORMAL_DROPOFF_TS 1
			#define ASE_FOG 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _SPECULAR_SETUP 1
			#define _EMISSION
			#define ASE_VERSION 19912
			#define ASE_SRP_VERSION 140007
			#define REQUIRE_DEPTH_TEXTURE 1


			

			#pragma vertex vert
			#pragma fragment frag

			#if defined( _SPECULAR_SETUP ) && defined( ASE_LIGHTING_SIMPLE )
				#if defined( _SPECULARHIGHLIGHTS_OFF )
					#undef _SPECULAR_COLOR
				#else
					#define _SPECULAR_COLOR
				#endif
			#endif

			#define SCENESELECTIONPASS 1

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"

			

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			
            #if ASE_SRP_VERSION >=140007
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#endif
		

			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "../../../Shared/Shaders/MotionVectorFrameBlending.hlsl"
			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES1
			#define ASE_NEEDS_WORLD_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_SCREEN_POSITION_NORMALIZED


			#if defined(ASE_WRITE_DEPTH_CONSERVATIVE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float3 positionWS : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Color02;
			float4 _Color01;
			float _Cull1;
			float _CamDepthFadeLength;
			float _UseSideFade;
			float _SideFadeMultiply;
			float _SideFadeMax;
			float _SideFadeMin;
			float _OpacityCutoutSmoothness;
			float _OpacityCutoutEro;
			float _Emission;
			float _Smoothness;
			float _Specular;
			float _LightContribution;
			float _CamDepthFadeOffset;
			float _HorizontalFlip;
			float _MotionIntensity;
			float _EncodedMotionIntensity;
			float _Rows;
			float _Columns;
			float _ZWrite1;
			float _ZTest1;
			float _Dst1;
			float _Src1;
			float _LitBySun;
			float _DepthFade;
			float _AlphaClip;
			float _Cutoff;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _AOAlpha1;
			sampler2D _MotionVectors;
			sampler2D _OpacityCutout;


			
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			PackedVaryings VertexFunction(Attributes input  )
			{
				PackedVaryings output;
				ZERO_INITIALIZE(PackedVaryings, output);

				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float3 objectToViewPos = TransformWorldToView( TransformObjectToWorld( input.positionOS.xyz ) );
				float eyeDepth = -objectToViewPos.z;
				output.ase_texcoord3.x = eyeDepth;
				
				output.ase_color = input.ase_color;
				output.ase_texcoord1 = input.ase_texcoord;
				output.ase_texcoord2 = input.ase_texcoord1;
				output.ase_normal = input.normalOS;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord3.yzw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );

				output.positionCS = ASE_ADJUST_CLIP_POSITION( vertexInput.positionCS );
				output.positionWS = vertexInput.positionWS;
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.positionOS = input.positionOS;
				output.normalOS = input.normalOS;
				output.tangentOS = input.tangentOS;
				output.ase_color = input.ase_color;
				output.ase_texcoord = input.ase_texcoord;
				output.ase_texcoord1 = input.ase_texcoord1;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.tangentOS = patch[0].tangentOS * bary.x + patch[1].tangentOS * bary.y + patch[2].tangentOS * bary.z;
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				output.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				output.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].positionOS.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			half4 frag( PackedVaryings input
				#if defined( ASE_WRITE_DEPTH )
				,out float outputDepth : ASE_SV_DEPTH
				#endif
				 ) : SV_Target
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float3 PositionWS = input.positionWS;
				float3 PositionRWS = GetCameraRelativePositionWS( PositionWS );
				float4 ScreenPosNorm = float4( GetNormalizedScreenSpaceUV( input.positionCS ), input.positionCS.zw );
				float4 ClipPos = ComputeClipSpacePosition( ScreenPosNorm.xy, input.positionCS.z ) * input.positionCS.w;

				float localComputeMotionFlow451 = ( 0.0 );
				float4 appendResult423 = (float4(input.ase_texcoord1.x , input.ase_texcoord1.y , 0.0 , 0.0));
				float4 ShurikenCurrentFrame431 = appendResult423;
				float2 currentFrameUV451 = ShurikenCurrentFrame431.xy;
				float ShurikenFrameIndex424 = input.ase_texcoord1.w;
				float FlipbookSize421 = ( _Columns * _Rows );
				float4 appendResult428 = (float4(input.ase_texcoord2.x , input.ase_texcoord2.y , 0.0 , 0.0));
				float4 ifLocalVar432 = 0;
				if( ShurikenFrameIndex424 >= ( FlipbookSize421 - 1.0 ) )
				ifLocalVar432 = ShurikenCurrentFrame431;
				else
				ifLocalVar432 = appendResult428;
				float4 ShurikenNextFrame435 = ifLocalVar432;
				float2 nextFrameUV451 = ShurikenNextFrame435.xy;
				float4 currentMV451 = tex2D( _MotionVectors, ShurikenCurrentFrame431.xy );
				float4 tex2DNode438 = tex2D( _MotionVectors, ShurikenNextFrame435.xy );
				float2 appendResult445 = (float2(tex2DNode438.r , tex2DNode438.g));
				float2 nextMV451 = appendResult445;
				float isIntensityEncoded451 = _EncodedMotionIntensity;
				float motionIntensity451 = _MotionIntensity;
				float columns451 = _Columns;
				float rows451 = _Rows;
				float ShurikenBlendFactor440 = input.ase_texcoord1.z;
				float blendFactor451 = ShurikenBlendFactor440;
				float2 currentFrameMVUV451 = float2( 0,0 );
				float2 nextFrameMVUV451 = float2( 0,0 );
				ComputeMotionFlow_float( currentFrameUV451 , nextFrameUV451 , currentMV451 , nextMV451 , isIntensityEncoded451 , motionIntensity451 , columns451 , rows451 , blendFactor451 , currentFrameMVUV451 , nextFrameMVUV451 );
				float4 lerpResult455 = lerp( tex2D( _AOAlpha1, currentFrameMVUV451 ) , tex2D( _AOAlpha1, nextFrameMVUV451 ) , ShurikenBlendFactor440);
				float4 TextureAlpha457 = lerpResult455;
				float4 break462 = TextureAlpha457;
				float2 texCoord459 = input.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult456 = (float2(_Columns , _Rows));
				float2 Flipbook_Tile458 = appendResult456;
				float smoothstepResult471 = smoothstep( _OpacityCutoutEro , ( _OpacityCutoutEro + _OpacityCutoutSmoothness ) , tex2D( _OpacityCutout, ( texCoord459 * Flipbook_Tile458 ) ).g);
				float temp_output_231_0 = saturate( saturate( ( saturate( ( input.ase_color.a * break462.a ) ) * smoothstepResult471 ) ) );
				float3 normalizeResult244 = normalize( ( _WorldSpaceCameraPos - PositionWS ) );
				float dotResult249 = dot( input.ase_normal , normalizeResult244 );
				float lerpResult254 = lerp( _SideFadeMin , _SideFadeMax , saturate( ( ( 1.0 - abs( dotResult249 ) ) * _SideFadeMultiply ) ));
				float lerpResult236 = lerp( temp_output_231_0 , saturate( ( temp_output_231_0 * saturate( ( 1.0 - saturate( lerpResult254 ) ) ) ) ) , _UseSideFade);
				float eyeDepth = input.ase_texcoord3.x;
				float cameraDepthFade206 = (( eyeDepth -_ProjectionParams.y - _CamDepthFadeOffset ) / _CamDepthFadeLength);
				float camFade208 = saturate( cameraDepthFade206 );
				float screenDepth474 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ScreenPosNorm.xy ),_ZBufferParams);
				float distanceDepth474 = saturate( ( screenDepth474 - LinearEyeDepth( ScreenPosNorm.z,_ZBufferParams ) ) / ( _DepthFade ) );
				

				surfaceDescription.Alpha = saturate( ( saturate( ( saturate( lerpResult236 ) * camFade208 ) ) * distanceDepth474 ) );
				#if defined( _ALPHATEST_ON )
					surfaceDescription.AlphaClipThreshold = _Cutoff;
				#endif

				#if defined( ASE_WRITE_DEPTH )
					input.positionCS.z = input.positionCS.z;
				#endif

				#ifdef _ALPHATEST_ON
					clip(surfaceDescription.Alpha - surfaceDescription.AlphaClipThreshold);
				#endif

				#if defined( ASE_WRITE_DEPTH )
					outputDepth = input.positionCS.z;
				#endif

				return half4( _ObjectId, _PassValue, 1.0, 1.0 );
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "ScenePickingPass"
			Tags { "LightMode"="Picking" }

			AlphaToMask Off

			HLSLPROGRAM

			

			#define ASE_GEOMETRY
			#define _NORMAL_DROPOFF_TS 1
			#define ASE_FOG 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _SPECULAR_SETUP 1
			#define _EMISSION
			#define ASE_VERSION 19912
			#define ASE_SRP_VERSION 140007
			#define REQUIRE_DEPTH_TEXTURE 1


			

			#pragma vertex vert
			#pragma fragment frag

			#if defined( _SPECULAR_SETUP ) && defined( ASE_LIGHTING_SIMPLE )
				#if defined( _SPECULARHIGHLIGHTS_OFF )
					#undef _SPECULAR_COLOR
				#else
					#define _SPECULAR_COLOR
				#endif
			#endif

		    #define SCENEPICKINGPASS 1

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"

			

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			
            #if ASE_SRP_VERSION >=140007
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
			#endif
		

			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "../../../Shared/Shaders/MotionVectorFrameBlending.hlsl"
			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES1
			#define ASE_NEEDS_WORLD_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_SCREEN_POSITION_NORMALIZED


			#if defined(ASE_WRITE_DEPTH_CONSERVATIVE) && (SHADER_TARGET >= 45)
				#define ASE_SV_DEPTH SV_DepthLessEqual
				#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
			#else
				#define ASE_SV_DEPTH SV_Depth
				#define ASE_SV_POSITION_QUALIFIERS
			#endif

			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float3 positionWS : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Color02;
			float4 _Color01;
			float _Cull1;
			float _CamDepthFadeLength;
			float _UseSideFade;
			float _SideFadeMultiply;
			float _SideFadeMax;
			float _SideFadeMin;
			float _OpacityCutoutSmoothness;
			float _OpacityCutoutEro;
			float _Emission;
			float _Smoothness;
			float _Specular;
			float _LightContribution;
			float _CamDepthFadeOffset;
			float _HorizontalFlip;
			float _MotionIntensity;
			float _EncodedMotionIntensity;
			float _Rows;
			float _Columns;
			float _ZWrite1;
			float _ZTest1;
			float _Dst1;
			float _Src1;
			float _LitBySun;
			float _DepthFade;
			float _AlphaClip;
			float _Cutoff;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _AOAlpha1;
			sampler2D _MotionVectors;
			sampler2D _OpacityCutout;


			
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output;
				ZERO_INITIALIZE(PackedVaryings, output);

				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float3 objectToViewPos = TransformWorldToView( TransformObjectToWorld( input.positionOS.xyz ) );
				float eyeDepth = -objectToViewPos.z;
				output.ase_texcoord3.x = eyeDepth;
				
				output.ase_color = input.ase_color;
				output.ase_texcoord1 = input.ase_texcoord;
				output.ase_texcoord2 = input.ase_texcoord1;
				output.ase_normal = input.normalOS;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord3.yzw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				input.normalOS = input.normalOS;

				VertexPositionInputs vertexInput = GetVertexPositionInputs( input.positionOS.xyz );

				output.positionCS = ASE_ADJUST_CLIP_POSITION( vertexInput.positionCS );
				output.positionWS = vertexInput.positionWS;
				return output;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 positionOS : INTERNALTESSPOS;
				half3 normalOS : NORMAL;
				half4 tangentOS : TANGENT;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( Attributes input )
			{
				VertexControl output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				output.positionOS = input.positionOS;
				output.normalOS = input.normalOS;
				output.tangentOS = input.tangentOS;
				output.ase_color = input.ase_color;
				output.ase_texcoord = input.ase_texcoord;
				output.ase_texcoord1 = input.ase_texcoord1;
				return output;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> input)
			{
				TessellationFactors output;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(input[0].positionOS, input[1].positionOS, input[2].positionOS, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				output.edge[0] = tf.x; output.edge[1] = tf.y; output.edge[2] = tf.z; output.inside = tf.w;
				return output;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			PackedVaryings DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				Attributes output = (Attributes) 0;
				output.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z;
				output.normalOS = patch[0].normalOS * bary.x + patch[1].normalOS * bary.y + patch[2].normalOS * bary.z;
				output.tangentOS = patch[0].tangentOS * bary.x + patch[1].tangentOS * bary.y + patch[2].tangentOS * bary.z;
				output.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				output.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				output.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = output.positionOS.xyz - patch[i].normalOS * (dot(output.positionOS.xyz, patch[i].normalOS) - dot(patch[i].positionOS.xyz, patch[i].normalOS));
				float phongStrength = _TessPhongStrength;
				output.positionOS.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * output.positionOS.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], output);
				return VertexFunction(output);
			}
			#else
			PackedVaryings vert ( Attributes input )
			{
				return VertexFunction( input );
			}
			#endif

			half4 frag( PackedVaryings input
				#if defined( ASE_WRITE_DEPTH )
				,out float outputDepth : ASE_SV_DEPTH
				#endif
				 ) : SV_Target
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float3 PositionWS = input.positionWS;
				float3 PositionRWS = GetCameraRelativePositionWS( PositionWS );
				float4 ScreenPosNorm = float4( GetNormalizedScreenSpaceUV( input.positionCS ), input.positionCS.zw );
				float4 ClipPos = ComputeClipSpacePosition( ScreenPosNorm.xy, input.positionCS.z ) * input.positionCS.w;

				float localComputeMotionFlow451 = ( 0.0 );
				float4 appendResult423 = (float4(input.ase_texcoord1.x , input.ase_texcoord1.y , 0.0 , 0.0));
				float4 ShurikenCurrentFrame431 = appendResult423;
				float2 currentFrameUV451 = ShurikenCurrentFrame431.xy;
				float ShurikenFrameIndex424 = input.ase_texcoord1.w;
				float FlipbookSize421 = ( _Columns * _Rows );
				float4 appendResult428 = (float4(input.ase_texcoord2.x , input.ase_texcoord2.y , 0.0 , 0.0));
				float4 ifLocalVar432 = 0;
				if( ShurikenFrameIndex424 >= ( FlipbookSize421 - 1.0 ) )
				ifLocalVar432 = ShurikenCurrentFrame431;
				else
				ifLocalVar432 = appendResult428;
				float4 ShurikenNextFrame435 = ifLocalVar432;
				float2 nextFrameUV451 = ShurikenNextFrame435.xy;
				float4 currentMV451 = tex2D( _MotionVectors, ShurikenCurrentFrame431.xy );
				float4 tex2DNode438 = tex2D( _MotionVectors, ShurikenNextFrame435.xy );
				float2 appendResult445 = (float2(tex2DNode438.r , tex2DNode438.g));
				float2 nextMV451 = appendResult445;
				float isIntensityEncoded451 = _EncodedMotionIntensity;
				float motionIntensity451 = _MotionIntensity;
				float columns451 = _Columns;
				float rows451 = _Rows;
				float ShurikenBlendFactor440 = input.ase_texcoord1.z;
				float blendFactor451 = ShurikenBlendFactor440;
				float2 currentFrameMVUV451 = float2( 0,0 );
				float2 nextFrameMVUV451 = float2( 0,0 );
				ComputeMotionFlow_float( currentFrameUV451 , nextFrameUV451 , currentMV451 , nextMV451 , isIntensityEncoded451 , motionIntensity451 , columns451 , rows451 , blendFactor451 , currentFrameMVUV451 , nextFrameMVUV451 );
				float4 lerpResult455 = lerp( tex2D( _AOAlpha1, currentFrameMVUV451 ) , tex2D( _AOAlpha1, nextFrameMVUV451 ) , ShurikenBlendFactor440);
				float4 TextureAlpha457 = lerpResult455;
				float4 break462 = TextureAlpha457;
				float2 texCoord459 = input.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult456 = (float2(_Columns , _Rows));
				float2 Flipbook_Tile458 = appendResult456;
				float smoothstepResult471 = smoothstep( _OpacityCutoutEro , ( _OpacityCutoutEro + _OpacityCutoutSmoothness ) , tex2D( _OpacityCutout, ( texCoord459 * Flipbook_Tile458 ) ).g);
				float temp_output_231_0 = saturate( saturate( ( saturate( ( input.ase_color.a * break462.a ) ) * smoothstepResult471 ) ) );
				float3 normalizeResult244 = normalize( ( _WorldSpaceCameraPos - PositionWS ) );
				float dotResult249 = dot( input.ase_normal , normalizeResult244 );
				float lerpResult254 = lerp( _SideFadeMin , _SideFadeMax , saturate( ( ( 1.0 - abs( dotResult249 ) ) * _SideFadeMultiply ) ));
				float lerpResult236 = lerp( temp_output_231_0 , saturate( ( temp_output_231_0 * saturate( ( 1.0 - saturate( lerpResult254 ) ) ) ) ) , _UseSideFade);
				float eyeDepth = input.ase_texcoord3.x;
				float cameraDepthFade206 = (( eyeDepth -_ProjectionParams.y - _CamDepthFadeOffset ) / _CamDepthFadeLength);
				float camFade208 = saturate( cameraDepthFade206 );
				float screenDepth474 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ScreenPosNorm.xy ),_ZBufferParams);
				float distanceDepth474 = saturate( ( screenDepth474 - LinearEyeDepth( ScreenPosNorm.z,_ZBufferParams ) ) / ( _DepthFade ) );
				

				surfaceDescription.Alpha = saturate( ( saturate( ( saturate( lerpResult236 ) * camFade208 ) ) * distanceDepth474 ) );
				#if defined( _ALPHATEST_ON )
					surfaceDescription.AlphaClipThreshold = _Cutoff;
				#endif

				#if defined( ASE_WRITE_DEPTH )
					input.positionCS.z = input.positionCS.z;
				#endif

				#ifdef _ALPHATEST_ON
					clip(surfaceDescription.Alpha - surfaceDescription.AlphaClipThreshold);
				#endif

				#if defined( ASE_WRITE_DEPTH )
					outputDepth = input.positionCS.z;
				#endif

				return unity_SelectionID;
			}
			ENDHLSL
		}
		
	}
	

	

	CustomEditor "UnityEditor.ShaderGraphLitGUI"
	FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback Off
}
/*ASEBEGIN
Version=19912
{"type":"AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor","id":416,"pos":[-10272,-1136],"params":["Inherit","False","3684.295","1184.774","Motion Vector Frame Blending","30","550","549","547","546","545","544","458","457","456","455","454","453","452","451","450","449","448","446","445","444","443","442","439","438","437","436","421","420","418","417","Motion Vector Frame Blending","0,0,0,1","0","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":417,"pos":[-9216,-432],"params":["Inherit","False","Property","_Rows","Rows","12","0","Create","True","0","0","0","False","0","False","Object","-1","","8","8","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":418,"pos":[-9216,-512],"params":["Inherit","False","Property","_Columns","Columns","13","0","Create","True","0","0","0","False","0","False","Object","-1","","8","8","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":420,"pos":[-8960,-512],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor","id":419,"pos":[-10272,-2032],"params":["Inherit","False","2336.386","824.6879","Shuriken provides Blend Timing in UV.z and Next Frame UVs in UV2.xy","13","479","440","435","432","431","430","429","428","426","425","424","423","422","Shuriken Texture Sheet Animation Data","0,0,0,1","0","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":421,"pos":[-8704,-512],"params":["Inherit","False","FlipbookSize","-1","True","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor","id":427,"pos":[-10272,-3200],"params":["Inherit","False","930.0732","1021.819","Textures","6","551","548","447","441","434","433","Textures","0,0,0,1","0","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":424,"pos":[-9600,-1664],"params":["Inherit","False","ShurikenFrameIndex","-1","True","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.TexCoordVertexDataNode, AmplifyShaderEditor","id":425,"pos":[-10112,-1536],"params":["Inherit","False","1","4","0","5","FLOAT4","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":426,"pos":[-9088,-1408],"params":["Inherit","False","421","FlipbookSize","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor","id":267,"pos":[-4736,2512],"params":["Inherit","False","2916","746.8","Side Fade","17","241","247","242","244","248","249","250","251","263","252","262","256","255","254","240","264","265","Side Fade","0,0,0,1","0","0"]}
{"type":"AmplifyShaderEditor.TexCoordVertexDataNode, AmplifyShaderEditor","id":422,"pos":[-10112,-1920],"params":["Inherit","False","0","4","0","5","FLOAT4","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4"]}
{"type":"AmplifyShaderEditor.DynamicAppendNode, AmplifyShaderEditor","id":428,"pos":[-9856,-1536],"params":["Inherit","False","FLOAT4","4","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","0","False","3","FLOAT","0","False","1","FLOAT4","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":429,"pos":[-9088,-1664],"params":["Inherit","False","424","ShurikenFrameIndex","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleSubtractOpNode, AmplifyShaderEditor","id":430,"pos":[-8832,-1408],"params":["Inherit","False","2","0","FLOAT","0","False","1","FLOAT","1","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor","id":433,"pos":[-10112,-2560],"params":["Inherit","True","Property","_MotionVectors","Motion Vectors","11","0","Create","True","0","0","0","False","3","Space(33)","Header(Motion Vector Frame Blending)","Space(13)","False","","None","None","False","white","Auto","Texture2D","False","-1","0","2","SAMPLER2D","0","SAMPLERSTATE","1"]}
{"type":"AmplifyShaderEditor.DynamicAppendNode, AmplifyShaderEditor","id":423,"pos":[-9856,-1920],"params":["Inherit","False","FLOAT4","4","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","0","False","3","FLOAT","0","False","1","FLOAT4","0"]}
{"type":"AmplifyShaderEditor.ConditionalIfNode, AmplifyShaderEditor","id":432,"pos":[-8704,-1664],"params":["Inherit","False","False","5","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT4","0,0,0,0","False","3","FLOAT4","0,0,0,0","False","4","FLOAT4","0,0,0,0","False","1","FLOAT4","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":434,"pos":[-9728,-2560],"params":["Inherit","False","MotionVectors","-1","True","1","0","SAMPLER2D","","False","1","SAMPLER2D","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":437,"pos":[-10240,-768],"params":["Inherit","False","435","ShurikenNextFrame","1","0","OBJECT","","False","1","FLOAT4","0"]}
{"type":"AmplifyShaderEditor.WorldSpaceCameraPos, AmplifyShaderEditor","id":241,"pos":[-4688,2816],"params":["Inherit","False","0","4","FLOAT3","0","FLOAT","1","FLOAT","2","FLOAT","3"]}
{"type":"AmplifyShaderEditor.WorldPosInputsNode, AmplifyShaderEditor","id":247,"pos":[-4688,3072],"params":["Inherit","False","0","4","FLOAT3","0","FLOAT","1","FLOAT","2","FLOAT","3"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":431,"pos":[-9600,-1920],"params":["Inherit","False","ShurikenCurrentFrame","-1","True","1","0","FLOAT4","0,0,0,0","False","1","FLOAT4","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":435,"pos":[-8320,-1536],"params":["Inherit","False","ShurikenNextFrame","-1","True","1","0","FLOAT4","0,0,0,0","False","1","FLOAT4","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":436,"pos":[-10240,-896],"params":["Inherit","False","434","MotionVectors","1","0","OBJECT","","False","1","SAMPLER2D","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":439,"pos":[-10240,-1024],"params":["Inherit","False","431","ShurikenCurrentFrame","1","0","OBJECT","","False","1","FLOAT4","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":440,"pos":[-9600,-1792],"params":["Inherit","False","ShurikenBlendFactor","-1","True","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor","id":438,"pos":[-9728,-768],"params":["Inherit","True","Property","_TextureSample3","Texture Sample 0","0","0","Create","True","0","0","0","False","0","False","","-1","None","None","True","0","False","white","Auto","False","Object","-1","Auto","Texture2D","False","8","0","SAMPLER2D","","False","1","FLOAT2","0,0","False","2","FLOAT","0","False","3","FLOAT2","0,0","False","4","FLOAT2","0,0","False","5","FLOAT","1","False","6","FLOAT","0","False","7","SAMPLERSTATE","","False","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor","id":441,"pos":[-10112,-2816],"params":["Inherit","True","Property","_AOAlpha1","AO Alpha","1","0","Create","True","0","0","0","False","3","Space(33)","Header(AO Alpha)","Space(13)","False","","None","None","False","white","Auto","Texture2D","False","-1","0","2","SAMPLER2D","0","SAMPLERSTATE","1"]}
{"type":"AmplifyShaderEditor.SimpleSubtractOpNode, AmplifyShaderEditor","id":242,"pos":[-4304,2816],"params":["Inherit","False","2","0","FLOAT3","0,0,0","False","1","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":442,"pos":[-9216,-1024],"params":["Inherit","False","431","ShurikenCurrentFrame","1","0","OBJECT","","False","1","FLOAT4","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":443,"pos":[-9216,-896],"params":["Inherit","False","435","ShurikenNextFrame","1","0","OBJECT","","False","1","FLOAT4","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":444,"pos":[-9216,-688],"params":["Inherit","False","Property","_MotionIntensity","Motion Intensity","15","0","Create","True","0","0","0","False","0","False","Object","-1","","0","0","0","1","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":446,"pos":[-9216,-256],"params":["Inherit","False","440","ShurikenBlendFactor","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":449,"pos":[-9216,-768],"params":["Inherit","False","Property","_EncodedMotionIntensity","Encoded Motion Intensity","14","0","Create","True","0","0","0","False","0","False","Object","-1","","1","1","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.DynamicAppendNode, AmplifyShaderEditor","id":445,"pos":[-9344,-768],"params":["Inherit","False","FLOAT2","4","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","0","False","3","FLOAT","0","False","1","FLOAT2","0"]}
{"type":"AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor","id":448,"pos":[-9728,-1024],"params":["Inherit","True","Property","_TextureSample2","Texture Sample 0","0","0","Create","True","0","0","0","False","0","False","","-1","None","None","True","0","False","white","Auto","False","Object","-1","Auto","Texture2D","False","8","0","SAMPLER2D","","False","1","FLOAT2","0,0","False","2","FLOAT","0","False","3","FLOAT2","0,0","False","4","FLOAT2","0,0","False","5","FLOAT","1","False","6","FLOAT","0","False","7","SAMPLERSTATE","","False","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":447,"pos":[-9728,-2816],"params":["Inherit","False","FlipbookAlpha","-1","True","1","0","SAMPLER2D","","False","1","SAMPLER2D","0"]}
{"type":"AmplifyShaderEditor.NormalizeNode, AmplifyShaderEditor","id":244,"pos":[-4048,2816],"params":["Inherit","False","False","1","0","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.NormalVertexDataNode, AmplifyShaderEditor","id":248,"pos":[-4048,2560],"params":["Inherit","False","0","5","FLOAT3","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4"]}
{"type":"AmplifyShaderEditor.CustomExpressionNode, AmplifyShaderEditor","id":451,"pos":[-8704,-1024],"params":["Inherit","False"," ","8","File","11","True","currentFrameUV","FLOAT2","0,0","In","","Inherit","False","True","nextFrameUV","FLOAT2","0,0","In","","Inherit","False","True","currentMV","FLOAT4","0,0,0,0","In","","Inherit","False","True","nextMV","FLOAT2","0,0","In","","Inherit","False","True","isIntensityEncoded","FLOAT","0","In","","Inherit","False","True","motionIntensity","FLOAT","0","In","","Inherit","False","True","columns","FLOAT","0","In","","Inherit","False","True","rows","FLOAT","0","In","","Inherit","False","True","blendFactor","FLOAT","0","In","","Inherit","False","True","currentFrameMVUV","FLOAT2","0,0","Out","","Inherit","False","True","nextFrameMVUV","FLOAT2","0,0","Out","","Inherit","False","ComputeMotionFlow","False","False","0","44655f03ba5dfca44a92110412bc10e5","True","12","0","FLOAT","0","False","1","FLOAT2","0,0","False","2","FLOAT2","0,0","False","3","FLOAT4","0,0,0,0","False","4","FLOAT2","0,0","False","5","FLOAT","0","False","6","FLOAT","0","False","7","FLOAT","0","False","8","FLOAT","0","False","9","FLOAT","0","False","10","FLOAT2","0,0","False","11","FLOAT2","0,0","False","3","FLOAT","0","FLOAT2","11","FLOAT2","12"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":450,"pos":[-8064,-384],"params":["Inherit","False","447","FlipbookAlpha","1","0","OBJECT","","False","1","SAMPLER2D","0"]}
{"type":"AmplifyShaderEditor.DotProductOpNode, AmplifyShaderEditor","id":249,"pos":[-3792,2560],"params":["Inherit","False","2","0","FLOAT3","0,0,0","False","1","FLOAT3","0,0,0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":452,"pos":[-7424,-384],"params":["Inherit","False","440","ShurikenBlendFactor","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor","id":453,"pos":[-7808,-256],"params":["Inherit","True","Property","_TextureSample5","Texture Sample 0","0","0","Create","True","0","0","0","False","0","False","","-1","None","None","True","0","False","white","Auto","False","Instance","-1","Auto","Texture2D","False","8","0","SAMPLER2D","","False","1","FLOAT2","0,0","False","2","FLOAT","0","False","3","FLOAT2","0,0","False","4","FLOAT2","0,0","False","5","FLOAT","1","False","6","FLOAT","0","False","7","SAMPLERSTATE","","False","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor","id":454,"pos":[-7808,-512],"params":["Inherit","True","Property","_TextureSample4","Texture Sample 1","0","0","Create","True","0","0","0","False","0","False","","-1","None","None","True","0","False","white","Auto","False","Instance","-1","Auto","Texture2D","False","8","0","SAMPLER2D","","False","1","FLOAT2","0,0","False","2","FLOAT","0","False","3","FLOAT2","0,0","False","4","FLOAT2","0,0","False","5","FLOAT","1","False","6","FLOAT","0","False","7","SAMPLERSTATE","","False","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.AbsOpNode, AmplifyShaderEditor","id":250,"pos":[-3664,2560],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.LerpOp, AmplifyShaderEditor","id":455,"pos":[-7424,-512],"params":["Inherit","False","3","0","COLOR","0,0,0,0","False","1","COLOR","0,0,0,0","False","2","FLOAT","0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.DynamicAppendNode, AmplifyShaderEditor","id":456,"pos":[-8960,-384],"params":["Inherit","False","FLOAT2","4","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","0","False","3","FLOAT","0","False","1","FLOAT2","0"]}
{"type":"AmplifyShaderEditor.OneMinusNode, AmplifyShaderEditor","id":251,"pos":[-3536,2560],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":263,"pos":[-3280,2688],"params":["Inherit","False","Property","_SideFadeMultiply","Side Fade Multiply","22","0","Create","True","0","0","0","False","0","False","Object","-1","","1.15","1.15","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":457,"pos":[-6912,-512],"params":["Inherit","False","TextureAlpha","-1","True","1","0","COLOR","0,0,0,0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":458,"pos":[-8704,-384],"params":["Inherit","False","Flipbook Tile","-1","True","1","0","FLOAT2","0,0","False","1","FLOAT2","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":252,"pos":[-3280,2560],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","2","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor","id":459,"pos":[-2432,640],"params":["Inherit","False","0","-1","2","3","2","SAMPLER2D","","False","0","FLOAT2","1,1","False","1","FLOAT2","0,0","False","5","FLOAT2","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":460,"pos":[-2176,768],"params":["Inherit","False","458","Flipbook Tile","1","0","OBJECT","","False","1","FLOAT2","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":461,"pos":[-1920,256],"params":["Inherit","False","457","TextureAlpha","1","0","OBJECT","","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":262,"pos":[-3024,2560],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":256,"pos":[-2768,2816],"params":["Inherit","False","Property","_SideFadeMax","Side Fade Max","24","0","Create","True","0","0","0","False","0","False","Object","-1","","1","1","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":255,"pos":[-2768,2688],"params":["Inherit","False","Property","_SideFadeMin","Side Fade Min","23","0","Create","True","0","0","0","False","0","False","Object","-1","","0","0","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.BreakToComponentsNode, AmplifyShaderEditor","id":462,"pos":[-1664,256],"params":["Inherit","False","COLOR","1","0","COLOR","0,0,0,0","False","16","FLOAT","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT","5","FLOAT","6","FLOAT","7","FLOAT","8","FLOAT","9","FLOAT","10","FLOAT","11","FLOAT","12","FLOAT","13","FLOAT","14","FLOAT","15"]}
{"type":"AmplifyShaderEditor.VertexColorNode, AmplifyShaderEditor","id":463,"pos":[-1920,-512],"params":["Inherit","False","0","5","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":464,"pos":[-2176,640],"params":["Inherit","False","2","2","0","FLOAT2","0,0","False","1","FLOAT2","0,0","False","1","FLOAT2","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":465,"pos":[-1792,1024],"params":["Inherit","False","Property","_OpacityCutoutSmoothness","Opacity Cutout Smoothness","18","0","Create","True","0","0","0","False","0","False","Object","-1","","0.01","0.01","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.LerpOp, AmplifyShaderEditor","id":254,"pos":[-2768,2560],"params":["Inherit","False","3","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":466,"pos":[-1792,896],"params":["Inherit","False","Property","_OpacityCutoutEro","Opacity Cutout Ero","17","0","Create","True","0","0","0","False","0","False","Object","-1","","0","0","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":467,"pos":[-1408,256],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor","id":468,"pos":[-1408,896],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor","id":469,"pos":[-1792,640],"params":["Inherit","True","Property","_OpacityCutout","Opacity Cutout","16","0","Create","True","0","0","0","False","3","Space(33)","Header(Opacity Cutout)","Space(13)","False","","-1","d981c863a6701424eb185510d6ea29d0","d981c863a6701424eb185510d6ea29d0","True","0","False","white","Auto","False","Object","-1","Auto","Texture2D","False","8","0","SAMPLER2D","","False","1","FLOAT2","0,0","False","2","FLOAT","0","False","3","FLOAT2","0,0","False","4","FLOAT2","0,0","False","5","FLOAT","1","False","6","FLOAT","0","False","7","SAMPLERSTATE","","False","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":240,"pos":[-2512,2560],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor","id":268,"pos":[-1712,2544],"params":["Inherit","False","804","418.95","Cam Fade","5","204","205","206","207","208","Cam Fade","0,0,0,1","0","0"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":470,"pos":[-1280,256],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SmoothstepOpNode, AmplifyShaderEditor","id":471,"pos":[-1408,640],"params":["Inherit","True","3","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","1","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.OneMinusNode, AmplifyShaderEditor","id":264,"pos":[-2256,2560],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":472,"pos":[-1024,256],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":265,"pos":[-2000,2560],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":204,"pos":[-1664,2720],"params":["Inherit","False","Property","_CamDepthFadeLength","Cam Depth Fade Length","19","0","Create","True","0","0","0","False","3","Space(33)","Header(Cam Depth Fade)","Space(13)","False","Object","-1","","1","5","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":205,"pos":[-1664,2848],"params":["Inherit","False","Property","_CamDepthFadeOffset","Cam Depth Fade Offset","20","0","Create","True","0","0","0","False","0","False","Object","-1","","0","1","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":475,"pos":[-896,256],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.CameraDepthFade, AmplifyShaderEditor","id":206,"pos":[-1664,2592],"params":["Inherit","False","3","2","FLOAT3","0,0,0","False","0","FLOAT","1","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":104,"pos":[-1664,1920],"params":["Inherit","True","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":231,"pos":[-1920,1536],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":207,"pos":[-1408,2592],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":237,"pos":[-1408,1664],"params":["Inherit","False","Property","_UseSideFade","Use Side Fade","21","0","Create","True","0","0","0","False","0","False","Object","-1","","1","1","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":165,"pos":[-1408,1920],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":208,"pos":[-1152,2592],"params":["Inherit","False","camFade","-1","True","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.LerpOp, AmplifyShaderEditor","id":236,"pos":[-1408,1536],"params":["Inherit","False","3","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":210,"pos":[-768,1408],"params":["Inherit","False","208","camFade","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":266,"pos":[-1152,1536],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":473,"pos":[-640,512],"params":["Inherit","False","Property","_DepthFade","Depth Fade","10","0","Create","True","0","0","0","False","0","False","Object","-1","","1","1","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":211,"pos":[-768,1280],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.DepthFade, AmplifyShaderEditor","id":474,"pos":[-640,384],"params":["Inherit","False","True","True","False","2","1","FLOAT3","0,0,0","False","0","FLOAT","1","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":209,"pos":[-384,1280],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor","id":49,"pos":[459.26,31.68577],"params":["Inherit","False","1238","166","Auto Register Variables","5","54","53","52","51","50","Lush was here! <3","0.4872068,0.2971698,1,1","0","0"]}
{"type":"AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor","id":476,"pos":[-6352,-192],"params":["Inherit","False","2386.335","1605.285","Lightmap Calculation","21","518","517","516","515","514","513","512","511","510","509","508","507","506","505","504","503","502","501","500","499","498","Lightmap Calculation","0,0,0,1","0","0"]}
{"type":"AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor","id":477,"pos":[-6352,-1136],"params":["Inherit","False","4046.4","887.45","Light Contribution Textures","25","543","542","541","540","539","538","537","536","535","534","533","532","531","530","529","528","527","526","525","524","523","522","521","520","519","Light Contribution Textures","0,0,0,1","0","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":478,"pos":[-640,256],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.StickyNoteNode, AmplifyShaderEditor","id":479,"pos":[-9120,-1792],"params":["Inherit","False","670.2373","514.3649","Super Secret Hack","","1,1,1,1","prevent nextFrameUV from wrapping around the flipbook","0","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":50,"pos":[507.2599,79.68589],"params":["Inherit","False","Property","_Cull1","Cull","25","0","Create","True","0","0","0","True","3","Space(13)","Header(AR)","Space(13)","False","Object","-1","","2","2","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":51,"pos":[763.2599,79.68589],"params":["Inherit","False","Property","_Src1","Src","26","0","Create","True","0","0","0","True","0","False","Object","-1","","5","5","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":52,"pos":[1019.26,79.68589],"params":["Inherit","False","Property","_Dst1","Dst","27","0","Create","True","0","0","0","True","0","False","Object","-1","","10","10","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":53,"pos":[1531.26,79.68589],"params":["Inherit","False","Property","_ZTest1","ZTest","29","0","Create","True","0","0","0","True","0","False","Object","-1","","2","2","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":54,"pos":[1275.26,79.68589],"params":["Inherit","False","Property","_ZWrite1","ZWrite","28","0","Create","True","0","0","0","True","0","False","Object","-1","","0","0","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.ColorNode, AmplifyShaderEditor","id":480,"pos":[-1920,-1664],"params":["Inherit","False","Property","_Color01","Color 01","5","0","Create","True","0","0","0","False","0","False","Object","-1","","0.945098,0.7137255,0.427451,1","0.945098,0.7137255,0.427451,1","True","True","0","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.ColorNode, AmplifyShaderEditor","id":481,"pos":[-1920,-1408],"params":["Inherit","False","Property","_Color02","Color 02","6","0","Create","True","0","0","0","False","0","False","Object","-1","","0.6588235,0.3803922,0.227451,1","0.6588235,0.3803921,0.2274509,1","True","True","0","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.LerpOp, AmplifyShaderEditor","id":482,"pos":[-1024,-1664],"params":["Inherit","True","3","0","FLOAT3","0,0,0","False","1","FLOAT3","0,0,0","False","2","FLOAT","0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.LerpOp, AmplifyShaderEditor","id":483,"pos":[-1408,-1408],"params":["Inherit","True","3","0","FLOAT3","0,0,0","False","1","FLOAT3","0,0,0","False","2","FLOAT","0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":484,"pos":[-640,-128],"params":["Inherit","False","Property","_Emission","Emission","9","0","Create","True","0","0","0","False","0","False","Object","-1","","0.1","1","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":485,"pos":[-640,-256],"params":["Inherit","False","2","2","0","COLOR","0,0,0,0","False","1","FLOAT","0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":486,"pos":[-640,-512],"params":["Inherit","False","2","2","0","FLOAT3","0,0,0","False","1","COLOR","0,0,0,0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":487,"pos":[-1920,-1024],"params":["Inherit","False","Constant","_Float1","Float 1","15","0","Create","True","0","0","0","False","0","False","Object","-1","","1","0","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.LerpOp, AmplifyShaderEditor","id":488,"pos":[-1664,-1024],"params":["Inherit","False","3","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":489,"pos":[-1920,-896],"params":["Inherit","False","504","lightmap","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.LerpOp, AmplifyShaderEditor","id":490,"pos":[-1408,-1024],"params":["Inherit","False","3","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":491,"pos":[-512,256],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":492,"pos":[-640,0],"params":["Inherit","False","Property","_Specular","Specular","7","0","Create","True","0","0","0","False","0","False","Object","-1","","0","0","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":493,"pos":[-640,128],"params":["Inherit","False","Property","_Smoothness","Smoothness","8","0","Create","True","0","0","0","False","0","False","Object","-1","","0","0","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":494,"pos":[-1408,-896],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":495,"pos":[-1664,-896],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":496,"pos":[-1920,-768],"params":["Inherit","False","Property","_LightContribution","Light Contribution","3","0","Create","True","0","0","0","False","0","False","Object","-1","","1","1","0","1","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":497,"pos":[-1408,-768],"params":["Inherit","False","Property","_LitBySun","Lit By Sun","2","0","Create","True","0","0","0","False","3","Space(33)","Header(Lighting)","Space(13)","False","Object","-1","","1","1","0","1","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.WorldSpaceLightDirHlpNode, AmplifyShaderEditor","id":498,"pos":[-6272,512],"params":["Inherit","False","True","1","0","FLOAT","0","False","4","FLOAT3","0","FLOAT","1","FLOAT","2","FLOAT","3"]}
{"type":"AmplifyShaderEditor.BreakToComponentsNode, AmplifyShaderEditor","id":499,"pos":[-5632,512],"params":["Inherit","False","FLOAT3","1","0","FLOAT3","0,0,0","False","16","FLOAT","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT","5","FLOAT","6","FLOAT","7","FLOAT","8","FLOAT","9","FLOAT","10","FLOAT","11","FLOAT","12","FLOAT","13","FLOAT","14","FLOAT","15"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":500,"pos":[-4992,-128],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":501,"pos":[-5248,-128],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":502,"pos":[-4992,512],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":503,"pos":[-5248,512],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.ConditionalIfNode, AmplifyShaderEditor","id":505,"pos":[-4992,0],"params":["Inherit","False","False","5","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","0","False","3","FLOAT","0","False","4","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":506,"pos":[-5248,128],"params":["Inherit","False","538","right","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":507,"pos":[-5248,16],"params":["Inherit","False","541","left","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.ConditionalIfNode, AmplifyShaderEditor","id":508,"pos":[-4992,640],"params":["Inherit","False","False","5","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","0","False","3","FLOAT","0","False","4","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":509,"pos":[-5248,640],"params":["Inherit","False","540","top","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":510,"pos":[-5248,768],"params":["Inherit","False","539","bottom","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":511,"pos":[-4992,1024],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":512,"pos":[-5248,1024],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.ConditionalIfNode, AmplifyShaderEditor","id":513,"pos":[-4992,1152],"params":["Inherit","False","False","5","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","0","False","3","FLOAT","0","False","4","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":514,"pos":[-5248,1152],"params":["Inherit","False","529","front","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor","id":516,"pos":[-4736,-128],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor","id":517,"pos":[-4608,512],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.TransformDirectionNode, AmplifyShaderEditor","id":518,"pos":[-5888,512],"params":["Inherit","False","World","Tangent","True","Fast","False","1","0","FLOAT3","0,0,0","False","4","FLOAT3","0","FLOAT","1","FLOAT","2","FLOAT","3"]}
{"type":"AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor","id":520,"pos":[-2816,-896],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":521,"pos":[-3456,-1024],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":522,"pos":[-3328,-1024],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":523,"pos":[-3200,-1024],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleDivideOpNode, AmplifyShaderEditor","id":524,"pos":[-3072,-1024],"params":["Inherit","False","2","0","FLOAT","0","False","1","FLOAT","2","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":525,"pos":[-3584,-1024],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.OneMinusNode, AmplifyShaderEditor","id":526,"pos":[-3584,-768],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleDivideOpNode, AmplifyShaderEditor","id":527,"pos":[-3328,-768],"params":["Inherit","False","2","0","FLOAT","0","False","1","FLOAT","4","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":528,"pos":[-3120,-768],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":529,"pos":[-3840,-896],"params":["Inherit","False","front","-1","True","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.PowerNode, AmplifyShaderEditor","id":530,"pos":[-3968,-896],"params":["Inherit","False","True","2","0","FLOAT","0","False","1","FLOAT","0.625","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleDivideOpNode, AmplifyShaderEditor","id":531,"pos":[-4096,-896],"params":["Inherit","False","2","0","FLOAT","0","False","1","FLOAT","4","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor","id":532,"pos":[-4224,-896],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor","id":533,"pos":[-4736,-1024],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor","id":534,"pos":[-4736,-512],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.BreakToComponentsNode, AmplifyShaderEditor","id":536,"pos":[-6016,-768],"params":["Inherit","False","COLOR","1","0","COLOR","0,0,0,0","False","16","FLOAT","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT","5","FLOAT","6","FLOAT","7","FLOAT","8","FLOAT","9","FLOAT","10","FLOAT","11","FLOAT","12","FLOAT","13","FLOAT","14","FLOAT","15"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":537,"pos":[-6016,-1024],"params":["Inherit","False","Property","_HorizontalFlip","Horizontal Flip","4","0","Create","True","0","0","0","False","0","False","Object","-1","","0","1","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":538,"pos":[-4992,-1024],"params":["Inherit","False","right","-1","True","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":539,"pos":[-4992,-384],"params":["Inherit","False","bottom","-1","True","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":540,"pos":[-4992,-512],"params":["Inherit","False","top","-1","True","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":541,"pos":[-4992,-896],"params":["Inherit","False","left","-1","True","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.ConditionalIfNode, AmplifyShaderEditor","id":542,"pos":[-5248,-768],"params":["Inherit","False","False","5","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","0","False","3","FLOAT","0","False","4","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.ConditionalIfNode, AmplifyShaderEditor","id":543,"pos":[-5248,-1024],"params":["Inherit","False","False","5","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","0","False","3","FLOAT","0","False","4","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":544,"pos":[-8064,-896],"params":["Inherit","False","548","Flipbook","1","0","OBJECT","","False","1","SAMPLER2D","0"]}
{"type":"AmplifyShaderEditor.LerpOp, AmplifyShaderEditor","id":545,"pos":[-7424,-1024],"params":["Inherit","False","3","0","COLOR","0,0,0,0","False","1","COLOR","0,0,0,0","False","2","FLOAT","0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":546,"pos":[-7424,-896],"params":["Inherit","False","440","ShurikenBlendFactor","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":547,"pos":[-6912,-1024],"params":["Inherit","False","TextureColor","-1","True","1","0","COLOR","0,0,0,0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":548,"pos":[-9728,-3072],"params":["Inherit","False","Flipbook","-1","True","1","0","SAMPLER2D","","False","1","SAMPLER2D","0"]}
{"type":"AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor","id":549,"pos":[-7808,-1024],"params":["Inherit","True","Property","_TextureSample1","Texture Sample 1","0","0","Create","True","0","0","0","False","0","False","","-1","None","None","True","0","False","white","Auto","False","Instance","-1","Auto","Texture2D","False","8","0","SAMPLER2D","","False","1","FLOAT2","0,0","False","2","FLOAT","0","False","3","FLOAT2","0,0","False","4","FLOAT2","0,0","False","5","FLOAT","1","False","6","FLOAT","0","False","7","SAMPLERSTATE","","False","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor","id":550,"pos":[-7808,-768],"params":["Inherit","True","Property","_TextureSample0","Texture Sample 0","0","0","Create","True","0","0","0","False","0","False","","-1","None","None","True","0","False","white","Auto","False","Instance","-1","Auto","Texture2D","False","8","0","SAMPLER2D","","False","1","FLOAT2","0,0","False","2","FLOAT","0","False","3","FLOAT2","0,0","False","4","FLOAT2","0,0","False","5","FLOAT","1","False","6","FLOAT","0","False","7","SAMPLERSTATE","","False","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor","id":551,"pos":[-10112,-3072],"params":["Inherit","True","Property","_MDC","MDC","0","0","Create","True","0","0","0","False","3","Space(33)","Header(MDC)","Space(13)","False","","None","None","False","white","Auto","Texture2D","False","-1","0","2","SAMPLER2D","0","SAMPLERSTATE","1"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":504,"pos":[-4352,512],"params":["Inherit","False","lightmap","-1","True","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":519,"pos":[-2688,-896],"params":["Inherit","False","back","-1","True","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":515,"pos":[-5248,1280],"params":["Inherit","False","519","back","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":535,"pos":[-6272,-768],"params":["Inherit","False","547","TextureColor","1","0","OBJECT","","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":91,"pos":[0,0],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphLitGUI","0","1","New Amplify Shader","94348b07e5e8bab40bd6c8a1e3df54cd","True","ExtraPrePass","0","0","ExtraPrePass","6","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","False","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","4","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Lit","True","3","True","12","all","0","False","True","1","1","False","","0","False","","0","1","False","","0","False","","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","0","False","False","0","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":93,"pos":[0,0],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphLitGUI","0","1","New Amplify Shader","94348b07e5e8bab40bd6c8a1e3df54cd","True","ShadowCaster","0","2","ShadowCaster","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","False","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","4","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Lit","True","3","True","12","all","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","False","False","True","False","False","False","False","0","False","","False","False","False","False","False","False","False","False","False","True","1","False","","True","3","False","","False","False","True","1","LightMode=ShadowCaster","False","False","0","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":94,"pos":[0,0],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphLitGUI","0","1","New Amplify Shader","94348b07e5e8bab40bd6c8a1e3df54cd","True","DepthOnly","0","3","DepthOnly","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","False","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","4","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Lit","True","3","True","12","all","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","False","False","True","False","False","False","False","0","False","","False","False","False","False","False","False","False","False","False","True","1","False","","False","False","False","True","1","LightMode=DepthOnly","False","False","0","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":95,"pos":[0,0],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphLitGUI","0","1","New Amplify Shader","94348b07e5e8bab40bd6c8a1e3df54cd","True","Meta","0","4","Meta","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","False","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","4","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Lit","True","3","True","12","all","0","False","False","False","False","False","False","False","False","False","False","False","False","False","False","True","2","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","True","1","LightMode=Meta","False","False","0","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":96,"pos":[0,0],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphLitGUI","0","1","New Amplify Shader","94348b07e5e8bab40bd6c8a1e3df54cd","True","Universal2D","0","5","Universal2D","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","False","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","4","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Lit","True","3","True","12","all","0","False","True","1","5","True","_Src1","10","True","_Dst1","2","5","False","","10","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","False","False","True","1","True","","True","3","True","","True","True","0","False","","0","False","","False","True","1","LightMode=Universal2D","False","False","0","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":97,"pos":[0,0],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphLitGUI","0","1","New Amplify Shader","94348b07e5e8bab40bd6c8a1e3df54cd","True","DepthNormals","0","6","DepthNormals","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","False","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","4","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Lit","True","3","True","12","all","0","False","True","1","1","False","","0","False","","0","1","False","","0","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","True","1","False","","True","3","False","","False","False","True","1","LightMode=DepthNormals","False","False","0","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":98,"pos":[0,0],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphLitGUI","0","1","New Amplify Shader","94348b07e5e8bab40bd6c8a1e3df54cd","True","GBuffer","0","7","GBuffer","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","False","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","4","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Lit","True","3","True","12","all","0","False","True","1","5","True","_Src1","10","True","_Dst1","2","5","False","","10","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","True","","True","3","True","","True","True","0","False","","0","False","","False","True","1","LightMode=UniversalGBuffer","False","True","10","d3d11","gles","metal","vulkan","xboxone","xboxseries","playstation","ps4","ps5","switch","0","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":99,"pos":[0,0],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphLitGUI","0","1","New Amplify Shader","94348b07e5e8bab40bd6c8a1e3df54cd","True","SceneSelectionPass","0","8","SceneSelectionPass","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","False","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","4","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Lit","True","3","True","12","all","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","2","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","True","1","LightMode=SceneSelectionPass","False","False","0","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":100,"pos":[0,0],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphLitGUI","0","1","New Amplify Shader","94348b07e5e8bab40bd6c8a1e3df54cd","True","ScenePickingPass","0","9","ScenePickingPass","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","False","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","4","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Lit","True","3","True","12","all","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","True","1","LightMode=Picking","False","False","0","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":92,"pos":[0,0],"params":["Float","False","True","-1","2","UnityEditor.ShaderGraphLitGUI","0","15","Vefects/SH_Vefects_URP_VFX_Ambient_Sand_MV_New","94348b07e5e8bab40bd6c8a1e3df54cd","True","Forward","0","1","Forward","21","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","True","True","0","True","_Cull1","False","False","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","True","True","2","True","_ZWrite1","True","3","True","_ZTest1","True","True","0","False","","0","False","","False","True","4","RenderPipeline=UniversalPipeline","RenderType=Transparent=RenderType","Queue=Transparent=Queue=0","UniversalMaterialType=Lit","True","4","True","12","all","0","True","True","1","5","True","_Src1","10","True","_Dst1","2","5","False","","10","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","True","True","1","True","_ZWrite1","True","3","True","_ZTest1","True","True","0","False","","0","False","","False","True","1","LightMode=UniversalForward","False","False","0","","0","0","Standard","48","Category","0","0","  Instanced Terrain Normals","1","0","Lighting Model","0","0","Workflow","0","638489975902210172","Surface","1","638489974111807992","  Keep Alpha","0","0","  Refraction Model","0","0","  Blend","0","0","Two Sided","1","0","Alpha Clipping","0","638726435652633129","  Use Shadow Threshold","0","0","Fragment Normal Space","0","0","Forward Only","0","0","Transmission","0","0","  Transmission Shadow","0.5,False,","0","Translucency","0","0","  Translucency Strength","1,False,","0","  Normal Distortion","0.5,False,","0","  Scattering","2,False,","0","  Direct","0.9,False,","0","  Ambient","0.1,False,","0","  Shadow","0.5,False,","0","Cast Shadows","1","0","Receive Shadows","1","0","Specular Highlights","2","0","Environment Reflections","2","0","Receive SSAO","1","0","GPU Instancing","1","0","LOD CrossFade","1","0","Built-in Fog","1","0","_FinalColorxAlpha","0","0","Meta Pass","1","0","Override Baked GI","0","0","Extra Pre Pass","0","0","Tessellation","0","0","  Phong","0","0","  Strength","0.5,False,","0","  Type","0","0","  Tess","16,False,","0","  Min","10,False,","0","  Max","25,False,","0","  Edge Length","16,False,","0","  Max Displacement","25,False,","0","Write Depth","0","0","  Conservative","0","0","Vertex Position","1","0","Debug Display","0","0","Clear Coat","0","0","0","10","False","True","True","True","True","True","True","True","True","True","False","","False","0"]}
{"wire":[420,0,418,0]}
{"wire":[420,1,417,0]}
{"wire":[421,0,420,0]}
{"wire":[424,0,422,4]}
{"wire":[428,0,425,1]}
{"wire":[428,1,425,2]}
{"wire":[430,0,426,0]}
{"wire":[423,0,422,1]}
{"wire":[423,1,422,2]}
{"wire":[432,0,429,0]}
{"wire":[432,1,430,0]}
{"wire":[432,2,431,0]}
{"wire":[432,3,431,0]}
{"wire":[432,4,428,0]}
{"wire":[434,0,433,0]}
{"wire":[431,0,423,0]}
{"wire":[435,0,432,0]}
{"wire":[440,0,422,3]}
{"wire":[438,0,436,0]}
{"wire":[438,1,437,0]}
{"wire":[242,0,241,0]}
{"wire":[242,1,247,0]}
{"wire":[445,0,438,1]}
{"wire":[445,1,438,2]}
{"wire":[448,0,436,0]}
{"wire":[448,1,439,0]}
{"wire":[447,0,441,0]}
{"wire":[244,0,242,0]}
{"wire":[451,1,442,0]}
{"wire":[451,2,443,0]}
{"wire":[451,3,448,0]}
{"wire":[451,4,445,0]}
{"wire":[451,5,449,0]}
{"wire":[451,6,444,0]}
{"wire":[451,7,418,0]}
{"wire":[451,8,417,0]}
{"wire":[451,9,446,0]}
{"wire":[249,0,248,0]}
{"wire":[249,1,244,0]}
{"wire":[453,0,450,0]}
{"wire":[453,1,451,12]}
{"wire":[454,0,450,0]}
{"wire":[454,1,451,11]}
{"wire":[250,0,249,0]}
{"wire":[455,0,454,0]}
{"wire":[455,1,453,0]}
{"wire":[455,2,452,0]}
{"wire":[456,0,418,0]}
{"wire":[456,1,417,0]}
{"wire":[251,0,250,0]}
{"wire":[457,0,455,0]}
{"wire":[458,0,456,0]}
{"wire":[252,0,251,0]}
{"wire":[252,1,263,0]}
{"wire":[262,0,252,0]}
{"wire":[462,0,461,0]}
{"wire":[464,0,459,0]}
{"wire":[464,1,460,0]}
{"wire":[254,0,255,0]}
{"wire":[254,1,256,0]}
{"wire":[254,2,262,0]}
{"wire":[467,0,463,4]}
{"wire":[467,1,462,3]}
{"wire":[468,0,466,0]}
{"wire":[468,1,465,0]}
{"wire":[469,1,464,0]}
{"wire":[240,0,254,0]}
{"wire":[470,0,467,0]}
{"wire":[471,0,469,2]}
{"wire":[471,1,466,0]}
{"wire":[471,2,468,0]}
{"wire":[264,0,240,0]}
{"wire":[472,0,470,0]}
{"wire":[472,1,471,0]}
{"wire":[265,0,264,0]}
{"wire":[475,0,472,0]}
{"wire":[206,0,204,0]}
{"wire":[206,1,205,0]}
{"wire":[104,0,231,0]}
{"wire":[104,1,265,0]}
{"wire":[231,0,475,0]}
{"wire":[207,0,206,0]}
{"wire":[165,0,104,0]}
{"wire":[208,0,207,0]}
{"wire":[236,0,231,0]}
{"wire":[236,1,165,0]}
{"wire":[236,2,237,0]}
{"wire":[266,0,236,0]}
{"wire":[211,0,266,0]}
{"wire":[211,1,210,0]}
{"wire":[474,0,473,0]}
{"wire":[209,0,211,0]}
{"wire":[478,0,209,0]}
{"wire":[478,1,474,0]}
{"wire":[482,0,481,5]}
{"wire":[482,1,483,0]}
{"wire":[482,2,462,3]}
{"wire":[483,0,480,5]}
{"wire":[483,1,481,5]}
{"wire":[483,2,490,0]}
{"wire":[485,0,486,0]}
{"wire":[485,1,484,0]}
{"wire":[486,0,482,0]}
{"wire":[486,1,463,0]}
{"wire":[488,0,487,0]}
{"wire":[488,1,489,0]}
{"wire":[488,2,495,0]}
{"wire":[490,0,462,1]}
{"wire":[490,1,488,0]}
{"wire":[490,2,494,0]}
{"wire":[491,0,478,0]}
{"wire":[494,0,497,0]}
{"wire":[495,0,496,0]}
{"wire":[499,0,518,0]}
{"wire":[500,0,501,0]}
{"wire":[500,1,505,0]}
{"wire":[501,0,499,0]}
{"wire":[501,1,499,0]}
{"wire":[502,0,503,0]}
{"wire":[502,1,508,0]}
{"wire":[503,0,499,1]}
{"wire":[503,1,499,1]}
{"wire":[505,0,499,0]}
{"wire":[505,2,507,0]}
{"wire":[505,4,506,0]}
{"wire":[508,0,499,1]}
{"wire":[508,2,509,0]}
{"wire":[508,4,510,0]}
{"wire":[511,0,512,0]}
{"wire":[511,1,513,0]}
{"wire":[512,0,499,2]}
{"wire":[512,1,499,2]}
{"wire":[513,0,499,2]}
{"wire":[513,2,514,0]}
{"wire":[513,4,515,0]}
{"wire":[516,0,500,0]}
{"wire":[516,1,502,0]}
{"wire":[517,0,516,0]}
{"wire":[517,1,511,0]}
{"wire":[518,0,498,0]}
{"wire":[520,0,524,0]}
{"wire":[520,1,528,0]}
{"wire":[521,0,525,0]}
{"wire":[521,1,525,0]}
{"wire":[522,0,521,0]}
{"wire":[522,1,521,0]}
{"wire":[523,0,522,0]}
{"wire":[523,1,522,0]}
{"wire":[524,0,523,0]}
{"wire":[525,0,529,0]}
{"wire":[525,1,529,0]}
{"wire":[526,0,529,0]}
{"wire":[527,0,526,0]}
{"wire":[528,0,527,0]}
{"wire":[529,0,530,0]}
{"wire":[530,0,531,0]}
{"wire":[531,0,532,0]}
{"wire":[532,0,533,0]}
{"wire":[532,1,534,0]}
{"wire":[533,0,538,0]}
{"wire":[533,1,541,0]}
{"wire":[534,0,540,0]}
{"wire":[534,1,539,0]}
{"wire":[536,0,535,0]}
{"wire":[538,0,543,0]}
{"wire":[539,0,536,3]}
{"wire":[540,0,536,2]}
{"wire":[541,0,542,0]}
{"wire":[542,0,537,0]}
{"wire":[542,2,536,0]}
{"wire":[542,4,536,1]}
{"wire":[543,0,537,0]}
{"wire":[543,2,536,1]}
{"wire":[543,4,536,0]}
{"wire":[545,0,549,0]}
{"wire":[545,1,550,0]}
{"wire":[545,2,546,0]}
{"wire":[547,0,545,0]}
{"wire":[548,0,551,0]}
{"wire":[549,0,544,0]}
{"wire":[549,1,451,11]}
{"wire":[550,0,544,0]}
{"wire":[550,1,451,12]}
{"wire":[504,0,517,0]}
{"wire":[519,0,520,0]}
{"wire":[92,0,486,0]}
{"wire":[92,9,492,0]}
{"wire":[92,4,493,0]}
{"wire":[92,2,485,0]}
{"wire":[92,6,491,0]}
ASEEND*/
//CHKSM=06E47E76C1B0CA366D79CEA1D57D2A47CB1B0BA8