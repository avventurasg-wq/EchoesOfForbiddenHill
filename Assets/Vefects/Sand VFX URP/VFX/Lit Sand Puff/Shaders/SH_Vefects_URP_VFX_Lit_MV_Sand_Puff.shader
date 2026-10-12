// Made with Amplify Shader Editor v1.9.9.12
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Vefects/SH_Vefects_URP_VFX_Lit_MV_Sand_Puff"
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
		[Space(33)][Header(AR)][Space(13)] _Cull( "Cull", Float ) = 2
		_Src( "Src", Float ) = 5
		_Dst( "Dst", Float ) = 10
		_ZWrite( "ZWrite", Float ) = 0
		_ZTest( "ZTest", Float ) = 2


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

		Cull Back
		ZWrite Off
		ZTest [_ZTest]
		Offset 0 , 0
		AlphaToMask Off

		

		HLSLINCLUDE
		#pragma target 4.5
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

			Blend [_Src] [_Dst], One OneMinusSrcAlpha
			ZWrite [_ZWrite]
			ZTest [_ZTest]
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Color02;
			float4 _Color01;
			float _Cull;
			float _OpacityCutoutEro;
			float _Emission;
			float _Smoothness;
			float _Specular;
			float _LitBySun;
			float _LightContribution;
			float _HorizontalFlip;
			float _EncodedMotionIntensity;
			float _OpacityCutoutSmoothness;
			float _Rows;
			float _Columns;
			float _ZTest;
			float _ZWrite;
			float _Dst;
			float _Src;
			float _MotionIntensity;
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

				output.ase_texcoord6 = input.texcoord;
				output.ase_texcoord7 = input.texcoord1;
				output.ase_color = input.ase_color;

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

				float localComputeMotionFlow369 = ( 0.0 );
				float4 appendResult334 = (float4(input.ase_texcoord6.x , input.ase_texcoord6.y , 0.0 , 0.0));
				float4 ShurikenCurrentFrame333 = appendResult334;
				float2 currentFrameUV369 = ShurikenCurrentFrame333.xy;
				float ShurikenFrameIndex418 = input.ase_texcoord6.w;
				float FlipbookSize420 = ( _Columns * _Rows );
				float4 appendResult331 = (float4(input.ase_texcoord7.x , input.ase_texcoord7.y , 0.0 , 0.0));
				float4 ifLocalVar416 = 0;
				if( ShurikenFrameIndex418 >= ( FlipbookSize420 - 1.0 ) )
				ifLocalVar416 = ShurikenCurrentFrame333;
				else
				ifLocalVar416 = appendResult331;
				float4 ShurikenNextFrame332 = ifLocalVar416;
				float2 nextFrameUV369 = ShurikenNextFrame332.xy;
				float4 currentMV369 = tex2D( _MotionVectors, ShurikenCurrentFrame333.xy );
				float4 tex2DNode374 = tex2D( _MotionVectors, ShurikenNextFrame332.xy );
				float2 appendResult372 = (float2(tex2DNode374.r , tex2DNode374.g));
				float2 nextMV369 = appendResult372;
				float isIntensityEncoded369 = _EncodedMotionIntensity;
				float motionIntensity369 = _MotionIntensity;
				float columns369 = _Columns;
				float rows369 = _Rows;
				float ShurikenBlendFactor336 = input.ase_texcoord6.z;
				float blendFactor369 = ShurikenBlendFactor336;
				float2 currentFrameMVUV369 = float2( 0,0 );
				float2 nextFrameMVUV369 = float2( 0,0 );
				ComputeMotionFlow_float( currentFrameUV369 , nextFrameUV369 , currentMV369 , nextMV369 , isIntensityEncoded369 , motionIntensity369 , columns369 , rows369 , blendFactor369 , currentFrameMVUV369 , nextFrameMVUV369 );
				float4 lerpResult396 = lerp( tex2D( _AOAlpha1, currentFrameMVUV369 ) , tex2D( _AOAlpha1, nextFrameMVUV369 ) , ShurikenBlendFactor336);
				float4 TextureAlpha401 = lerpResult396;
				float4 break297 = TextureAlpha401;
				float3x3 ase_worldToTangent = float3x3( TangentWS, BitangentWS, NormalWS );
				float3 worldToTangentDir99 = normalize( mul( ase_worldToTangent, SafeNormalize( _MainLightPosition.xyz ) ) );
				float3 break145 = worldToTangentDir99;
				float4 lerpResult364 = lerp( tex2D( _MDC, currentFrameMVUV369 ) , tex2D( _MDC, nextFrameMVUV369 ) , ShurikenBlendFactor336);
				float4 TextureColor400 = lerpResult364;
				float4 break288 = TextureColor400;
				float ifLocalVar96 = 0;
				if( _HorizontalFlip > 0.0 )
				ifLocalVar96 = break288.r;
				else if( _HorizontalFlip < 0.0 )
				ifLocalVar96 = break288.g;
				float left114 = ifLocalVar96;
				float ifLocalVar94 = 0;
				if( _HorizontalFlip > 0.0 )
				ifLocalVar94 = break288.g;
				else if( _HorizontalFlip < 0.0 )
				ifLocalVar94 = break288.r;
				float right113 = ifLocalVar94;
				float ifLocalVar102 = 0;
				if( break145.x > 0.0 )
				ifLocalVar102 = left114;
				else if( break145.x < 0.0 )
				ifLocalVar102 = right113;
				float top97 = break288.b;
				float bottom112 = break288.a;
				float ifLocalVar109 = 0;
				if( break145.y > 0.0 )
				ifLocalVar109 = top97;
				else if( break145.y < 0.0 )
				ifLocalVar109 = bottom112;
				float saferPower120 = abs( ( ( ( right113 + left114 ) + ( top97 + bottom112 ) ) / 4.0 ) );
				float front121 = pow( saferPower120 , 0.625 );
				float temp_output_122_0 = ( front121 * front121 );
				float temp_output_123_0 = ( temp_output_122_0 * temp_output_122_0 );
				float temp_output_124_0 = ( temp_output_123_0 * temp_output_123_0 );
				float back128 = ( ( ( temp_output_124_0 * temp_output_124_0 ) / 2.0 ) + saturate( ( ( 1.0 - front121 ) / 4.0 ) ) );
				float ifLocalVar110 = 0;
				if( break145.z > 0.0 )
				ifLocalVar110 = front121;
				else if( break145.z < 0.0 )
				ifLocalVar110 = back128;
				float lightmap106 = ( ( ( ( break145.x * break145.x ) * ifLocalVar102 ) + ( ( break145.y * break145.y ) * ifLocalVar109 ) ) + ( ( break145.z * break145.z ) * ifLocalVar110 ) );
				float lerpResult141 = lerp( 1.0 , lightmap106 , saturate( _LightContribution ));
				float lerpResult77 = lerp( break297.g , lerpResult141 , saturate( _LitBySun ));
				float3 lerpResult80 = lerp( _Color01.rgb , _Color02.rgb , lerpResult77);
				float3 lerpResult84 = lerp( _Color02.rgb , lerpResult80 , break297.a);
				float4 temp_output_81_0 = ( float4( lerpResult84 , 0.0 ) * input.ase_color );
				
				float3 temp_cast_7 = (_Specular).xxx;
				
				float2 texCoord454 = input.ase_texcoord6.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult459 = (float2(_Columns , _Rows));
				float2 Flipbook_Tile461 = appendResult459;
				float smoothstepResult457 = smoothstep( _OpacityCutoutEro , ( _OpacityCutoutEro + _OpacityCutoutSmoothness ) , tex2D( _OpacityCutout, ( texCoord454 * Flipbook_Tile461 ) ).g);
				float screenDepth75 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ScreenPosNorm.xy ),_ZBufferParams);
				float distanceDepth75 = saturate( ( screenDepth75 - LinearEyeDepth( ScreenPosNorm.z,_ZBufferParams ) ) / ( _DepthFade ) );
				

				float3 BaseColor = temp_output_81_0.rgb;
				float3 Normal = float3(0, 0, 1);
				float3 Specular = temp_cast_7;
				float Metallic = 0;
				float Smoothness = _Smoothness;
				float Occlusion = 1;
				float3 Emission = ( temp_output_81_0 * _Emission ).rgb;
				float Alpha = saturate( ( saturate( ( saturate( ( input.ase_color.a * break297.a ) ) * smoothstepResult457 ) ) * distanceDepth75 ) );
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Color02;
			float4 _Color01;
			float _Cull;
			float _OpacityCutoutEro;
			float _Emission;
			float _Smoothness;
			float _Specular;
			float _LitBySun;
			float _LightContribution;
			float _HorizontalFlip;
			float _EncodedMotionIntensity;
			float _OpacityCutoutSmoothness;
			float _Rows;
			float _Columns;
			float _ZTest;
			float _ZWrite;
			float _Dst;
			float _Src;
			float _MotionIntensity;
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

				output.ase_color = input.ase_color;
				output.ase_texcoord1 = input.ase_texcoord;
				output.ase_texcoord2 = input.ase_texcoord1;

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

				float localComputeMotionFlow369 = ( 0.0 );
				float4 appendResult334 = (float4(input.ase_texcoord1.x , input.ase_texcoord1.y , 0.0 , 0.0));
				float4 ShurikenCurrentFrame333 = appendResult334;
				float2 currentFrameUV369 = ShurikenCurrentFrame333.xy;
				float ShurikenFrameIndex418 = input.ase_texcoord1.w;
				float FlipbookSize420 = ( _Columns * _Rows );
				float4 appendResult331 = (float4(input.ase_texcoord2.x , input.ase_texcoord2.y , 0.0 , 0.0));
				float4 ifLocalVar416 = 0;
				if( ShurikenFrameIndex418 >= ( FlipbookSize420 - 1.0 ) )
				ifLocalVar416 = ShurikenCurrentFrame333;
				else
				ifLocalVar416 = appendResult331;
				float4 ShurikenNextFrame332 = ifLocalVar416;
				float2 nextFrameUV369 = ShurikenNextFrame332.xy;
				float4 currentMV369 = tex2D( _MotionVectors, ShurikenCurrentFrame333.xy );
				float4 tex2DNode374 = tex2D( _MotionVectors, ShurikenNextFrame332.xy );
				float2 appendResult372 = (float2(tex2DNode374.r , tex2DNode374.g));
				float2 nextMV369 = appendResult372;
				float isIntensityEncoded369 = _EncodedMotionIntensity;
				float motionIntensity369 = _MotionIntensity;
				float columns369 = _Columns;
				float rows369 = _Rows;
				float ShurikenBlendFactor336 = input.ase_texcoord1.z;
				float blendFactor369 = ShurikenBlendFactor336;
				float2 currentFrameMVUV369 = float2( 0,0 );
				float2 nextFrameMVUV369 = float2( 0,0 );
				ComputeMotionFlow_float( currentFrameUV369 , nextFrameUV369 , currentMV369 , nextMV369 , isIntensityEncoded369 , motionIntensity369 , columns369 , rows369 , blendFactor369 , currentFrameMVUV369 , nextFrameMVUV369 );
				float4 lerpResult396 = lerp( tex2D( _AOAlpha1, currentFrameMVUV369 ) , tex2D( _AOAlpha1, nextFrameMVUV369 ) , ShurikenBlendFactor336);
				float4 TextureAlpha401 = lerpResult396;
				float4 break297 = TextureAlpha401;
				float2 texCoord454 = input.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult459 = (float2(_Columns , _Rows));
				float2 Flipbook_Tile461 = appendResult459;
				float smoothstepResult457 = smoothstep( _OpacityCutoutEro , ( _OpacityCutoutEro + _OpacityCutoutSmoothness ) , tex2D( _OpacityCutout, ( texCoord454 * Flipbook_Tile461 ) ).g);
				float screenDepth75 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ScreenPosNorm.xy ),_ZBufferParams);
				float distanceDepth75 = saturate( ( screenDepth75 - LinearEyeDepth( ScreenPosNorm.z,_ZBufferParams ) ) / ( _DepthFade ) );
				

				float Alpha = saturate( ( saturate( ( saturate( ( input.ase_color.a * break297.a ) ) * smoothstepResult457 ) ) * distanceDepth75 ) );
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
			ColorMask R
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Color02;
			float4 _Color01;
			float _Cull;
			float _OpacityCutoutEro;
			float _Emission;
			float _Smoothness;
			float _Specular;
			float _LitBySun;
			float _LightContribution;
			float _HorizontalFlip;
			float _EncodedMotionIntensity;
			float _OpacityCutoutSmoothness;
			float _Rows;
			float _Columns;
			float _ZTest;
			float _ZWrite;
			float _Dst;
			float _Src;
			float _MotionIntensity;
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

				output.ase_color = input.ase_color;
				output.ase_texcoord1 = input.ase_texcoord;
				output.ase_texcoord2 = input.ase_texcoord1;

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

				float localComputeMotionFlow369 = ( 0.0 );
				float4 appendResult334 = (float4(input.ase_texcoord1.x , input.ase_texcoord1.y , 0.0 , 0.0));
				float4 ShurikenCurrentFrame333 = appendResult334;
				float2 currentFrameUV369 = ShurikenCurrentFrame333.xy;
				float ShurikenFrameIndex418 = input.ase_texcoord1.w;
				float FlipbookSize420 = ( _Columns * _Rows );
				float4 appendResult331 = (float4(input.ase_texcoord2.x , input.ase_texcoord2.y , 0.0 , 0.0));
				float4 ifLocalVar416 = 0;
				if( ShurikenFrameIndex418 >= ( FlipbookSize420 - 1.0 ) )
				ifLocalVar416 = ShurikenCurrentFrame333;
				else
				ifLocalVar416 = appendResult331;
				float4 ShurikenNextFrame332 = ifLocalVar416;
				float2 nextFrameUV369 = ShurikenNextFrame332.xy;
				float4 currentMV369 = tex2D( _MotionVectors, ShurikenCurrentFrame333.xy );
				float4 tex2DNode374 = tex2D( _MotionVectors, ShurikenNextFrame332.xy );
				float2 appendResult372 = (float2(tex2DNode374.r , tex2DNode374.g));
				float2 nextMV369 = appendResult372;
				float isIntensityEncoded369 = _EncodedMotionIntensity;
				float motionIntensity369 = _MotionIntensity;
				float columns369 = _Columns;
				float rows369 = _Rows;
				float ShurikenBlendFactor336 = input.ase_texcoord1.z;
				float blendFactor369 = ShurikenBlendFactor336;
				float2 currentFrameMVUV369 = float2( 0,0 );
				float2 nextFrameMVUV369 = float2( 0,0 );
				ComputeMotionFlow_float( currentFrameUV369 , nextFrameUV369 , currentMV369 , nextMV369 , isIntensityEncoded369 , motionIntensity369 , columns369 , rows369 , blendFactor369 , currentFrameMVUV369 , nextFrameMVUV369 );
				float4 lerpResult396 = lerp( tex2D( _AOAlpha1, currentFrameMVUV369 ) , tex2D( _AOAlpha1, nextFrameMVUV369 ) , ShurikenBlendFactor336);
				float4 TextureAlpha401 = lerpResult396;
				float4 break297 = TextureAlpha401;
				float2 texCoord454 = input.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult459 = (float2(_Columns , _Rows));
				float2 Flipbook_Tile461 = appendResult459;
				float smoothstepResult457 = smoothstep( _OpacityCutoutEro , ( _OpacityCutoutEro + _OpacityCutoutSmoothness ) , tex2D( _OpacityCutout, ( texCoord454 * Flipbook_Tile461 ) ).g);
				float screenDepth75 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ScreenPosNorm.xy ),_ZBufferParams);
				float distanceDepth75 = saturate( ( screenDepth75 - LinearEyeDepth( ScreenPosNorm.z,_ZBufferParams ) ) / ( _DepthFade ) );
				

				float Alpha = saturate( ( saturate( ( saturate( ( input.ase_color.a * break297.a ) ) * smoothstepResult457 ) ) * distanceDepth75 ) );
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
				float4 ase_texcoord8 : TEXCOORD8;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Color02;
			float4 _Color01;
			float _Cull;
			float _OpacityCutoutEro;
			float _Emission;
			float _Smoothness;
			float _Specular;
			float _LitBySun;
			float _LightContribution;
			float _HorizontalFlip;
			float _EncodedMotionIntensity;
			float _OpacityCutoutSmoothness;
			float _Rows;
			float _Columns;
			float _ZTest;
			float _ZWrite;
			float _Dst;
			float _Src;
			float _MotionIntensity;
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
				
				float4 ase_positionCS = TransformObjectToHClip( ( input.positionOS ).xyz );
				float4 screenPos = ComputeScreenPos( ase_positionCS );
				output.ase_texcoord8 = screenPos;
				
				output.ase_texcoord3 = input.texcoord;
				output.ase_texcoord4 = input.texcoord1;
				output.ase_color = input.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord5.w = 0;
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

				float localComputeMotionFlow369 = ( 0.0 );
				float4 appendResult334 = (float4(input.ase_texcoord3.x , input.ase_texcoord3.y , 0.0 , 0.0));
				float4 ShurikenCurrentFrame333 = appendResult334;
				float2 currentFrameUV369 = ShurikenCurrentFrame333.xy;
				float ShurikenFrameIndex418 = input.ase_texcoord3.w;
				float FlipbookSize420 = ( _Columns * _Rows );
				float4 appendResult331 = (float4(input.ase_texcoord4.x , input.ase_texcoord4.y , 0.0 , 0.0));
				float4 ifLocalVar416 = 0;
				if( ShurikenFrameIndex418 >= ( FlipbookSize420 - 1.0 ) )
				ifLocalVar416 = ShurikenCurrentFrame333;
				else
				ifLocalVar416 = appendResult331;
				float4 ShurikenNextFrame332 = ifLocalVar416;
				float2 nextFrameUV369 = ShurikenNextFrame332.xy;
				float4 currentMV369 = tex2D( _MotionVectors, ShurikenCurrentFrame333.xy );
				float4 tex2DNode374 = tex2D( _MotionVectors, ShurikenNextFrame332.xy );
				float2 appendResult372 = (float2(tex2DNode374.r , tex2DNode374.g));
				float2 nextMV369 = appendResult372;
				float isIntensityEncoded369 = _EncodedMotionIntensity;
				float motionIntensity369 = _MotionIntensity;
				float columns369 = _Columns;
				float rows369 = _Rows;
				float ShurikenBlendFactor336 = input.ase_texcoord3.z;
				float blendFactor369 = ShurikenBlendFactor336;
				float2 currentFrameMVUV369 = float2( 0,0 );
				float2 nextFrameMVUV369 = float2( 0,0 );
				ComputeMotionFlow_float( currentFrameUV369 , nextFrameUV369 , currentMV369 , nextMV369 , isIntensityEncoded369 , motionIntensity369 , columns369 , rows369 , blendFactor369 , currentFrameMVUV369 , nextFrameMVUV369 );
				float4 lerpResult396 = lerp( tex2D( _AOAlpha1, currentFrameMVUV369 ) , tex2D( _AOAlpha1, nextFrameMVUV369 ) , ShurikenBlendFactor336);
				float4 TextureAlpha401 = lerpResult396;
				float4 break297 = TextureAlpha401;
				float3 ase_tangentWS = input.ase_texcoord5.xyz;
				float3 ase_normalWS = input.ase_texcoord6.xyz;
				float3 ase_bitangentWS = input.ase_texcoord7.xyz;
				float3x3 ase_worldToTangent = float3x3( ase_tangentWS, ase_bitangentWS, ase_normalWS );
				float3 worldToTangentDir99 = normalize( mul( ase_worldToTangent, SafeNormalize( _MainLightPosition.xyz ) ) );
				float3 break145 = worldToTangentDir99;
				float4 lerpResult364 = lerp( tex2D( _MDC, currentFrameMVUV369 ) , tex2D( _MDC, nextFrameMVUV369 ) , ShurikenBlendFactor336);
				float4 TextureColor400 = lerpResult364;
				float4 break288 = TextureColor400;
				float ifLocalVar96 = 0;
				if( _HorizontalFlip > 0.0 )
				ifLocalVar96 = break288.r;
				else if( _HorizontalFlip < 0.0 )
				ifLocalVar96 = break288.g;
				float left114 = ifLocalVar96;
				float ifLocalVar94 = 0;
				if( _HorizontalFlip > 0.0 )
				ifLocalVar94 = break288.g;
				else if( _HorizontalFlip < 0.0 )
				ifLocalVar94 = break288.r;
				float right113 = ifLocalVar94;
				float ifLocalVar102 = 0;
				if( break145.x > 0.0 )
				ifLocalVar102 = left114;
				else if( break145.x < 0.0 )
				ifLocalVar102 = right113;
				float top97 = break288.b;
				float bottom112 = break288.a;
				float ifLocalVar109 = 0;
				if( break145.y > 0.0 )
				ifLocalVar109 = top97;
				else if( break145.y < 0.0 )
				ifLocalVar109 = bottom112;
				float saferPower120 = abs( ( ( ( right113 + left114 ) + ( top97 + bottom112 ) ) / 4.0 ) );
				float front121 = pow( saferPower120 , 0.625 );
				float temp_output_122_0 = ( front121 * front121 );
				float temp_output_123_0 = ( temp_output_122_0 * temp_output_122_0 );
				float temp_output_124_0 = ( temp_output_123_0 * temp_output_123_0 );
				float back128 = ( ( ( temp_output_124_0 * temp_output_124_0 ) / 2.0 ) + saturate( ( ( 1.0 - front121 ) / 4.0 ) ) );
				float ifLocalVar110 = 0;
				if( break145.z > 0.0 )
				ifLocalVar110 = front121;
				else if( break145.z < 0.0 )
				ifLocalVar110 = back128;
				float lightmap106 = ( ( ( ( break145.x * break145.x ) * ifLocalVar102 ) + ( ( break145.y * break145.y ) * ifLocalVar109 ) ) + ( ( break145.z * break145.z ) * ifLocalVar110 ) );
				float lerpResult141 = lerp( 1.0 , lightmap106 , saturate( _LightContribution ));
				float lerpResult77 = lerp( break297.g , lerpResult141 , saturate( _LitBySun ));
				float3 lerpResult80 = lerp( _Color01.rgb , _Color02.rgb , lerpResult77);
				float3 lerpResult84 = lerp( _Color02.rgb , lerpResult80 , break297.a);
				float4 temp_output_81_0 = ( float4( lerpResult84 , 0.0 ) * input.ase_color );
				
				float2 texCoord454 = input.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult459 = (float2(_Columns , _Rows));
				float2 Flipbook_Tile461 = appendResult459;
				float smoothstepResult457 = smoothstep( _OpacityCutoutEro , ( _OpacityCutoutEro + _OpacityCutoutSmoothness ) , tex2D( _OpacityCutout, ( texCoord454 * Flipbook_Tile461 ) ).g);
				float4 screenPos = input.ase_texcoord8;
				float4 ase_positionSSNorm = screenPos / screenPos.w;
				ase_positionSSNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_positionSSNorm.z : ase_positionSSNorm.z * 0.5 + 0.5;
				float screenDepth75 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_positionSSNorm.xy ),_ZBufferParams);
				float distanceDepth75 = saturate( ( screenDepth75 - LinearEyeDepth( ase_positionSSNorm.z,_ZBufferParams ) ) / ( _DepthFade ) );
				

				float3 BaseColor = temp_output_81_0.rgb;
				float3 Emission = ( temp_output_81_0 * _Emission ).rgb;
				float Alpha = saturate( ( saturate( ( saturate( ( input.ase_color.a * break297.a ) ) * smoothstepResult457 ) ) * distanceDepth75 ) );
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

			Blend [_Src] [_Dst], One OneMinusSrcAlpha
			ZWrite [_ZWrite]
			ZTest [_ZTest]
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
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Color02;
			float4 _Color01;
			float _Cull;
			float _OpacityCutoutEro;
			float _Emission;
			float _Smoothness;
			float _Specular;
			float _LitBySun;
			float _LightContribution;
			float _HorizontalFlip;
			float _EncodedMotionIntensity;
			float _OpacityCutoutSmoothness;
			float _Rows;
			float _Columns;
			float _ZTest;
			float _ZWrite;
			float _Dst;
			float _Src;
			float _MotionIntensity;
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
				
				float4 ase_positionCS = TransformObjectToHClip( ( input.positionOS ).xyz );
				float4 screenPos = ComputeScreenPos( ase_positionCS );
				output.ase_texcoord6 = screenPos;
				
				output.ase_texcoord1 = input.ase_texcoord;
				output.ase_texcoord2 = input.ase_texcoord1;
				output.ase_color = input.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord3.w = 0;
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

				float localComputeMotionFlow369 = ( 0.0 );
				float4 appendResult334 = (float4(input.ase_texcoord1.x , input.ase_texcoord1.y , 0.0 , 0.0));
				float4 ShurikenCurrentFrame333 = appendResult334;
				float2 currentFrameUV369 = ShurikenCurrentFrame333.xy;
				float ShurikenFrameIndex418 = input.ase_texcoord1.w;
				float FlipbookSize420 = ( _Columns * _Rows );
				float4 appendResult331 = (float4(input.ase_texcoord2.x , input.ase_texcoord2.y , 0.0 , 0.0));
				float4 ifLocalVar416 = 0;
				if( ShurikenFrameIndex418 >= ( FlipbookSize420 - 1.0 ) )
				ifLocalVar416 = ShurikenCurrentFrame333;
				else
				ifLocalVar416 = appendResult331;
				float4 ShurikenNextFrame332 = ifLocalVar416;
				float2 nextFrameUV369 = ShurikenNextFrame332.xy;
				float4 currentMV369 = tex2D( _MotionVectors, ShurikenCurrentFrame333.xy );
				float4 tex2DNode374 = tex2D( _MotionVectors, ShurikenNextFrame332.xy );
				float2 appendResult372 = (float2(tex2DNode374.r , tex2DNode374.g));
				float2 nextMV369 = appendResult372;
				float isIntensityEncoded369 = _EncodedMotionIntensity;
				float motionIntensity369 = _MotionIntensity;
				float columns369 = _Columns;
				float rows369 = _Rows;
				float ShurikenBlendFactor336 = input.ase_texcoord1.z;
				float blendFactor369 = ShurikenBlendFactor336;
				float2 currentFrameMVUV369 = float2( 0,0 );
				float2 nextFrameMVUV369 = float2( 0,0 );
				ComputeMotionFlow_float( currentFrameUV369 , nextFrameUV369 , currentMV369 , nextMV369 , isIntensityEncoded369 , motionIntensity369 , columns369 , rows369 , blendFactor369 , currentFrameMVUV369 , nextFrameMVUV369 );
				float4 lerpResult396 = lerp( tex2D( _AOAlpha1, currentFrameMVUV369 ) , tex2D( _AOAlpha1, nextFrameMVUV369 ) , ShurikenBlendFactor336);
				float4 TextureAlpha401 = lerpResult396;
				float4 break297 = TextureAlpha401;
				float3 ase_tangentWS = input.ase_texcoord3.xyz;
				float3 ase_normalWS = input.ase_texcoord4.xyz;
				float3 ase_bitangentWS = input.ase_texcoord5.xyz;
				float3x3 ase_worldToTangent = float3x3( ase_tangentWS, ase_bitangentWS, ase_normalWS );
				float3 worldToTangentDir99 = normalize( mul( ase_worldToTangent, SafeNormalize( _MainLightPosition.xyz ) ) );
				float3 break145 = worldToTangentDir99;
				float4 lerpResult364 = lerp( tex2D( _MDC, currentFrameMVUV369 ) , tex2D( _MDC, nextFrameMVUV369 ) , ShurikenBlendFactor336);
				float4 TextureColor400 = lerpResult364;
				float4 break288 = TextureColor400;
				float ifLocalVar96 = 0;
				if( _HorizontalFlip > 0.0 )
				ifLocalVar96 = break288.r;
				else if( _HorizontalFlip < 0.0 )
				ifLocalVar96 = break288.g;
				float left114 = ifLocalVar96;
				float ifLocalVar94 = 0;
				if( _HorizontalFlip > 0.0 )
				ifLocalVar94 = break288.g;
				else if( _HorizontalFlip < 0.0 )
				ifLocalVar94 = break288.r;
				float right113 = ifLocalVar94;
				float ifLocalVar102 = 0;
				if( break145.x > 0.0 )
				ifLocalVar102 = left114;
				else if( break145.x < 0.0 )
				ifLocalVar102 = right113;
				float top97 = break288.b;
				float bottom112 = break288.a;
				float ifLocalVar109 = 0;
				if( break145.y > 0.0 )
				ifLocalVar109 = top97;
				else if( break145.y < 0.0 )
				ifLocalVar109 = bottom112;
				float saferPower120 = abs( ( ( ( right113 + left114 ) + ( top97 + bottom112 ) ) / 4.0 ) );
				float front121 = pow( saferPower120 , 0.625 );
				float temp_output_122_0 = ( front121 * front121 );
				float temp_output_123_0 = ( temp_output_122_0 * temp_output_122_0 );
				float temp_output_124_0 = ( temp_output_123_0 * temp_output_123_0 );
				float back128 = ( ( ( temp_output_124_0 * temp_output_124_0 ) / 2.0 ) + saturate( ( ( 1.0 - front121 ) / 4.0 ) ) );
				float ifLocalVar110 = 0;
				if( break145.z > 0.0 )
				ifLocalVar110 = front121;
				else if( break145.z < 0.0 )
				ifLocalVar110 = back128;
				float lightmap106 = ( ( ( ( break145.x * break145.x ) * ifLocalVar102 ) + ( ( break145.y * break145.y ) * ifLocalVar109 ) ) + ( ( break145.z * break145.z ) * ifLocalVar110 ) );
				float lerpResult141 = lerp( 1.0 , lightmap106 , saturate( _LightContribution ));
				float lerpResult77 = lerp( break297.g , lerpResult141 , saturate( _LitBySun ));
				float3 lerpResult80 = lerp( _Color01.rgb , _Color02.rgb , lerpResult77);
				float3 lerpResult84 = lerp( _Color02.rgb , lerpResult80 , break297.a);
				float4 temp_output_81_0 = ( float4( lerpResult84 , 0.0 ) * input.ase_color );
				
				float2 texCoord454 = input.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult459 = (float2(_Columns , _Rows));
				float2 Flipbook_Tile461 = appendResult459;
				float smoothstepResult457 = smoothstep( _OpacityCutoutEro , ( _OpacityCutoutEro + _OpacityCutoutSmoothness ) , tex2D( _OpacityCutout, ( texCoord454 * Flipbook_Tile461 ) ).g);
				float4 screenPos = input.ase_texcoord6;
				float4 ase_positionSSNorm = screenPos / screenPos.w;
				ase_positionSSNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_positionSSNorm.z : ase_positionSSNorm.z * 0.5 + 0.5;
				float screenDepth75 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_positionSSNorm.xy ),_ZBufferParams);
				float distanceDepth75 = saturate( ( screenDepth75 - LinearEyeDepth( ase_positionSSNorm.z,_ZBufferParams ) ) / ( _DepthFade ) );
				

				float3 BaseColor = temp_output_81_0.rgb;
				float Alpha = saturate( ( saturate( ( saturate( ( input.ase_color.a * break297.a ) ) * smoothstepResult457 ) ) * distanceDepth75 ) );
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Color02;
			float4 _Color01;
			float _Cull;
			float _OpacityCutoutEro;
			float _Emission;
			float _Smoothness;
			float _Specular;
			float _LitBySun;
			float _LightContribution;
			float _HorizontalFlip;
			float _EncodedMotionIntensity;
			float _OpacityCutoutSmoothness;
			float _Rows;
			float _Columns;
			float _ZTest;
			float _ZWrite;
			float _Dst;
			float _Src;
			float _MotionIntensity;
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

				output.ase_color = input.ase_color;
				output.ase_texcoord3 = input.texcoord;
				output.ase_texcoord4 = input.ase_texcoord1;
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

				float localComputeMotionFlow369 = ( 0.0 );
				float4 appendResult334 = (float4(input.ase_texcoord3.x , input.ase_texcoord3.y , 0.0 , 0.0));
				float4 ShurikenCurrentFrame333 = appendResult334;
				float2 currentFrameUV369 = ShurikenCurrentFrame333.xy;
				float ShurikenFrameIndex418 = input.ase_texcoord3.w;
				float FlipbookSize420 = ( _Columns * _Rows );
				float4 appendResult331 = (float4(input.ase_texcoord4.x , input.ase_texcoord4.y , 0.0 , 0.0));
				float4 ifLocalVar416 = 0;
				if( ShurikenFrameIndex418 >= ( FlipbookSize420 - 1.0 ) )
				ifLocalVar416 = ShurikenCurrentFrame333;
				else
				ifLocalVar416 = appendResult331;
				float4 ShurikenNextFrame332 = ifLocalVar416;
				float2 nextFrameUV369 = ShurikenNextFrame332.xy;
				float4 currentMV369 = tex2D( _MotionVectors, ShurikenCurrentFrame333.xy );
				float4 tex2DNode374 = tex2D( _MotionVectors, ShurikenNextFrame332.xy );
				float2 appendResult372 = (float2(tex2DNode374.r , tex2DNode374.g));
				float2 nextMV369 = appendResult372;
				float isIntensityEncoded369 = _EncodedMotionIntensity;
				float motionIntensity369 = _MotionIntensity;
				float columns369 = _Columns;
				float rows369 = _Rows;
				float ShurikenBlendFactor336 = input.ase_texcoord3.z;
				float blendFactor369 = ShurikenBlendFactor336;
				float2 currentFrameMVUV369 = float2( 0,0 );
				float2 nextFrameMVUV369 = float2( 0,0 );
				ComputeMotionFlow_float( currentFrameUV369 , nextFrameUV369 , currentMV369 , nextMV369 , isIntensityEncoded369 , motionIntensity369 , columns369 , rows369 , blendFactor369 , currentFrameMVUV369 , nextFrameMVUV369 );
				float4 lerpResult396 = lerp( tex2D( _AOAlpha1, currentFrameMVUV369 ) , tex2D( _AOAlpha1, nextFrameMVUV369 ) , ShurikenBlendFactor336);
				float4 TextureAlpha401 = lerpResult396;
				float4 break297 = TextureAlpha401;
				float2 texCoord454 = input.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult459 = (float2(_Columns , _Rows));
				float2 Flipbook_Tile461 = appendResult459;
				float smoothstepResult457 = smoothstep( _OpacityCutoutEro , ( _OpacityCutoutEro + _OpacityCutoutSmoothness ) , tex2D( _OpacityCutout, ( texCoord454 * Flipbook_Tile461 ) ).g);
				float screenDepth75 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ScreenPosNorm.xy ),_ZBufferParams);
				float distanceDepth75 = saturate( ( screenDepth75 - LinearEyeDepth( ScreenPosNorm.z,_ZBufferParams ) ) / ( _DepthFade ) );
				

				float3 Normal = float3(0, 0, 1);
				float Alpha = saturate( ( saturate( ( saturate( ( input.ase_color.a * break297.a ) ) * smoothstepResult457 ) ) * distanceDepth75 ) );
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

			Blend [_Src] [_Dst], One OneMinusSrcAlpha
			ZWrite [_ZWrite]
			ZTest [_ZTest]
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Color02;
			float4 _Color01;
			float _Cull;
			float _OpacityCutoutEro;
			float _Emission;
			float _Smoothness;
			float _Specular;
			float _LitBySun;
			float _LightContribution;
			float _HorizontalFlip;
			float _EncodedMotionIntensity;
			float _OpacityCutoutSmoothness;
			float _Rows;
			float _Columns;
			float _ZTest;
			float _ZWrite;
			float _Dst;
			float _Src;
			float _MotionIntensity;
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

				output.ase_texcoord6 = input.texcoord;
				output.ase_texcoord7 = input.texcoord1;
				output.ase_color = input.ase_color;
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

				float localComputeMotionFlow369 = ( 0.0 );
				float4 appendResult334 = (float4(input.ase_texcoord6.x , input.ase_texcoord6.y , 0.0 , 0.0));
				float4 ShurikenCurrentFrame333 = appendResult334;
				float2 currentFrameUV369 = ShurikenCurrentFrame333.xy;
				float ShurikenFrameIndex418 = input.ase_texcoord6.w;
				float FlipbookSize420 = ( _Columns * _Rows );
				float4 appendResult331 = (float4(input.ase_texcoord7.x , input.ase_texcoord7.y , 0.0 , 0.0));
				float4 ifLocalVar416 = 0;
				if( ShurikenFrameIndex418 >= ( FlipbookSize420 - 1.0 ) )
				ifLocalVar416 = ShurikenCurrentFrame333;
				else
				ifLocalVar416 = appendResult331;
				float4 ShurikenNextFrame332 = ifLocalVar416;
				float2 nextFrameUV369 = ShurikenNextFrame332.xy;
				float4 currentMV369 = tex2D( _MotionVectors, ShurikenCurrentFrame333.xy );
				float4 tex2DNode374 = tex2D( _MotionVectors, ShurikenNextFrame332.xy );
				float2 appendResult372 = (float2(tex2DNode374.r , tex2DNode374.g));
				float2 nextMV369 = appendResult372;
				float isIntensityEncoded369 = _EncodedMotionIntensity;
				float motionIntensity369 = _MotionIntensity;
				float columns369 = _Columns;
				float rows369 = _Rows;
				float ShurikenBlendFactor336 = input.ase_texcoord6.z;
				float blendFactor369 = ShurikenBlendFactor336;
				float2 currentFrameMVUV369 = float2( 0,0 );
				float2 nextFrameMVUV369 = float2( 0,0 );
				ComputeMotionFlow_float( currentFrameUV369 , nextFrameUV369 , currentMV369 , nextMV369 , isIntensityEncoded369 , motionIntensity369 , columns369 , rows369 , blendFactor369 , currentFrameMVUV369 , nextFrameMVUV369 );
				float4 lerpResult396 = lerp( tex2D( _AOAlpha1, currentFrameMVUV369 ) , tex2D( _AOAlpha1, nextFrameMVUV369 ) , ShurikenBlendFactor336);
				float4 TextureAlpha401 = lerpResult396;
				float4 break297 = TextureAlpha401;
				float3x3 ase_worldToTangent = float3x3( TangentWS, BitangentWS, NormalWS );
				float3 worldToTangentDir99 = normalize( mul( ase_worldToTangent, SafeNormalize( _MainLightPosition.xyz ) ) );
				float3 break145 = worldToTangentDir99;
				float4 lerpResult364 = lerp( tex2D( _MDC, currentFrameMVUV369 ) , tex2D( _MDC, nextFrameMVUV369 ) , ShurikenBlendFactor336);
				float4 TextureColor400 = lerpResult364;
				float4 break288 = TextureColor400;
				float ifLocalVar96 = 0;
				if( _HorizontalFlip > 0.0 )
				ifLocalVar96 = break288.r;
				else if( _HorizontalFlip < 0.0 )
				ifLocalVar96 = break288.g;
				float left114 = ifLocalVar96;
				float ifLocalVar94 = 0;
				if( _HorizontalFlip > 0.0 )
				ifLocalVar94 = break288.g;
				else if( _HorizontalFlip < 0.0 )
				ifLocalVar94 = break288.r;
				float right113 = ifLocalVar94;
				float ifLocalVar102 = 0;
				if( break145.x > 0.0 )
				ifLocalVar102 = left114;
				else if( break145.x < 0.0 )
				ifLocalVar102 = right113;
				float top97 = break288.b;
				float bottom112 = break288.a;
				float ifLocalVar109 = 0;
				if( break145.y > 0.0 )
				ifLocalVar109 = top97;
				else if( break145.y < 0.0 )
				ifLocalVar109 = bottom112;
				float saferPower120 = abs( ( ( ( right113 + left114 ) + ( top97 + bottom112 ) ) / 4.0 ) );
				float front121 = pow( saferPower120 , 0.625 );
				float temp_output_122_0 = ( front121 * front121 );
				float temp_output_123_0 = ( temp_output_122_0 * temp_output_122_0 );
				float temp_output_124_0 = ( temp_output_123_0 * temp_output_123_0 );
				float back128 = ( ( ( temp_output_124_0 * temp_output_124_0 ) / 2.0 ) + saturate( ( ( 1.0 - front121 ) / 4.0 ) ) );
				float ifLocalVar110 = 0;
				if( break145.z > 0.0 )
				ifLocalVar110 = front121;
				else if( break145.z < 0.0 )
				ifLocalVar110 = back128;
				float lightmap106 = ( ( ( ( break145.x * break145.x ) * ifLocalVar102 ) + ( ( break145.y * break145.y ) * ifLocalVar109 ) ) + ( ( break145.z * break145.z ) * ifLocalVar110 ) );
				float lerpResult141 = lerp( 1.0 , lightmap106 , saturate( _LightContribution ));
				float lerpResult77 = lerp( break297.g , lerpResult141 , saturate( _LitBySun ));
				float3 lerpResult80 = lerp( _Color01.rgb , _Color02.rgb , lerpResult77);
				float3 lerpResult84 = lerp( _Color02.rgb , lerpResult80 , break297.a);
				float4 temp_output_81_0 = ( float4( lerpResult84 , 0.0 ) * input.ase_color );
				
				float3 temp_cast_7 = (_Specular).xxx;
				
				float2 texCoord454 = input.ase_texcoord6.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult459 = (float2(_Columns , _Rows));
				float2 Flipbook_Tile461 = appendResult459;
				float smoothstepResult457 = smoothstep( _OpacityCutoutEro , ( _OpacityCutoutEro + _OpacityCutoutSmoothness ) , tex2D( _OpacityCutout, ( texCoord454 * Flipbook_Tile461 ) ).g);
				float screenDepth75 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ScreenPosNorm.xy ),_ZBufferParams);
				float distanceDepth75 = saturate( ( screenDepth75 - LinearEyeDepth( ScreenPosNorm.z,_ZBufferParams ) ) / ( _DepthFade ) );
				

				float3 BaseColor = temp_output_81_0.rgb;
				float3 Normal = float3(0, 0, 1);
				float3 Specular = temp_cast_7;
				float Metallic = 0;
				float Smoothness = _Smoothness;
				float Occlusion = 1;
				float3 Emission = ( temp_output_81_0 * _Emission ).rgb;
				float Alpha = saturate( ( saturate( ( saturate( ( input.ase_color.a * break297.a ) ) * smoothstepResult457 ) ) * distanceDepth75 ) );
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Color02;
			float4 _Color01;
			float _Cull;
			float _OpacityCutoutEro;
			float _Emission;
			float _Smoothness;
			float _Specular;
			float _LitBySun;
			float _LightContribution;
			float _HorizontalFlip;
			float _EncodedMotionIntensity;
			float _OpacityCutoutSmoothness;
			float _Rows;
			float _Columns;
			float _ZTest;
			float _ZWrite;
			float _Dst;
			float _Src;
			float _MotionIntensity;
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

				output.ase_color = input.ase_color;
				output.ase_texcoord1 = input.ase_texcoord;
				output.ase_texcoord2 = input.ase_texcoord1;

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

				float localComputeMotionFlow369 = ( 0.0 );
				float4 appendResult334 = (float4(input.ase_texcoord1.x , input.ase_texcoord1.y , 0.0 , 0.0));
				float4 ShurikenCurrentFrame333 = appendResult334;
				float2 currentFrameUV369 = ShurikenCurrentFrame333.xy;
				float ShurikenFrameIndex418 = input.ase_texcoord1.w;
				float FlipbookSize420 = ( _Columns * _Rows );
				float4 appendResult331 = (float4(input.ase_texcoord2.x , input.ase_texcoord2.y , 0.0 , 0.0));
				float4 ifLocalVar416 = 0;
				if( ShurikenFrameIndex418 >= ( FlipbookSize420 - 1.0 ) )
				ifLocalVar416 = ShurikenCurrentFrame333;
				else
				ifLocalVar416 = appendResult331;
				float4 ShurikenNextFrame332 = ifLocalVar416;
				float2 nextFrameUV369 = ShurikenNextFrame332.xy;
				float4 currentMV369 = tex2D( _MotionVectors, ShurikenCurrentFrame333.xy );
				float4 tex2DNode374 = tex2D( _MotionVectors, ShurikenNextFrame332.xy );
				float2 appendResult372 = (float2(tex2DNode374.r , tex2DNode374.g));
				float2 nextMV369 = appendResult372;
				float isIntensityEncoded369 = _EncodedMotionIntensity;
				float motionIntensity369 = _MotionIntensity;
				float columns369 = _Columns;
				float rows369 = _Rows;
				float ShurikenBlendFactor336 = input.ase_texcoord1.z;
				float blendFactor369 = ShurikenBlendFactor336;
				float2 currentFrameMVUV369 = float2( 0,0 );
				float2 nextFrameMVUV369 = float2( 0,0 );
				ComputeMotionFlow_float( currentFrameUV369 , nextFrameUV369 , currentMV369 , nextMV369 , isIntensityEncoded369 , motionIntensity369 , columns369 , rows369 , blendFactor369 , currentFrameMVUV369 , nextFrameMVUV369 );
				float4 lerpResult396 = lerp( tex2D( _AOAlpha1, currentFrameMVUV369 ) , tex2D( _AOAlpha1, nextFrameMVUV369 ) , ShurikenBlendFactor336);
				float4 TextureAlpha401 = lerpResult396;
				float4 break297 = TextureAlpha401;
				float2 texCoord454 = input.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult459 = (float2(_Columns , _Rows));
				float2 Flipbook_Tile461 = appendResult459;
				float smoothstepResult457 = smoothstep( _OpacityCutoutEro , ( _OpacityCutoutEro + _OpacityCutoutSmoothness ) , tex2D( _OpacityCutout, ( texCoord454 * Flipbook_Tile461 ) ).g);
				float screenDepth75 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ScreenPosNorm.xy ),_ZBufferParams);
				float distanceDepth75 = saturate( ( screenDepth75 - LinearEyeDepth( ScreenPosNorm.z,_ZBufferParams ) ) / ( _DepthFade ) );
				

				surfaceDescription.Alpha = saturate( ( saturate( ( saturate( ( input.ase_color.a * break297.a ) ) * smoothstepResult457 ) ) * distanceDepth75 ) );
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Color02;
			float4 _Color01;
			float _Cull;
			float _OpacityCutoutEro;
			float _Emission;
			float _Smoothness;
			float _Specular;
			float _LitBySun;
			float _LightContribution;
			float _HorizontalFlip;
			float _EncodedMotionIntensity;
			float _OpacityCutoutSmoothness;
			float _Rows;
			float _Columns;
			float _ZTest;
			float _ZWrite;
			float _Dst;
			float _Src;
			float _MotionIntensity;
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

				output.ase_color = input.ase_color;
				output.ase_texcoord1 = input.ase_texcoord;
				output.ase_texcoord2 = input.ase_texcoord1;

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

				float localComputeMotionFlow369 = ( 0.0 );
				float4 appendResult334 = (float4(input.ase_texcoord1.x , input.ase_texcoord1.y , 0.0 , 0.0));
				float4 ShurikenCurrentFrame333 = appendResult334;
				float2 currentFrameUV369 = ShurikenCurrentFrame333.xy;
				float ShurikenFrameIndex418 = input.ase_texcoord1.w;
				float FlipbookSize420 = ( _Columns * _Rows );
				float4 appendResult331 = (float4(input.ase_texcoord2.x , input.ase_texcoord2.y , 0.0 , 0.0));
				float4 ifLocalVar416 = 0;
				if( ShurikenFrameIndex418 >= ( FlipbookSize420 - 1.0 ) )
				ifLocalVar416 = ShurikenCurrentFrame333;
				else
				ifLocalVar416 = appendResult331;
				float4 ShurikenNextFrame332 = ifLocalVar416;
				float2 nextFrameUV369 = ShurikenNextFrame332.xy;
				float4 currentMV369 = tex2D( _MotionVectors, ShurikenCurrentFrame333.xy );
				float4 tex2DNode374 = tex2D( _MotionVectors, ShurikenNextFrame332.xy );
				float2 appendResult372 = (float2(tex2DNode374.r , tex2DNode374.g));
				float2 nextMV369 = appendResult372;
				float isIntensityEncoded369 = _EncodedMotionIntensity;
				float motionIntensity369 = _MotionIntensity;
				float columns369 = _Columns;
				float rows369 = _Rows;
				float ShurikenBlendFactor336 = input.ase_texcoord1.z;
				float blendFactor369 = ShurikenBlendFactor336;
				float2 currentFrameMVUV369 = float2( 0,0 );
				float2 nextFrameMVUV369 = float2( 0,0 );
				ComputeMotionFlow_float( currentFrameUV369 , nextFrameUV369 , currentMV369 , nextMV369 , isIntensityEncoded369 , motionIntensity369 , columns369 , rows369 , blendFactor369 , currentFrameMVUV369 , nextFrameMVUV369 );
				float4 lerpResult396 = lerp( tex2D( _AOAlpha1, currentFrameMVUV369 ) , tex2D( _AOAlpha1, nextFrameMVUV369 ) , ShurikenBlendFactor336);
				float4 TextureAlpha401 = lerpResult396;
				float4 break297 = TextureAlpha401;
				float2 texCoord454 = input.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult459 = (float2(_Columns , _Rows));
				float2 Flipbook_Tile461 = appendResult459;
				float smoothstepResult457 = smoothstep( _OpacityCutoutEro , ( _OpacityCutoutEro + _OpacityCutoutSmoothness ) , tex2D( _OpacityCutout, ( texCoord454 * Flipbook_Tile461 ) ).g);
				float screenDepth75 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ScreenPosNorm.xy ),_ZBufferParams);
				float distanceDepth75 = saturate( ( screenDepth75 - LinearEyeDepth( ScreenPosNorm.z,_ZBufferParams ) ) / ( _DepthFade ) );
				

				surfaceDescription.Alpha = saturate( ( saturate( ( saturate( ( input.ase_color.a * break297.a ) ) * smoothstepResult457 ) ) * distanceDepth75 ) );
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
{"type":"AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor","id":414,"pos":[-11040,-1008],"params":["Inherit","False","3684.295","1184.774","Motion Vector Frame Blending","30","369","279","277","282","381","400","389","361","364","362","401","396","399","397","395","398","388","372","387","386","373","374","382","419","420","394","371","459","461","471","Motion Vector Frame Blending","0,0,0,1","0","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":279,"pos":[-9984,-304],"params":["Inherit","False","Property","_Rows","Rows","12","0","Create","True","0","0","0","False","0","False","Object","-1","","8","8","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":277,"pos":[-9984,-384],"params":["Inherit","False","Property","_Columns","Columns","13","0","Create","True","0","0","0","False","0","False","Object","-1","","8","8","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":419,"pos":[-9728,-384],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor","id":410,"pos":[-11040,-1904],"params":["Inherit","False","2336.386","824.6879","Shuriken provides Blend Timing in UV.z and Next Frame UVs in UV2.xy","13","332","416","437","438","436","331","325","418","336","333","334","335","435","Shuriken Texture Sheet Animation Data","0,0,0,1","0","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":420,"pos":[-9472,-384],"params":["Inherit","False","FlipbookSize","-1","True","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor","id":411,"pos":[-11040,-3072],"params":["Inherit","False","930.0732","1021.819","Textures","6","321","385","281","377","380","384","Textures","0,0,0,1","0","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":418,"pos":[-10368,-1536],"params":["Inherit","False","ShurikenFrameIndex","-1","True","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.TexCoordVertexDataNode, AmplifyShaderEditor","id":325,"pos":[-10880,-1408],"params":["Inherit","False","1","4","0","5","FLOAT4","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":436,"pos":[-9856,-1280],"params":["Inherit","False","420","FlipbookSize","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.TexCoordVertexDataNode, AmplifyShaderEditor","id":335,"pos":[-10880,-1792],"params":["Inherit","False","0","4","0","5","FLOAT4","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4"]}
{"type":"AmplifyShaderEditor.DynamicAppendNode, AmplifyShaderEditor","id":331,"pos":[-10624,-1408],"params":["Inherit","False","FLOAT4","4","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","0","False","3","FLOAT","0","False","1","FLOAT4","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":437,"pos":[-9856,-1536],"params":["Inherit","False","418","ShurikenFrameIndex","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleSubtractOpNode, AmplifyShaderEditor","id":438,"pos":[-9600,-1280],"params":["Inherit","False","2","0","FLOAT","0","False","1","FLOAT","1","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor","id":281,"pos":[-10880,-2432],"params":["Inherit","True","Property","_MotionVectors","Motion Vectors","11","0","Create","True","0","0","0","False","3","Space(33)","Header(Motion Vector Frame Blending)","Space(13)","False","","None","None","False","white","Auto","Texture2D","False","-1","0","2","SAMPLER2D","0","SAMPLERSTATE","1"]}
{"type":"AmplifyShaderEditor.DynamicAppendNode, AmplifyShaderEditor","id":334,"pos":[-10624,-1792],"params":["Inherit","False","FLOAT4","4","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","0","False","3","FLOAT","0","False","1","FLOAT4","0"]}
{"type":"AmplifyShaderEditor.ConditionalIfNode, AmplifyShaderEditor","id":416,"pos":[-9472,-1536],"params":["Inherit","False","False","5","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT4","0,0,0,0","False","3","FLOAT4","0,0,0,0","False","4","FLOAT4","0,0,0,0","False","1","FLOAT4","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":321,"pos":[-10496,-2432],"params":["Inherit","False","MotionVectors","-1","True","1","0","SAMPLER2D","","False","1","SAMPLER2D","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":394,"pos":[-11008,-640],"params":["Inherit","False","332","ShurikenNextFrame","1","0","OBJECT","","False","1","FLOAT4","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":333,"pos":[-10368,-1792],"params":["Inherit","False","ShurikenCurrentFrame","-1","True","1","0","FLOAT4","0,0,0,0","False","1","FLOAT4","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":332,"pos":[-9088,-1408],"params":["Inherit","False","ShurikenNextFrame","-1","True","1","0","FLOAT4","0,0,0,0","False","1","FLOAT4","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":382,"pos":[-11008,-768],"params":["Inherit","False","321","MotionVectors","1","0","OBJECT","","False","1","SAMPLER2D","0"]}
{"type":"AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor","id":374,"pos":[-10624,-640],"params":["Inherit","True","Property","_TextureSample3","Texture Sample 0","0","0","Create","True","0","0","0","False","0","False","","-1","None","None","True","0","False","white","Auto","False","Object","-1","Auto","Texture2D","False","8","0","SAMPLER2D","","False","1","FLOAT2","0,0","False","2","FLOAT","0","False","3","FLOAT2","0,0","False","4","FLOAT2","0,0","False","5","FLOAT","1","False","6","FLOAT","0","False","7","SAMPLERSTATE","","False","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":371,"pos":[-11008,-896],"params":["Inherit","False","333","ShurikenCurrentFrame","1","0","OBJECT","","False","1","FLOAT4","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":336,"pos":[-10368,-1664],"params":["Inherit","False","ShurikenBlendFactor","-1","True","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor","id":384,"pos":[-10880,-2688],"params":["Inherit","True","Property","_AOAlpha1","AO Alpha","1","0","Create","True","0","0","0","False","3","Space(33)","Header(AO Alpha)","Space(13)","False","","None","None","False","white","Auto","Texture2D","False","-1","0","2","SAMPLER2D","0","SAMPLERSTATE","1"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":388,"pos":[-9984,-896],"params":["Inherit","False","333","ShurikenCurrentFrame","1","0","OBJECT","","False","1","FLOAT4","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":387,"pos":[-9984,-768],"params":["Inherit","False","332","ShurikenNextFrame","1","0","OBJECT","","False","1","FLOAT4","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":282,"pos":[-9984,-560],"params":["Inherit","False","Property","_MotionIntensity","Motion Intensity","15","0","Create","True","0","0","0","False","0","False","Object","-1","","0","0","0","1","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.DynamicAppendNode, AmplifyShaderEditor","id":372,"pos":[-10240,-640],"params":["Inherit","False","FLOAT2","4","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","0","False","3","FLOAT","0","False","1","FLOAT2","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":386,"pos":[-9984,-128],"params":["Inherit","False","336","ShurikenBlendFactor","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":385,"pos":[-10496,-2688],"params":["Inherit","False","FlipbookAlpha","-1","True","1","0","SAMPLER2D","","False","1","SAMPLER2D","0"]}
{"type":"AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor","id":373,"pos":[-10624,-896],"params":["Inherit","True","Property","_TextureSample2","Texture Sample 0","0","0","Create","True","0","0","0","False","0","False","","-1","None","None","True","0","False","white","Auto","False","Object","-1","Auto","Texture2D","False","8","0","SAMPLER2D","","False","1","FLOAT2","0,0","False","2","FLOAT","0","False","3","FLOAT2","0,0","False","4","FLOAT2","0,0","False","5","FLOAT","1","False","6","FLOAT","0","False","7","SAMPLERSTATE","","False","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":471,"pos":[-9984,-640],"params":["Inherit","False","Property","_EncodedMotionIntensity","Encoded Motion Intensity","14","0","Create","True","0","0","0","False","0","False","Object","-1","","1","1","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":398,"pos":[-8832,-256],"params":["Inherit","False","385","FlipbookAlpha","1","0","OBJECT","","False","1","SAMPLER2D","0"]}
{"type":"AmplifyShaderEditor.CustomExpressionNode, AmplifyShaderEditor","id":369,"pos":[-9472,-896],"params":["Inherit","False"," ","8","File","11","True","currentFrameUV","FLOAT2","0,0","In","","Inherit","False","True","nextFrameUV","FLOAT2","0,0","In","","Inherit","False","True","currentMV","FLOAT4","0,0,0,0","In","","Inherit","False","True","nextMV","FLOAT2","0,0","In","","Inherit","False","True","isIntensityEncoded","FLOAT","0","In","","Inherit","False","True","motionIntensity","FLOAT","0","In","","Inherit","False","True","columns","FLOAT","0","In","","Inherit","False","True","rows","FLOAT","0","In","","Inherit","False","True","blendFactor","FLOAT","0","In","","Inherit","False","True","currentFrameMVUV","FLOAT2","0,0","Out","","Inherit","False","True","nextFrameMVUV","FLOAT2","0,0","Out","","Inherit","False","ComputeMotionFlow","False","False","0","44655f03ba5dfca44a92110412bc10e5","True","12","0","FLOAT","0","False","1","FLOAT2","0,0","False","2","FLOAT2","0,0","False","3","FLOAT4","0,0,0,0","False","4","FLOAT2","0,0","False","5","FLOAT","0","False","6","FLOAT","0","False","7","FLOAT","0","False","8","FLOAT","0","False","9","FLOAT","0","False","10","FLOAT2","0,0","False","11","FLOAT2","0,0","False","3","FLOAT","0","FLOAT2","11","FLOAT2","12"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":399,"pos":[-8192,-256],"params":["Inherit","False","336","ShurikenBlendFactor","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor","id":397,"pos":[-8576,-128],"params":["Inherit","True","Property","_TextureSample5","Texture Sample 0","0","0","Create","True","0","0","0","False","0","False","","-1","None","None","True","0","False","white","Auto","False","Instance","-1","Auto","Texture2D","False","8","0","SAMPLER2D","","False","1","FLOAT2","0,0","False","2","FLOAT","0","False","3","FLOAT2","0,0","False","4","FLOAT2","0,0","False","5","FLOAT","1","False","6","FLOAT","0","False","7","SAMPLERSTATE","","False","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor","id":395,"pos":[-8576,-384],"params":["Inherit","True","Property","_TextureSample4","Texture Sample 1","0","0","Create","True","0","0","0","False","0","False","","-1","None","None","True","0","False","white","Auto","False","Instance","-1","Auto","Texture2D","False","8","0","SAMPLER2D","","False","1","FLOAT2","0,0","False","2","FLOAT","0","False","3","FLOAT2","0,0","False","4","FLOAT2","0,0","False","5","FLOAT","1","False","6","FLOAT","0","False","7","SAMPLERSTATE","","False","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.LerpOp, AmplifyShaderEditor","id":396,"pos":[-8192,-384],"params":["Inherit","False","3","0","COLOR","0,0,0,0","False","1","COLOR","0,0,0,0","False","2","FLOAT","0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.DynamicAppendNode, AmplifyShaderEditor","id":459,"pos":[-9728,-256],"params":["Inherit","False","FLOAT2","4","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","0","False","3","FLOAT","0","False","1","FLOAT2","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":401,"pos":[-7680,-384],"params":["Inherit","False","TextureAlpha","-1","True","1","0","COLOR","0,0,0,0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":461,"pos":[-9472,-256],"params":["Inherit","False","Flipbook Tile","-1","True","1","0","FLOAT2","0,0","False","1","FLOAT2","0"]}
{"type":"AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor","id":454,"pos":[-3200,768],"params":["Inherit","False","0","-1","2","3","2","SAMPLER2D","","False","0","FLOAT2","1,1","False","1","FLOAT2","0,0","False","5","FLOAT2","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":456,"pos":[-2944,896],"params":["Inherit","False","461","Flipbook Tile","1","0","OBJECT","","False","1","FLOAT2","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":403,"pos":[-2688,384],"params":["Inherit","False","401","TextureAlpha","1","0","OBJECT","","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.BreakToComponentsNode, AmplifyShaderEditor","id":297,"pos":[-2432,384],"params":["Inherit","False","COLOR","1","0","COLOR","0,0,0,0","False","16","FLOAT","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT","5","FLOAT","6","FLOAT","7","FLOAT","8","FLOAT","9","FLOAT","10","FLOAT","11","FLOAT","12","FLOAT","13","FLOAT","14","FLOAT","15"]}
{"type":"AmplifyShaderEditor.VertexColorNode, AmplifyShaderEditor","id":10,"pos":[-2688,-384],"params":["Inherit","False","0","5","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":455,"pos":[-2944,768],"params":["Inherit","False","2","2","0","FLOAT2","0,0","False","1","FLOAT2","0,0","False","1","FLOAT2","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":464,"pos":[-2560,1152],"params":["Inherit","False","Property","_OpacityCutoutSmoothness","Opacity Cutout Smoothness","18","0","Create","True","0","0","0","False","0","False","Object","-1","","0.01","0.01","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":463,"pos":[-2560,1024],"params":["Inherit","False","Property","_OpacityCutoutEro","Opacity Cutout Ero","17","0","Create","True","0","0","0","False","0","False","Object","-1","","0","0","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":72,"pos":[-2176,384],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor","id":465,"pos":[-2176,1024],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor","id":453,"pos":[-2560,768],"params":["Inherit","True","Property","_OpacityCutout","Opacity Cutout","16","0","Create","True","0","0","0","False","3","Space(33)","Header(Opacity Cutout)","Space(13)","False","","-1","d981c863a6701424eb185510d6ea29d0","d981c863a6701424eb185510d6ea29d0","True","0","False","white","Auto","False","Object","-1","Auto","Texture2D","False","8","0","SAMPLER2D","","False","1","FLOAT2","0,0","False","2","FLOAT","0","False","3","FLOAT2","0,0","False","4","FLOAT2","0,0","False","5","FLOAT","1","False","6","FLOAT","0","False","7","SAMPLERSTATE","","False","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":450,"pos":[-2048,384],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SmoothstepOpNode, AmplifyShaderEditor","id":457,"pos":[-2176,768],"params":["Inherit","True","3","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","1","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":451,"pos":[-1792,384],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":74,"pos":[-1408,640],"params":["Inherit","False","Property","_DepthFade","Depth Fade","10","0","Create","True","0","0","0","False","0","False","Object","-1","","1","1","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.DepthFade, AmplifyShaderEditor","id":75,"pos":[-1408,512],"params":["Inherit","False","True","True","False","2","1","FLOAT3","0,0,0","False","0","FLOAT","1","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":452,"pos":[-1664,384],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor","id":133,"pos":[-7120,-64],"params":["Inherit","False","2386.335","1605.285","Lightmap Calculation","21","139","138","110","111","107","136","137","109","135","134","102","106","105","103","108","104","100","101","145","99","91","Lightmap Calculation","0,0,0,1","0","0"]}
{"type":"AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor","id":132,"pos":[-7120,-1008],"params":["Inherit","False","4046.4","887.45","Light Contribution Textures","25","288","402","118","121","94","113","131","130","129","128","127","126","125","124","123","122","120","119","116","117","115","114","112","97","96","Light Contribution Textures","0,0,0,1","0","0"]}
{"type":"AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor","id":59,"pos":[-432,-176],"params":["Inherit","False","1252","162.95","Ge Lush was here! <3","1","54","Ge Lush was here! <3","0,0,0,1","0","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":73,"pos":[-1408,384],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.StickyNoteNode, AmplifyShaderEditor","id":435,"pos":[-9888,-1664],"params":["Inherit","False","670.2373","514.3649","Super Secret Hack","","1,1,1,1","prevent nextFrameUV from wrapping around the flipbook","0","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":54,"pos":[-384,-128],"params":["Inherit","False","Property","_Cull","Cull","19","0","Create","True","0","0","0","True","3","Space(33)","Header(AR)","Space(13)","False","Object","-1","","2","0","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":55,"pos":[-128,-128],"params":["Inherit","False","Property","_Src","Src","20","0","Create","True","0","0","0","True","0","False","Object","-1","","5","5","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":56,"pos":[128,-128],"params":["Inherit","False","Property","_Dst","Dst","21","0","Create","True","0","0","0","True","0","False","Object","-1","","10","10","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":57,"pos":[384,-128],"params":["Inherit","False","Property","_ZWrite","ZWrite","22","0","Create","True","0","0","0","True","0","False","Object","-1","","0","0","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":58,"pos":[640,-128],"params":["Inherit","False","Property","_ZTest","ZTest","23","0","Create","True","0","0","0","True","0","False","Object","-1","","2","2","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.ColorNode, AmplifyShaderEditor","id":78,"pos":[-2688,-1536],"params":["Inherit","False","Property","_Color01","Color 01","5","0","Create","True","0","0","0","False","0","False","Object","-1","","0.945098,0.7137255,0.427451,1","0.945098,0.7137255,0.427451,1","True","True","0","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.ColorNode, AmplifyShaderEditor","id":79,"pos":[-2688,-1280],"params":["Inherit","False","Property","_Color02","Color 02","6","0","Create","True","0","0","0","False","0","False","Object","-1","","0.6588235,0.3803922,0.227451,1","0.6588235,0.3803921,0.2274509,1","True","True","0","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.LerpOp, AmplifyShaderEditor","id":84,"pos":[-1792,-1536],"params":["Inherit","True","3","0","FLOAT3","0,0,0","False","1","FLOAT3","0,0,0","False","2","FLOAT","0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.LerpOp, AmplifyShaderEditor","id":80,"pos":[-2176,-1280],"params":["Inherit","True","3","0","FLOAT3","0,0,0","False","1","FLOAT3","0,0,0","False","2","FLOAT","0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":85,"pos":[-1408,0],"params":["Inherit","False","Property","_Emission","Emission","9","0","Create","True","0","0","0","False","0","False","Object","-1","","0.1","1","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":86,"pos":[-1408,-128],"params":["Inherit","False","2","2","0","COLOR","0,0,0,0","False","1","FLOAT","0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":81,"pos":[-1408,-384],"params":["Inherit","False","2","2","0","FLOAT3","0,0,0","False","1","COLOR","0,0,0,0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":140,"pos":[-2688,-896],"params":["Inherit","False","Constant","_Float1","Float 1","15","0","Create","True","0","0","0","False","0","False","Object","-1","","1","0","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.LerpOp, AmplifyShaderEditor","id":141,"pos":[-2432,-896],"params":["Inherit","False","3","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":142,"pos":[-2688,-768],"params":["Inherit","False","106","lightmap","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.LerpOp, AmplifyShaderEditor","id":77,"pos":[-2176,-896],"params":["Inherit","False","3","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":76,"pos":[-1280,384],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":466,"pos":[-1408,128],"params":["Inherit","False","Property","_Specular","Specular","7","0","Create","True","0","0","0","False","0","False","Object","-1","","0","0","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":467,"pos":[-1408,256],"params":["Inherit","False","Property","_Smoothness","Smoothness","8","0","Create","True","0","0","0","False","0","False","Object","-1","","0","0","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":469,"pos":[-2176,-768],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":470,"pos":[-2432,-768],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":143,"pos":[-2688,-640],"params":["Inherit","False","Property","_LightContribution","Light Contribution","3","0","Create","True","0","0","0","False","0","False","Object","-1","","1","1","0","1","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":82,"pos":[-2176,-640],"params":["Inherit","False","Property","_LitBySun","Lit By Sun","2","0","Create","True","0","0","0","False","3","Space(33)","Header(Lighting)","Space(13)","False","Object","-1","","1","1","0","1","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.WorldSpaceLightDirHlpNode, AmplifyShaderEditor","id":91,"pos":[-7040,640],"params":["Inherit","False","True","1","0","FLOAT","0","False","4","FLOAT3","0","FLOAT","1","FLOAT","2","FLOAT","3"]}
{"type":"AmplifyShaderEditor.BreakToComponentsNode, AmplifyShaderEditor","id":145,"pos":[-6400,640],"params":["Inherit","False","FLOAT3","1","0","FLOAT3","0,0,0","False","16","FLOAT","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT","5","FLOAT","6","FLOAT","7","FLOAT","8","FLOAT","9","FLOAT","10","FLOAT","11","FLOAT","12","FLOAT","13","FLOAT","14","FLOAT","15"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":101,"pos":[-5760,0],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":100,"pos":[-6016,0],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":104,"pos":[-5760,640],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":108,"pos":[-6016,640],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":106,"pos":[-5120,640],"params":["Inherit","False","lightmap","-1","True","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.ConditionalIfNode, AmplifyShaderEditor","id":102,"pos":[-5760,128],"params":["Inherit","False","False","5","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","0","False","3","FLOAT","0","False","4","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":134,"pos":[-6016,256],"params":["Inherit","False","113","right","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":135,"pos":[-6016,144],"params":["Inherit","False","114","left","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.ConditionalIfNode, AmplifyShaderEditor","id":109,"pos":[-5760,768],"params":["Inherit","False","False","5","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","0","False","3","FLOAT","0","False","4","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":137,"pos":[-6016,768],"params":["Inherit","False","97","top","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":136,"pos":[-6016,896],"params":["Inherit","False","112","bottom","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":107,"pos":[-5760,1152],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":111,"pos":[-6016,1152],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.ConditionalIfNode, AmplifyShaderEditor","id":110,"pos":[-5760,1280],"params":["Inherit","False","False","5","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","0","False","3","FLOAT","0","False","4","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":138,"pos":[-6016,1280],"params":["Inherit","False","121","front","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":139,"pos":[-6016,1408],"params":["Inherit","False","128","back","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor","id":103,"pos":[-5504,0],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor","id":105,"pos":[-5376,640],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.TransformDirectionNode, AmplifyShaderEditor","id":99,"pos":[-6656,640],"params":["Inherit","False","World","Tangent","True","Fast","False","1","0","FLOAT3","0,0,0","False","4","FLOAT3","0","FLOAT","1","FLOAT","2","FLOAT","3"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":128,"pos":[-3456,-768],"params":["Inherit","False","back","-1","True","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor","id":127,"pos":[-3584,-768],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":123,"pos":[-4224,-896],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":124,"pos":[-4096,-896],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":125,"pos":[-3968,-896],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleDivideOpNode, AmplifyShaderEditor","id":126,"pos":[-3840,-896],"params":["Inherit","False","2","0","FLOAT","0","False","1","FLOAT","2","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":122,"pos":[-4352,-896],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.OneMinusNode, AmplifyShaderEditor","id":129,"pos":[-4352,-640],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleDivideOpNode, AmplifyShaderEditor","id":130,"pos":[-4096,-640],"params":["Inherit","False","2","0","FLOAT","0","False","1","FLOAT","4","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":131,"pos":[-3888,-640],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":121,"pos":[-4608,-768],"params":["Inherit","False","front","-1","True","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.PowerNode, AmplifyShaderEditor","id":120,"pos":[-4736,-768],"params":["Inherit","False","True","2","0","FLOAT","0","False","1","FLOAT","0.625","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleDivideOpNode, AmplifyShaderEditor","id":119,"pos":[-4864,-768],"params":["Inherit","False","2","0","FLOAT","0","False","1","FLOAT","4","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor","id":116,"pos":[-4992,-768],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor","id":115,"pos":[-5504,-896],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor","id":117,"pos":[-5504,-384],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":402,"pos":[-7040,-640],"params":["Inherit","False","400","TextureColor","1","0","OBJECT","","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.BreakToComponentsNode, AmplifyShaderEditor","id":288,"pos":[-6784,-640],"params":["Inherit","False","COLOR","1","0","COLOR","0,0,0,0","False","16","FLOAT","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT","5","FLOAT","6","FLOAT","7","FLOAT","8","FLOAT","9","FLOAT","10","FLOAT","11","FLOAT","12","FLOAT","13","FLOAT","14","FLOAT","15"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":118,"pos":[-6784,-896],"params":["Inherit","False","Property","_HorizontalFlip","Horizontal Flip","4","0","Create","True","0","0","0","False","0","False","Object","-1","","0","1","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":113,"pos":[-5760,-896],"params":["Inherit","False","right","-1","True","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":112,"pos":[-5760,-256],"params":["Inherit","False","bottom","-1","True","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":97,"pos":[-5760,-384],"params":["Inherit","False","top","-1","True","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":114,"pos":[-5760,-768],"params":["Inherit","False","left","-1","True","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.ConditionalIfNode, AmplifyShaderEditor","id":96,"pos":[-6016,-640],"params":["Inherit","False","False","5","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","0","False","3","FLOAT","0","False","4","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.ConditionalIfNode, AmplifyShaderEditor","id":94,"pos":[-6016,-896],"params":["Inherit","False","False","5","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","0","False","3","FLOAT","0","False","4","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":381,"pos":[-8832,-768],"params":["Inherit","False","380","Flipbook","1","0","OBJECT","","False","1","SAMPLER2D","0"]}
{"type":"AmplifyShaderEditor.LerpOp, AmplifyShaderEditor","id":364,"pos":[-8192,-896],"params":["Inherit","False","3","0","COLOR","0,0,0,0","False","1","COLOR","0,0,0,0","False","2","FLOAT","0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":389,"pos":[-8192,-768],"params":["Inherit","False","336","ShurikenBlendFactor","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":400,"pos":[-7680,-896],"params":["Inherit","False","TextureColor","-1","True","1","0","COLOR","0,0,0,0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":380,"pos":[-10496,-2944],"params":["Inherit","False","Flipbook","-1","True","1","0","SAMPLER2D","","False","1","SAMPLER2D","0"]}
{"type":"AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor","id":362,"pos":[-8576,-896],"params":["Inherit","True","Property","_TextureSample1","Texture Sample 1","0","0","Create","True","0","0","0","False","0","False","","-1","None","None","True","0","False","white","Auto","False","Instance","-1","Auto","Texture2D","False","8","0","SAMPLER2D","","False","1","FLOAT2","0,0","False","2","FLOAT","0","False","3","FLOAT2","0,0","False","4","FLOAT2","0,0","False","5","FLOAT","1","False","6","FLOAT","0","False","7","SAMPLERSTATE","","False","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor","id":361,"pos":[-8576,-640],"params":["Inherit","True","Property","_TextureSample0","Texture Sample 0","0","0","Create","True","0","0","0","False","0","False","","-1","None","None","True","0","False","white","Auto","False","Instance","-1","Auto","Texture2D","False","8","0","SAMPLER2D","","False","1","FLOAT2","0,0","False","2","FLOAT","0","False","3","FLOAT2","0,0","False","4","FLOAT2","0,0","False","5","FLOAT","1","False","6","FLOAT","0","False","7","SAMPLERSTATE","","False","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor","id":377,"pos":[-10880,-2944],"params":["Inherit","True","Property","_MDC","MDC","0","0","Create","True","0","0","0","False","3","Space(33)","Header(MDC)","Space(13)","False","","None","None","False","white","Auto","Texture2D","False","-1","0","2","SAMPLER2D","0","SAMPLERSTATE","1"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":439,"pos":[-816,-192],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphLitGUI","0","1","New Amplify Shader","94348b07e5e8bab40bd6c8a1e3df54cd","True","ExtraPrePass","0","0","ExtraPrePass","6","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","False","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","4","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Lit","True","5","True","12","all","0","False","True","1","1","False","","0","False","","0","1","False","","0","False","","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","0","False","False","0","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":441,"pos":[-816,-192],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphLitGUI","0","1","New Amplify Shader","94348b07e5e8bab40bd6c8a1e3df54cd","True","ShadowCaster","0","2","ShadowCaster","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","False","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","4","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Lit","True","5","True","12","all","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","False","False","True","False","False","False","False","0","False","","False","False","False","False","False","False","False","False","False","True","1","False","","True","3","False","","False","False","True","1","LightMode=ShadowCaster","False","False","0","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":442,"pos":[-816,-192],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphLitGUI","0","1","New Amplify Shader","94348b07e5e8bab40bd6c8a1e3df54cd","True","DepthOnly","0","3","DepthOnly","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","False","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","4","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Lit","True","5","True","12","all","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","False","False","True","True","False","False","False","0","False","","False","False","False","False","False","False","False","False","False","True","1","False","","False","False","False","True","1","LightMode=DepthOnly","False","False","0","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":443,"pos":[-816,-192],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphLitGUI","0","1","New Amplify Shader","94348b07e5e8bab40bd6c8a1e3df54cd","True","Meta","0","4","Meta","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","False","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","4","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Lit","True","5","True","12","all","0","False","False","False","False","False","False","False","False","False","False","False","False","False","False","True","2","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","True","1","LightMode=Meta","False","False","0","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":444,"pos":[-816,-192],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphLitGUI","0","1","New Amplify Shader","94348b07e5e8bab40bd6c8a1e3df54cd","True","Universal2D","0","5","Universal2D","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","False","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","4","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Lit","True","5","True","12","all","0","False","True","2","5","True","_Src","10","True","_Dst","1","1","False","","10","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","False","False","True","1","True","","True","3","True","","True","True","0","False","","0","False","","False","True","1","LightMode=Universal2D","False","False","0","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":445,"pos":[-816,-192],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphLitGUI","0","1","New Amplify Shader","94348b07e5e8bab40bd6c8a1e3df54cd","True","DepthNormals","0","6","DepthNormals","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","False","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","4","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Lit","True","5","True","12","all","0","False","True","1","1","False","","0","False","","0","1","False","","0","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","True","1","False","","True","3","False","","False","False","True","1","LightMode=DepthNormals","False","False","0","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":446,"pos":[-816,-192],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphLitGUI","0","1","New Amplify Shader","94348b07e5e8bab40bd6c8a1e3df54cd","True","GBuffer","0","7","GBuffer","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","False","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","4","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Lit","True","5","True","12","all","0","False","True","2","5","True","_Src","10","True","_Dst","1","1","False","","10","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","True","","True","3","True","","True","True","0","False","","0","False","","False","True","1","LightMode=UniversalGBuffer","False","True","10","d3d11","gles","metal","vulkan","xboxone","xboxseries","playstation","ps4","ps5","switch","0","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":447,"pos":[-816,-192],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphLitGUI","0","1","New Amplify Shader","94348b07e5e8bab40bd6c8a1e3df54cd","True","SceneSelectionPass","0","8","SceneSelectionPass","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","False","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","4","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Lit","True","5","True","12","all","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","2","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","True","1","LightMode=SceneSelectionPass","False","False","0","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":448,"pos":[-816,-192],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphLitGUI","0","1","New Amplify Shader","94348b07e5e8bab40bd6c8a1e3df54cd","True","ScenePickingPass","0","9","ScenePickingPass","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","False","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","4","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Lit","True","5","True","12","all","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","True","1","LightMode=Picking","False","False","0","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":440,"pos":[-896,-128],"params":["Float","False","True","-1","2","UnityEditor.ShaderGraphLitGUI","0","15","Vefects/SH_Vefects_URP_VFX_Lit_MV_Sand_Puff","94348b07e5e8bab40bd6c8a1e3df54cd","True","Forward","0","1","Forward","21","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","False","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","2","False","","True","3","True","_ZTest","True","True","0","False","","0","False","","False","True","4","RenderPipeline=UniversalPipeline","RenderType=Transparent=RenderType","Queue=Transparent=Queue=0","UniversalMaterialType=Lit","True","5","True","12","all","0","True","True","2","5","True","_Src","10","True","_Dst","1","1","False","","10","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","True","True","1","True","_ZWrite","True","3","True","_ZTest","True","True","0","False","","0","False","","False","True","1","LightMode=UniversalForward","False","False","0","","0","0","Standard","48","Category","0","0","  Instanced Terrain Normals","1","0","Lighting Model","0","0","Workflow","0","638732650805076132","Surface","1","638729604984611642","  Keep Alpha","0","0","  Refraction Model","0","0","  Blend","0","0","Two Sided","1","0","Alpha Clipping","0","638729605329173967","  Use Shadow Threshold","0","0","Fragment Normal Space","0","0","Forward Only","0","0","Transmission","0","0","  Transmission Shadow","0.5,False,","0","Translucency","0","0","  Translucency Strength","1,False,","0","  Normal Distortion","0.5,False,","0","  Scattering","2,False,","0","  Direct","0.9,False,","0","  Ambient","0.1,False,","0","  Shadow","0.5,False,","0","Cast Shadows","1","0","Receive Shadows","1","0","Specular Highlights","2","0","Environment Reflections","2","0","Receive SSAO","1","0","GPU Instancing","1","0","LOD CrossFade","1","0","Built-in Fog","1","0","_FinalColorxAlpha","0","0","Meta Pass","1","0","Override Baked GI","0","0","Extra Pre Pass","0","0","Tessellation","0","0","  Phong","0","0","  Strength","0.5,False,","0","  Type","0","0","  Tess","16,False,","0","  Min","10,False,","0","  Max","25,False,","0","  Edge Length","16,False,","0","  Max Displacement","25,False,","0","Write Depth","0","0","  Conservative","0","0","Vertex Position","1","0","Debug Display","0","0","Clear Coat","0","0","0","10","False","True","True","True","True","True","True","True","True","True","False","","False","0"]}
{"type":"AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor","id":449,"pos":[-384,128],"params":["Inherit","False","1252","162.95","Thanks to Mirko for the MV tech!","0","Thanks to Mirko for the MV tech!","0,0,0,1","0","0"]}
{"wire":[419,0,277,0]}
{"wire":[419,1,279,0]}
{"wire":[420,0,419,0]}
{"wire":[418,0,335,4]}
{"wire":[331,0,325,1]}
{"wire":[331,1,325,2]}
{"wire":[438,0,436,0]}
{"wire":[334,0,335,1]}
{"wire":[334,1,335,2]}
{"wire":[416,0,437,0]}
{"wire":[416,1,438,0]}
{"wire":[416,2,333,0]}
{"wire":[416,3,333,0]}
{"wire":[416,4,331,0]}
{"wire":[321,0,281,0]}
{"wire":[333,0,334,0]}
{"wire":[332,0,416,0]}
{"wire":[374,0,382,0]}
{"wire":[374,1,394,0]}
{"wire":[336,0,335,3]}
{"wire":[372,0,374,1]}
{"wire":[372,1,374,2]}
{"wire":[385,0,384,0]}
{"wire":[373,0,382,0]}
{"wire":[373,1,371,0]}
{"wire":[369,1,388,0]}
{"wire":[369,2,387,0]}
{"wire":[369,3,373,0]}
{"wire":[369,4,372,0]}
{"wire":[369,5,471,0]}
{"wire":[369,6,282,0]}
{"wire":[369,7,277,0]}
{"wire":[369,8,279,0]}
{"wire":[369,9,386,0]}
{"wire":[397,0,398,0]}
{"wire":[397,1,369,12]}
{"wire":[395,0,398,0]}
{"wire":[395,1,369,11]}
{"wire":[396,0,395,0]}
{"wire":[396,1,397,0]}
{"wire":[396,2,399,0]}
{"wire":[459,0,277,0]}
{"wire":[459,1,279,0]}
{"wire":[401,0,396,0]}
{"wire":[461,0,459,0]}
{"wire":[297,0,403,0]}
{"wire":[455,0,454,0]}
{"wire":[455,1,456,0]}
{"wire":[72,0,10,4]}
{"wire":[72,1,297,3]}
{"wire":[465,0,463,0]}
{"wire":[465,1,464,0]}
{"wire":[453,1,455,0]}
{"wire":[450,0,72,0]}
{"wire":[457,0,453,2]}
{"wire":[457,1,463,0]}
{"wire":[457,2,465,0]}
{"wire":[451,0,450,0]}
{"wire":[451,1,457,0]}
{"wire":[75,0,74,0]}
{"wire":[452,0,451,0]}
{"wire":[73,0,452,0]}
{"wire":[73,1,75,0]}
{"wire":[84,0,79,5]}
{"wire":[84,1,80,0]}
{"wire":[84,2,297,3]}
{"wire":[80,0,78,5]}
{"wire":[80,1,79,5]}
{"wire":[80,2,77,0]}
{"wire":[86,0,81,0]}
{"wire":[86,1,85,0]}
{"wire":[81,0,84,0]}
{"wire":[81,1,10,0]}
{"wire":[141,0,140,0]}
{"wire":[141,1,142,0]}
{"wire":[141,2,470,0]}
{"wire":[77,0,297,1]}
{"wire":[77,1,141,0]}
{"wire":[77,2,469,0]}
{"wire":[76,0,73,0]}
{"wire":[469,0,82,0]}
{"wire":[470,0,143,0]}
{"wire":[145,0,99,0]}
{"wire":[101,0,100,0]}
{"wire":[101,1,102,0]}
{"wire":[100,0,145,0]}
{"wire":[100,1,145,0]}
{"wire":[104,0,108,0]}
{"wire":[104,1,109,0]}
{"wire":[108,0,145,1]}
{"wire":[108,1,145,1]}
{"wire":[106,0,105,0]}
{"wire":[102,0,145,0]}
{"wire":[102,2,135,0]}
{"wire":[102,4,134,0]}
{"wire":[109,0,145,1]}
{"wire":[109,2,137,0]}
{"wire":[109,4,136,0]}
{"wire":[107,0,111,0]}
{"wire":[107,1,110,0]}
{"wire":[111,0,145,2]}
{"wire":[111,1,145,2]}
{"wire":[110,0,145,2]}
{"wire":[110,2,138,0]}
{"wire":[110,4,139,0]}
{"wire":[103,0,101,0]}
{"wire":[103,1,104,0]}
{"wire":[105,0,103,0]}
{"wire":[105,1,107,0]}
{"wire":[99,0,91,0]}
{"wire":[128,0,127,0]}
{"wire":[127,0,126,0]}
{"wire":[127,1,131,0]}
{"wire":[123,0,122,0]}
{"wire":[123,1,122,0]}
{"wire":[124,0,123,0]}
{"wire":[124,1,123,0]}
{"wire":[125,0,124,0]}
{"wire":[125,1,124,0]}
{"wire":[126,0,125,0]}
{"wire":[122,0,121,0]}
{"wire":[122,1,121,0]}
{"wire":[129,0,121,0]}
{"wire":[130,0,129,0]}
{"wire":[131,0,130,0]}
{"wire":[121,0,120,0]}
{"wire":[120,0,119,0]}
{"wire":[119,0,116,0]}
{"wire":[116,0,115,0]}
{"wire":[116,1,117,0]}
{"wire":[115,0,113,0]}
{"wire":[115,1,114,0]}
{"wire":[117,0,97,0]}
{"wire":[117,1,112,0]}
{"wire":[288,0,402,0]}
{"wire":[113,0,94,0]}
{"wire":[112,0,288,3]}
{"wire":[97,0,288,2]}
{"wire":[114,0,96,0]}
{"wire":[96,0,118,0]}
{"wire":[96,2,288,0]}
{"wire":[96,4,288,1]}
{"wire":[94,0,118,0]}
{"wire":[94,2,288,1]}
{"wire":[94,4,288,0]}
{"wire":[364,0,362,0]}
{"wire":[364,1,361,0]}
{"wire":[364,2,389,0]}
{"wire":[400,0,364,0]}
{"wire":[380,0,377,0]}
{"wire":[362,0,381,0]}
{"wire":[362,1,369,11]}
{"wire":[361,0,381,0]}
{"wire":[361,1,369,12]}
{"wire":[440,0,81,0]}
{"wire":[440,9,466,0]}
{"wire":[440,4,467,0]}
{"wire":[440,2,86,0]}
{"wire":[440,6,76,0]}
ASEEND*/
//CHKSM=B08A7D2CC839002A7851C6D588D49AC86B3B7A6D