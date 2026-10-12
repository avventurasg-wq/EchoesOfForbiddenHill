// Made with Amplify Shader Editor v1.9.9.12
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Vefects/SH_Vefects_URP_VFX_Ambient_Sand_MV"
{
	Properties
	{
		_Specular( "Specular", Float ) = 0
		_Smoothness( "Smoothness", Float ) = 0
		[Space(33)][Header(Flipbook)][Space(13)] _Flipbook( "Flipbook", 2D ) = "white" {}
		[Space(33)][Header(Motion Vector)][Space(13)] _MotionVector( "Motion Vector", 2D ) = "white" {}
		_FlipbookColumns( "Flipbook Columns", Float ) = 8
		_FlipbookRows( "Flipbook Rows", Float ) = 8
		_FlipbookSpeed( "Flipbook Speed", Float ) = 64
		_FlipbookStartFrame( "Flipbook Start Frame", Float ) = 0
		_MVInfluence( "MV Influence", Float ) = 0.003
		_MVOffsetFrame( "MV Offset Frame", Float ) = 1
		[Space(33)][Header(Cam Depth Fade)][Space(13)] _CamDepthFadeLength( "Cam Depth Fade Length", Float ) = 1
		_CamDepthFadeOffset( "Cam Depth Fade Offset", Float ) = 0
		_DepthFadeDistance( "Depth Fade Distance", Float ) = 2
		_OpacityPower( "Opacity Power", Float ) = 1
		_OpacityMultiply( "Opacity Multiply", Float ) = 1
		_UseSideFade( "Use Side Fade", Float ) = 1
		_SideFadeMultiply( "Side Fade Multiply", Float ) = 1.15
		_SideFadeMin( "Side Fade Min", Float ) = 0
		_SideFadeMax( "Side Fade Max", Float ) = 1
		_CustomTimeFlipbookLerp( "Custom Time Flipbook Lerp", Float ) = 0
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
		ZWrite Off
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

			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES1
			#define ASE_NEEDS_FRAG_SCREEN_POSITION_NORMALIZED
			#define ASE_NEEDS_WORLD_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_POSITION


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
				float4 ase_color : COLOR;
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_texcoord7 : TEXCOORD7;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord8 : TEXCOORD8;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float _Cull1;
			float _UseSideFade;
			float _SideFadeMultiply;
			float _SideFadeMax;
			float _SideFadeMin;
			float _OpacityMultiply;
			float _OpacityPower;
			float _DepthFadeDistance;
			float _Smoothness;
			float _Specular;
			float _CamDepthFadeLength;
			float _MVOffsetFrame;
			float _CustomTimeFlipbookLerp;
			float _FlipbookStartFrame;
			float _FlipbookSpeed;
			float _FlipbookRows;
			float _FlipbookColumns;
			float _ZWrite1;
			float _ZTest1;
			float _Dst1;
			float _Src1;
			float _MVInfluence;
			float _CamDepthFadeOffset;
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

			sampler2D _Flipbook;
			sampler2D _MotionVector;


			
			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float3 objectToViewPos = TransformWorldToView( TransformObjectToWorld( input.positionOS.xyz ) );
				float eyeDepth = -objectToViewPos.z;
				output.ase_texcoord8.x = eyeDepth;
				
				output.ase_color = input.ase_color;
				output.ase_texcoord6 = input.texcoord;
				output.ase_texcoord7 = input.texcoord1;
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

				float2 texCoord78 = input.ase_texcoord6.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult259 = lerp( input.ase_texcoord6.z , _TimeParameters.x , _CustomTimeFlipbookLerp);
				float time144 = lerpResult259;
				// *** BEGIN Flipbook UV Animation vars ***
				// Total tiles of Flipbook Texture
				float fbtotaltiles82 = _FlipbookColumns * _FlipbookRows;
				// Offsets for cols and rows of Flipbook Texture
				float fbcolsoffset82 = 1.0f / _FlipbookColumns;
				float fbrowsoffset82 = 1.0f / _FlipbookRows;
				// Speed of animation
				float fbspeed82 = time144 * _FlipbookSpeed;
				// UV Tiling (col and row offset)
				float2 fbtiling82 = float2(fbcolsoffset82, fbrowsoffset82);
				// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
				// Calculate current tile linear index
				float fbcurrenttileindex82 = floor( fmod( fbspeed82 + _FlipbookStartFrame, fbtotaltiles82) );
				fbcurrenttileindex82 += ( fbcurrenttileindex82 < 0) ? fbtotaltiles82 : 0;
				// Obtain Offset X coordinate from current tile linear index
				float fblinearindextox82 = round ( fmod ( fbcurrenttileindex82, _FlipbookColumns ) );
				// Multiply Offset X by coloffset
				float fboffsetx82 = fblinearindextox82 * fbcolsoffset82;
				// Obtain Offset Y coordinate from current tile linear index
				float fblinearindextoy82 = round( fmod( ( fbcurrenttileindex82 - fblinearindextox82 ) / _FlipbookColumns, _FlipbookRows ) );
				// Reverse Y to get tiles from Top to Bottom
				fblinearindextoy82 = (int)(_FlipbookRows-1) - fblinearindextoy82;
				// Multiply Offset Y by rowoffset
				float fboffsety82 = fblinearindextoy82 * fbrowsoffset82;
				// UV Offset
				float2 fboffset82 = float2(fboffsetx82, fboffsety82);
				// Flipbook UV
				float2 fbuv82 = texCoord78 * fbtiling82 + fboffset82;
				// *** END Flipbook UV Animation vars ***
				int flipbookFrame82 = ( ( int )fbcurrenttileindex82);
				float2 temp_cast_0 = (1.0).xx;
				float temp_output_140_0 = frac( time144 );
				float fbtotaltiles134 = _FlipbookColumns * _FlipbookRows;
				float fbcolsoffset134 = 1.0f / _FlipbookColumns;
				float fbrowsoffset134 = 1.0f / _FlipbookRows;
				float fbspeed134 = ( time144 + _MVOffsetFrame ) * _FlipbookSpeed;
				float2 fbtiling134 = float2(fbcolsoffset134, fbrowsoffset134);
				float fbcurrenttileindex134 = floor( fmod( fbspeed134 + _FlipbookStartFrame, fbtotaltiles134) );
				fbcurrenttileindex134 += ( fbcurrenttileindex134 < 0) ? fbtotaltiles134 : 0;
				float fblinearindextox134 = round ( fmod ( fbcurrenttileindex134, _FlipbookColumns ) );
				float fboffsetx134 = fblinearindextox134 * fbcolsoffset134;
				float fblinearindextoy134 = round( fmod( ( fbcurrenttileindex134 - fblinearindextox134 ) / _FlipbookColumns, _FlipbookRows ) );
				fblinearindextoy134 = (int)(_FlipbookRows-1) - fblinearindextoy134;
				float fboffsety134 = fblinearindextoy134 * fbrowsoffset134;
				float2 fboffset134 = float2(fboffsetx134, fboffsety134);
				float2 fbuv134 = texCoord78 * fbtiling134 + fboffset134;
				int flipbookFrame134 = ( ( int )fbcurrenttileindex134);
				float2 temp_cast_1 = (1.0).xx;
				float4 lerpResult150 = lerp( tex2D( _Flipbook, ( fbuv82 - ( ( ( ( (tex2D( _MotionVector, fbuv82 )).rg * 2.0 ) - temp_cast_0 ) * temp_output_140_0 ) * _MVInfluence ) ) ) , tex2D( _Flipbook, ( ( ( ( ( (tex2D( _MotionVector, fbuv134 )).rg * 2.0 ) - temp_cast_1 ) * ( 1.0 - temp_output_140_0 ) ) * _MVInfluence ) + fbuv134 ) ) , temp_output_140_0);
				float4 break151 = lerpResult150;
				float3 appendResult216 = (float3(break151.r , break151.g , break151.b));
				float4 lerpResult223 = lerp( input.ase_color , float4( ( (input.ase_color).rgb * appendResult216 ) , 0.0 ) , break151.a);
				float AO_Strength221 = input.ase_texcoord7.z;
				float4 lerpResult219 = lerp( input.ase_color , lerpResult223 , AO_Strength221);
				
				float3 temp_cast_4 = (_Specular).xxx;
				
				float3 temp_cast_5 = (0.0).xxx;
				
				float Erosion146 = input.ase_texcoord6.w;
				float smoothstepResult213 = smoothstep( Erosion146 , ( Erosion146 + 1.0 ) , saturate( break151.a ));
				float temp_output_215_0 = saturate( smoothstepResult213 );
				float lerpResult227 = lerp( ( _DepthFadeDistance * 3.0 ) , _DepthFadeDistance , temp_output_215_0);
				float screenDepth176 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ScreenPosNorm.xy ),_ZBufferParams);
				float distanceDepth176 = saturate( ( screenDepth176 - LinearEyeDepth( ScreenPosNorm.z,_ZBufferParams ) ) / ( lerpResult227 ) );
				float temp_output_231_0 = saturate( ( saturate( pow( saturate( ( saturate( ( input.ase_color.a * temp_output_215_0 ) ) * distanceDepth176 ) ) , _OpacityPower ) ) * _OpacityMultiply ) );
				float3 normalizeResult244 = normalize( ( _WorldSpaceCameraPos - PositionWS ) );
				float dotResult249 = dot( input.ase_normal , normalizeResult244 );
				float lerpResult254 = lerp( _SideFadeMin , _SideFadeMax , saturate( ( ( 1.0 - abs( dotResult249 ) ) * _SideFadeMultiply ) ));
				float lerpResult236 = lerp( temp_output_231_0 , saturate( ( temp_output_231_0 * saturate( ( 1.0 - saturate( lerpResult254 ) ) ) ) ) , _UseSideFade);
				float eyeDepth = input.ase_texcoord8.x;
				float cameraDepthFade206 = (( eyeDepth -_ProjectionParams.y - _CamDepthFadeOffset ) / _CamDepthFadeLength);
				float camFade208 = saturate( cameraDepthFade206 );
				

				float3 BaseColor = lerpResult219.rgb;
				float3 Normal = float3(0, 0, 1);
				float3 Specular = temp_cast_4;
				float Metallic = 0;
				float Smoothness = _Smoothness;
				float Occlusion = 1;
				float3 Emission = temp_cast_5;
				float Alpha = saturate( ( saturate( lerpResult236 ) * camFade208 ) );
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

			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_SCREEN_POSITION_NORMALIZED
			#define ASE_NEEDS_WORLD_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_POSITION


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
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float3 positionWS : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float _Cull1;
			float _UseSideFade;
			float _SideFadeMultiply;
			float _SideFadeMax;
			float _SideFadeMin;
			float _OpacityMultiply;
			float _OpacityPower;
			float _DepthFadeDistance;
			float _Smoothness;
			float _Specular;
			float _CamDepthFadeLength;
			float _MVOffsetFrame;
			float _CustomTimeFlipbookLerp;
			float _FlipbookStartFrame;
			float _FlipbookSpeed;
			float _FlipbookRows;
			float _FlipbookColumns;
			float _ZWrite1;
			float _ZTest1;
			float _Dst1;
			float _Src1;
			float _MVInfluence;
			float _CamDepthFadeOffset;
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

			sampler2D _Flipbook;
			sampler2D _MotionVector;


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
				output.ase_texcoord2.x = eyeDepth;
				
				output.ase_color = input.ase_color;
				output.ase_texcoord1 = input.ase_texcoord;
				output.ase_normal = input.normalOS;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord2.yzw = 0;

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

				float Erosion146 = input.ase_texcoord1.w;
				float2 texCoord78 = input.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult259 = lerp( input.ase_texcoord1.z , _TimeParameters.x , _CustomTimeFlipbookLerp);
				float time144 = lerpResult259;
				// *** BEGIN Flipbook UV Animation vars ***
				// Total tiles of Flipbook Texture
				float fbtotaltiles82 = _FlipbookColumns * _FlipbookRows;
				// Offsets for cols and rows of Flipbook Texture
				float fbcolsoffset82 = 1.0f / _FlipbookColumns;
				float fbrowsoffset82 = 1.0f / _FlipbookRows;
				// Speed of animation
				float fbspeed82 = time144 * _FlipbookSpeed;
				// UV Tiling (col and row offset)
				float2 fbtiling82 = float2(fbcolsoffset82, fbrowsoffset82);
				// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
				// Calculate current tile linear index
				float fbcurrenttileindex82 = floor( fmod( fbspeed82 + _FlipbookStartFrame, fbtotaltiles82) );
				fbcurrenttileindex82 += ( fbcurrenttileindex82 < 0) ? fbtotaltiles82 : 0;
				// Obtain Offset X coordinate from current tile linear index
				float fblinearindextox82 = round ( fmod ( fbcurrenttileindex82, _FlipbookColumns ) );
				// Multiply Offset X by coloffset
				float fboffsetx82 = fblinearindextox82 * fbcolsoffset82;
				// Obtain Offset Y coordinate from current tile linear index
				float fblinearindextoy82 = round( fmod( ( fbcurrenttileindex82 - fblinearindextox82 ) / _FlipbookColumns, _FlipbookRows ) );
				// Reverse Y to get tiles from Top to Bottom
				fblinearindextoy82 = (int)(_FlipbookRows-1) - fblinearindextoy82;
				// Multiply Offset Y by rowoffset
				float fboffsety82 = fblinearindextoy82 * fbrowsoffset82;
				// UV Offset
				float2 fboffset82 = float2(fboffsetx82, fboffsety82);
				// Flipbook UV
				float2 fbuv82 = texCoord78 * fbtiling82 + fboffset82;
				// *** END Flipbook UV Animation vars ***
				int flipbookFrame82 = ( ( int )fbcurrenttileindex82);
				float2 temp_cast_0 = (1.0).xx;
				float temp_output_140_0 = frac( time144 );
				float fbtotaltiles134 = _FlipbookColumns * _FlipbookRows;
				float fbcolsoffset134 = 1.0f / _FlipbookColumns;
				float fbrowsoffset134 = 1.0f / _FlipbookRows;
				float fbspeed134 = ( time144 + _MVOffsetFrame ) * _FlipbookSpeed;
				float2 fbtiling134 = float2(fbcolsoffset134, fbrowsoffset134);
				float fbcurrenttileindex134 = floor( fmod( fbspeed134 + _FlipbookStartFrame, fbtotaltiles134) );
				fbcurrenttileindex134 += ( fbcurrenttileindex134 < 0) ? fbtotaltiles134 : 0;
				float fblinearindextox134 = round ( fmod ( fbcurrenttileindex134, _FlipbookColumns ) );
				float fboffsetx134 = fblinearindextox134 * fbcolsoffset134;
				float fblinearindextoy134 = round( fmod( ( fbcurrenttileindex134 - fblinearindextox134 ) / _FlipbookColumns, _FlipbookRows ) );
				fblinearindextoy134 = (int)(_FlipbookRows-1) - fblinearindextoy134;
				float fboffsety134 = fblinearindextoy134 * fbrowsoffset134;
				float2 fboffset134 = float2(fboffsetx134, fboffsety134);
				float2 fbuv134 = texCoord78 * fbtiling134 + fboffset134;
				int flipbookFrame134 = ( ( int )fbcurrenttileindex134);
				float2 temp_cast_1 = (1.0).xx;
				float4 lerpResult150 = lerp( tex2D( _Flipbook, ( fbuv82 - ( ( ( ( (tex2D( _MotionVector, fbuv82 )).rg * 2.0 ) - temp_cast_0 ) * temp_output_140_0 ) * _MVInfluence ) ) ) , tex2D( _Flipbook, ( ( ( ( ( (tex2D( _MotionVector, fbuv134 )).rg * 2.0 ) - temp_cast_1 ) * ( 1.0 - temp_output_140_0 ) ) * _MVInfluence ) + fbuv134 ) ) , temp_output_140_0);
				float4 break151 = lerpResult150;
				float smoothstepResult213 = smoothstep( Erosion146 , ( Erosion146 + 1.0 ) , saturate( break151.a ));
				float temp_output_215_0 = saturate( smoothstepResult213 );
				float lerpResult227 = lerp( ( _DepthFadeDistance * 3.0 ) , _DepthFadeDistance , temp_output_215_0);
				float screenDepth176 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ScreenPosNorm.xy ),_ZBufferParams);
				float distanceDepth176 = saturate( ( screenDepth176 - LinearEyeDepth( ScreenPosNorm.z,_ZBufferParams ) ) / ( lerpResult227 ) );
				float temp_output_231_0 = saturate( ( saturate( pow( saturate( ( saturate( ( input.ase_color.a * temp_output_215_0 ) ) * distanceDepth176 ) ) , _OpacityPower ) ) * _OpacityMultiply ) );
				float3 normalizeResult244 = normalize( ( _WorldSpaceCameraPos - PositionWS ) );
				float dotResult249 = dot( input.ase_normal , normalizeResult244 );
				float lerpResult254 = lerp( _SideFadeMin , _SideFadeMax , saturate( ( ( 1.0 - abs( dotResult249 ) ) * _SideFadeMultiply ) ));
				float lerpResult236 = lerp( temp_output_231_0 , saturate( ( temp_output_231_0 * saturate( ( 1.0 - saturate( lerpResult254 ) ) ) ) ) , _UseSideFade);
				float eyeDepth = input.ase_texcoord2.x;
				float cameraDepthFade206 = (( eyeDepth -_ProjectionParams.y - _CamDepthFadeOffset ) / _CamDepthFadeLength);
				float camFade208 = saturate( cameraDepthFade206 );
				

				float Alpha = saturate( ( saturate( lerpResult236 ) * camFade208 ) );
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

			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_SCREEN_POSITION_NORMALIZED
			#define ASE_NEEDS_WORLD_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_POSITION


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
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float3 positionWS : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float _Cull1;
			float _UseSideFade;
			float _SideFadeMultiply;
			float _SideFadeMax;
			float _SideFadeMin;
			float _OpacityMultiply;
			float _OpacityPower;
			float _DepthFadeDistance;
			float _Smoothness;
			float _Specular;
			float _CamDepthFadeLength;
			float _MVOffsetFrame;
			float _CustomTimeFlipbookLerp;
			float _FlipbookStartFrame;
			float _FlipbookSpeed;
			float _FlipbookRows;
			float _FlipbookColumns;
			float _ZWrite1;
			float _ZTest1;
			float _Dst1;
			float _Src1;
			float _MVInfluence;
			float _CamDepthFadeOffset;
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

			sampler2D _Flipbook;
			sampler2D _MotionVector;


			
			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float3 objectToViewPos = TransformWorldToView( TransformObjectToWorld( input.positionOS.xyz ) );
				float eyeDepth = -objectToViewPos.z;
				output.ase_texcoord2.x = eyeDepth;
				
				output.ase_color = input.ase_color;
				output.ase_texcoord1 = input.ase_texcoord;
				output.ase_normal = input.normalOS;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord2.yzw = 0;

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

				float Erosion146 = input.ase_texcoord1.w;
				float2 texCoord78 = input.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult259 = lerp( input.ase_texcoord1.z , _TimeParameters.x , _CustomTimeFlipbookLerp);
				float time144 = lerpResult259;
				// *** BEGIN Flipbook UV Animation vars ***
				// Total tiles of Flipbook Texture
				float fbtotaltiles82 = _FlipbookColumns * _FlipbookRows;
				// Offsets for cols and rows of Flipbook Texture
				float fbcolsoffset82 = 1.0f / _FlipbookColumns;
				float fbrowsoffset82 = 1.0f / _FlipbookRows;
				// Speed of animation
				float fbspeed82 = time144 * _FlipbookSpeed;
				// UV Tiling (col and row offset)
				float2 fbtiling82 = float2(fbcolsoffset82, fbrowsoffset82);
				// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
				// Calculate current tile linear index
				float fbcurrenttileindex82 = floor( fmod( fbspeed82 + _FlipbookStartFrame, fbtotaltiles82) );
				fbcurrenttileindex82 += ( fbcurrenttileindex82 < 0) ? fbtotaltiles82 : 0;
				// Obtain Offset X coordinate from current tile linear index
				float fblinearindextox82 = round ( fmod ( fbcurrenttileindex82, _FlipbookColumns ) );
				// Multiply Offset X by coloffset
				float fboffsetx82 = fblinearindextox82 * fbcolsoffset82;
				// Obtain Offset Y coordinate from current tile linear index
				float fblinearindextoy82 = round( fmod( ( fbcurrenttileindex82 - fblinearindextox82 ) / _FlipbookColumns, _FlipbookRows ) );
				// Reverse Y to get tiles from Top to Bottom
				fblinearindextoy82 = (int)(_FlipbookRows-1) - fblinearindextoy82;
				// Multiply Offset Y by rowoffset
				float fboffsety82 = fblinearindextoy82 * fbrowsoffset82;
				// UV Offset
				float2 fboffset82 = float2(fboffsetx82, fboffsety82);
				// Flipbook UV
				float2 fbuv82 = texCoord78 * fbtiling82 + fboffset82;
				// *** END Flipbook UV Animation vars ***
				int flipbookFrame82 = ( ( int )fbcurrenttileindex82);
				float2 temp_cast_0 = (1.0).xx;
				float temp_output_140_0 = frac( time144 );
				float fbtotaltiles134 = _FlipbookColumns * _FlipbookRows;
				float fbcolsoffset134 = 1.0f / _FlipbookColumns;
				float fbrowsoffset134 = 1.0f / _FlipbookRows;
				float fbspeed134 = ( time144 + _MVOffsetFrame ) * _FlipbookSpeed;
				float2 fbtiling134 = float2(fbcolsoffset134, fbrowsoffset134);
				float fbcurrenttileindex134 = floor( fmod( fbspeed134 + _FlipbookStartFrame, fbtotaltiles134) );
				fbcurrenttileindex134 += ( fbcurrenttileindex134 < 0) ? fbtotaltiles134 : 0;
				float fblinearindextox134 = round ( fmod ( fbcurrenttileindex134, _FlipbookColumns ) );
				float fboffsetx134 = fblinearindextox134 * fbcolsoffset134;
				float fblinearindextoy134 = round( fmod( ( fbcurrenttileindex134 - fblinearindextox134 ) / _FlipbookColumns, _FlipbookRows ) );
				fblinearindextoy134 = (int)(_FlipbookRows-1) - fblinearindextoy134;
				float fboffsety134 = fblinearindextoy134 * fbrowsoffset134;
				float2 fboffset134 = float2(fboffsetx134, fboffsety134);
				float2 fbuv134 = texCoord78 * fbtiling134 + fboffset134;
				int flipbookFrame134 = ( ( int )fbcurrenttileindex134);
				float2 temp_cast_1 = (1.0).xx;
				float4 lerpResult150 = lerp( tex2D( _Flipbook, ( fbuv82 - ( ( ( ( (tex2D( _MotionVector, fbuv82 )).rg * 2.0 ) - temp_cast_0 ) * temp_output_140_0 ) * _MVInfluence ) ) ) , tex2D( _Flipbook, ( ( ( ( ( (tex2D( _MotionVector, fbuv134 )).rg * 2.0 ) - temp_cast_1 ) * ( 1.0 - temp_output_140_0 ) ) * _MVInfluence ) + fbuv134 ) ) , temp_output_140_0);
				float4 break151 = lerpResult150;
				float smoothstepResult213 = smoothstep( Erosion146 , ( Erosion146 + 1.0 ) , saturate( break151.a ));
				float temp_output_215_0 = saturate( smoothstepResult213 );
				float lerpResult227 = lerp( ( _DepthFadeDistance * 3.0 ) , _DepthFadeDistance , temp_output_215_0);
				float screenDepth176 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ScreenPosNorm.xy ),_ZBufferParams);
				float distanceDepth176 = saturate( ( screenDepth176 - LinearEyeDepth( ScreenPosNorm.z,_ZBufferParams ) ) / ( lerpResult227 ) );
				float temp_output_231_0 = saturate( ( saturate( pow( saturate( ( saturate( ( input.ase_color.a * temp_output_215_0 ) ) * distanceDepth176 ) ) , _OpacityPower ) ) * _OpacityMultiply ) );
				float3 normalizeResult244 = normalize( ( _WorldSpaceCameraPos - PositionWS ) );
				float dotResult249 = dot( input.ase_normal , normalizeResult244 );
				float lerpResult254 = lerp( _SideFadeMin , _SideFadeMax , saturate( ( ( 1.0 - abs( dotResult249 ) ) * _SideFadeMultiply ) ));
				float lerpResult236 = lerp( temp_output_231_0 , saturate( ( temp_output_231_0 * saturate( ( 1.0 - saturate( lerpResult254 ) ) ) ) ) , _UseSideFade);
				float eyeDepth = input.ase_texcoord2.x;
				float cameraDepthFade206 = (( eyeDepth -_ProjectionParams.y - _CamDepthFadeOffset ) / _CamDepthFadeLength);
				float camFade208 = saturate( cameraDepthFade206 );
				

				float Alpha = saturate( ( saturate( lerpResult236 ) * camFade208 ) );
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

			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES1
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
				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float _Cull1;
			float _UseSideFade;
			float _SideFadeMultiply;
			float _SideFadeMax;
			float _SideFadeMin;
			float _OpacityMultiply;
			float _OpacityPower;
			float _DepthFadeDistance;
			float _Smoothness;
			float _Specular;
			float _CamDepthFadeLength;
			float _MVOffsetFrame;
			float _CustomTimeFlipbookLerp;
			float _FlipbookStartFrame;
			float _FlipbookSpeed;
			float _FlipbookRows;
			float _FlipbookColumns;
			float _ZWrite1;
			float _ZTest1;
			float _Dst1;
			float _Src1;
			float _MVInfluence;
			float _CamDepthFadeOffset;
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

			sampler2D _Flipbook;
			sampler2D _MotionVector;


			
			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float4 ase_positionCS = TransformObjectToHClip( ( input.positionOS ).xyz );
				float4 screenPos = ComputeScreenPos( ase_positionCS );
				output.ase_texcoord5 = screenPos;
				float3 objectToViewPos = TransformWorldToView( TransformObjectToWorld( input.positionOS.xyz ) );
				float eyeDepth = -objectToViewPos.z;
				output.ase_texcoord6.x = eyeDepth;
				
				output.ase_color = input.ase_color;
				output.ase_texcoord3 = input.texcoord;
				output.ase_texcoord4 = input.texcoord1;
				output.ase_normal = input.normalOS;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord6.yzw = 0;

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

				float2 texCoord78 = input.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult259 = lerp( input.ase_texcoord3.z , _TimeParameters.x , _CustomTimeFlipbookLerp);
				float time144 = lerpResult259;
				// *** BEGIN Flipbook UV Animation vars ***
				// Total tiles of Flipbook Texture
				float fbtotaltiles82 = _FlipbookColumns * _FlipbookRows;
				// Offsets for cols and rows of Flipbook Texture
				float fbcolsoffset82 = 1.0f / _FlipbookColumns;
				float fbrowsoffset82 = 1.0f / _FlipbookRows;
				// Speed of animation
				float fbspeed82 = time144 * _FlipbookSpeed;
				// UV Tiling (col and row offset)
				float2 fbtiling82 = float2(fbcolsoffset82, fbrowsoffset82);
				// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
				// Calculate current tile linear index
				float fbcurrenttileindex82 = floor( fmod( fbspeed82 + _FlipbookStartFrame, fbtotaltiles82) );
				fbcurrenttileindex82 += ( fbcurrenttileindex82 < 0) ? fbtotaltiles82 : 0;
				// Obtain Offset X coordinate from current tile linear index
				float fblinearindextox82 = round ( fmod ( fbcurrenttileindex82, _FlipbookColumns ) );
				// Multiply Offset X by coloffset
				float fboffsetx82 = fblinearindextox82 * fbcolsoffset82;
				// Obtain Offset Y coordinate from current tile linear index
				float fblinearindextoy82 = round( fmod( ( fbcurrenttileindex82 - fblinearindextox82 ) / _FlipbookColumns, _FlipbookRows ) );
				// Reverse Y to get tiles from Top to Bottom
				fblinearindextoy82 = (int)(_FlipbookRows-1) - fblinearindextoy82;
				// Multiply Offset Y by rowoffset
				float fboffsety82 = fblinearindextoy82 * fbrowsoffset82;
				// UV Offset
				float2 fboffset82 = float2(fboffsetx82, fboffsety82);
				// Flipbook UV
				float2 fbuv82 = texCoord78 * fbtiling82 + fboffset82;
				// *** END Flipbook UV Animation vars ***
				int flipbookFrame82 = ( ( int )fbcurrenttileindex82);
				float2 temp_cast_0 = (1.0).xx;
				float temp_output_140_0 = frac( time144 );
				float fbtotaltiles134 = _FlipbookColumns * _FlipbookRows;
				float fbcolsoffset134 = 1.0f / _FlipbookColumns;
				float fbrowsoffset134 = 1.0f / _FlipbookRows;
				float fbspeed134 = ( time144 + _MVOffsetFrame ) * _FlipbookSpeed;
				float2 fbtiling134 = float2(fbcolsoffset134, fbrowsoffset134);
				float fbcurrenttileindex134 = floor( fmod( fbspeed134 + _FlipbookStartFrame, fbtotaltiles134) );
				fbcurrenttileindex134 += ( fbcurrenttileindex134 < 0) ? fbtotaltiles134 : 0;
				float fblinearindextox134 = round ( fmod ( fbcurrenttileindex134, _FlipbookColumns ) );
				float fboffsetx134 = fblinearindextox134 * fbcolsoffset134;
				float fblinearindextoy134 = round( fmod( ( fbcurrenttileindex134 - fblinearindextox134 ) / _FlipbookColumns, _FlipbookRows ) );
				fblinearindextoy134 = (int)(_FlipbookRows-1) - fblinearindextoy134;
				float fboffsety134 = fblinearindextoy134 * fbrowsoffset134;
				float2 fboffset134 = float2(fboffsetx134, fboffsety134);
				float2 fbuv134 = texCoord78 * fbtiling134 + fboffset134;
				int flipbookFrame134 = ( ( int )fbcurrenttileindex134);
				float2 temp_cast_1 = (1.0).xx;
				float4 lerpResult150 = lerp( tex2D( _Flipbook, ( fbuv82 - ( ( ( ( (tex2D( _MotionVector, fbuv82 )).rg * 2.0 ) - temp_cast_0 ) * temp_output_140_0 ) * _MVInfluence ) ) ) , tex2D( _Flipbook, ( ( ( ( ( (tex2D( _MotionVector, fbuv134 )).rg * 2.0 ) - temp_cast_1 ) * ( 1.0 - temp_output_140_0 ) ) * _MVInfluence ) + fbuv134 ) ) , temp_output_140_0);
				float4 break151 = lerpResult150;
				float3 appendResult216 = (float3(break151.r , break151.g , break151.b));
				float4 lerpResult223 = lerp( input.ase_color , float4( ( (input.ase_color).rgb * appendResult216 ) , 0.0 ) , break151.a);
				float AO_Strength221 = input.ase_texcoord4.z;
				float4 lerpResult219 = lerp( input.ase_color , lerpResult223 , AO_Strength221);
				
				float3 temp_cast_4 = (0.0).xxx;
				
				float Erosion146 = input.ase_texcoord3.w;
				float smoothstepResult213 = smoothstep( Erosion146 , ( Erosion146 + 1.0 ) , saturate( break151.a ));
				float temp_output_215_0 = saturate( smoothstepResult213 );
				float4 screenPos = input.ase_texcoord5;
				float4 ase_positionSSNorm = screenPos / screenPos.w;
				ase_positionSSNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_positionSSNorm.z : ase_positionSSNorm.z * 0.5 + 0.5;
				float lerpResult227 = lerp( ( _DepthFadeDistance * 3.0 ) , _DepthFadeDistance , temp_output_215_0);
				float screenDepth176 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_positionSSNorm.xy ),_ZBufferParams);
				float distanceDepth176 = saturate( ( screenDepth176 - LinearEyeDepth( ase_positionSSNorm.z,_ZBufferParams ) ) / ( lerpResult227 ) );
				float temp_output_231_0 = saturate( ( saturate( pow( saturate( ( saturate( ( input.ase_color.a * temp_output_215_0 ) ) * distanceDepth176 ) ) , _OpacityPower ) ) * _OpacityMultiply ) );
				float3 normalizeResult244 = normalize( ( _WorldSpaceCameraPos - PositionWS ) );
				float dotResult249 = dot( input.ase_normal , normalizeResult244 );
				float lerpResult254 = lerp( _SideFadeMin , _SideFadeMax , saturate( ( ( 1.0 - abs( dotResult249 ) ) * _SideFadeMultiply ) ));
				float lerpResult236 = lerp( temp_output_231_0 , saturate( ( temp_output_231_0 * saturate( ( 1.0 - saturate( lerpResult254 ) ) ) ) ) , _UseSideFade);
				float eyeDepth = input.ase_texcoord6.x;
				float cameraDepthFade206 = (( eyeDepth -_ProjectionParams.y - _CamDepthFadeOffset ) / _CamDepthFadeLength);
				float camFade208 = saturate( cameraDepthFade206 );
				

				float3 BaseColor = lerpResult219.rgb;
				float3 Emission = temp_cast_4;
				float Alpha = saturate( ( saturate( lerpResult236 ) * camFade208 ) );
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

			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES1
			#define ASE_NEEDS_WORLD_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_POSITION


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
				float4 positionCS : SV_POSITION;
				float3 positionWS : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float _Cull1;
			float _UseSideFade;
			float _SideFadeMultiply;
			float _SideFadeMax;
			float _SideFadeMin;
			float _OpacityMultiply;
			float _OpacityPower;
			float _DepthFadeDistance;
			float _Smoothness;
			float _Specular;
			float _CamDepthFadeLength;
			float _MVOffsetFrame;
			float _CustomTimeFlipbookLerp;
			float _FlipbookStartFrame;
			float _FlipbookSpeed;
			float _FlipbookRows;
			float _FlipbookColumns;
			float _ZWrite1;
			float _ZTest1;
			float _Dst1;
			float _Src1;
			float _MVInfluence;
			float _CamDepthFadeOffset;
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

			sampler2D _Flipbook;
			sampler2D _MotionVector;


			
			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float4 ase_positionCS = TransformObjectToHClip( ( input.positionOS ).xyz );
				float4 screenPos = ComputeScreenPos( ase_positionCS );
				output.ase_texcoord3 = screenPos;
				float3 objectToViewPos = TransformWorldToView( TransformObjectToWorld( input.positionOS.xyz ) );
				float eyeDepth = -objectToViewPos.z;
				output.ase_texcoord4.x = eyeDepth;
				
				output.ase_color = input.ase_color;
				output.ase_texcoord1 = input.ase_texcoord;
				output.ase_texcoord2 = input.ase_texcoord1;
				output.ase_normal = input.normalOS;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord4.yzw = 0;

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

				float2 texCoord78 = input.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult259 = lerp( input.ase_texcoord1.z , _TimeParameters.x , _CustomTimeFlipbookLerp);
				float time144 = lerpResult259;
				// *** BEGIN Flipbook UV Animation vars ***
				// Total tiles of Flipbook Texture
				float fbtotaltiles82 = _FlipbookColumns * _FlipbookRows;
				// Offsets for cols and rows of Flipbook Texture
				float fbcolsoffset82 = 1.0f / _FlipbookColumns;
				float fbrowsoffset82 = 1.0f / _FlipbookRows;
				// Speed of animation
				float fbspeed82 = time144 * _FlipbookSpeed;
				// UV Tiling (col and row offset)
				float2 fbtiling82 = float2(fbcolsoffset82, fbrowsoffset82);
				// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
				// Calculate current tile linear index
				float fbcurrenttileindex82 = floor( fmod( fbspeed82 + _FlipbookStartFrame, fbtotaltiles82) );
				fbcurrenttileindex82 += ( fbcurrenttileindex82 < 0) ? fbtotaltiles82 : 0;
				// Obtain Offset X coordinate from current tile linear index
				float fblinearindextox82 = round ( fmod ( fbcurrenttileindex82, _FlipbookColumns ) );
				// Multiply Offset X by coloffset
				float fboffsetx82 = fblinearindextox82 * fbcolsoffset82;
				// Obtain Offset Y coordinate from current tile linear index
				float fblinearindextoy82 = round( fmod( ( fbcurrenttileindex82 - fblinearindextox82 ) / _FlipbookColumns, _FlipbookRows ) );
				// Reverse Y to get tiles from Top to Bottom
				fblinearindextoy82 = (int)(_FlipbookRows-1) - fblinearindextoy82;
				// Multiply Offset Y by rowoffset
				float fboffsety82 = fblinearindextoy82 * fbrowsoffset82;
				// UV Offset
				float2 fboffset82 = float2(fboffsetx82, fboffsety82);
				// Flipbook UV
				float2 fbuv82 = texCoord78 * fbtiling82 + fboffset82;
				// *** END Flipbook UV Animation vars ***
				int flipbookFrame82 = ( ( int )fbcurrenttileindex82);
				float2 temp_cast_0 = (1.0).xx;
				float temp_output_140_0 = frac( time144 );
				float fbtotaltiles134 = _FlipbookColumns * _FlipbookRows;
				float fbcolsoffset134 = 1.0f / _FlipbookColumns;
				float fbrowsoffset134 = 1.0f / _FlipbookRows;
				float fbspeed134 = ( time144 + _MVOffsetFrame ) * _FlipbookSpeed;
				float2 fbtiling134 = float2(fbcolsoffset134, fbrowsoffset134);
				float fbcurrenttileindex134 = floor( fmod( fbspeed134 + _FlipbookStartFrame, fbtotaltiles134) );
				fbcurrenttileindex134 += ( fbcurrenttileindex134 < 0) ? fbtotaltiles134 : 0;
				float fblinearindextox134 = round ( fmod ( fbcurrenttileindex134, _FlipbookColumns ) );
				float fboffsetx134 = fblinearindextox134 * fbcolsoffset134;
				float fblinearindextoy134 = round( fmod( ( fbcurrenttileindex134 - fblinearindextox134 ) / _FlipbookColumns, _FlipbookRows ) );
				fblinearindextoy134 = (int)(_FlipbookRows-1) - fblinearindextoy134;
				float fboffsety134 = fblinearindextoy134 * fbrowsoffset134;
				float2 fboffset134 = float2(fboffsetx134, fboffsety134);
				float2 fbuv134 = texCoord78 * fbtiling134 + fboffset134;
				int flipbookFrame134 = ( ( int )fbcurrenttileindex134);
				float2 temp_cast_1 = (1.0).xx;
				float4 lerpResult150 = lerp( tex2D( _Flipbook, ( fbuv82 - ( ( ( ( (tex2D( _MotionVector, fbuv82 )).rg * 2.0 ) - temp_cast_0 ) * temp_output_140_0 ) * _MVInfluence ) ) ) , tex2D( _Flipbook, ( ( ( ( ( (tex2D( _MotionVector, fbuv134 )).rg * 2.0 ) - temp_cast_1 ) * ( 1.0 - temp_output_140_0 ) ) * _MVInfluence ) + fbuv134 ) ) , temp_output_140_0);
				float4 break151 = lerpResult150;
				float3 appendResult216 = (float3(break151.r , break151.g , break151.b));
				float4 lerpResult223 = lerp( input.ase_color , float4( ( (input.ase_color).rgb * appendResult216 ) , 0.0 ) , break151.a);
				float AO_Strength221 = input.ase_texcoord2.z;
				float4 lerpResult219 = lerp( input.ase_color , lerpResult223 , AO_Strength221);
				
				float Erosion146 = input.ase_texcoord1.w;
				float smoothstepResult213 = smoothstep( Erosion146 , ( Erosion146 + 1.0 ) , saturate( break151.a ));
				float temp_output_215_0 = saturate( smoothstepResult213 );
				float4 screenPos = input.ase_texcoord3;
				float4 ase_positionSSNorm = screenPos / screenPos.w;
				ase_positionSSNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_positionSSNorm.z : ase_positionSSNorm.z * 0.5 + 0.5;
				float lerpResult227 = lerp( ( _DepthFadeDistance * 3.0 ) , _DepthFadeDistance , temp_output_215_0);
				float screenDepth176 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_positionSSNorm.xy ),_ZBufferParams);
				float distanceDepth176 = saturate( ( screenDepth176 - LinearEyeDepth( ase_positionSSNorm.z,_ZBufferParams ) ) / ( lerpResult227 ) );
				float temp_output_231_0 = saturate( ( saturate( pow( saturate( ( saturate( ( input.ase_color.a * temp_output_215_0 ) ) * distanceDepth176 ) ) , _OpacityPower ) ) * _OpacityMultiply ) );
				float3 normalizeResult244 = normalize( ( _WorldSpaceCameraPos - PositionWS ) );
				float dotResult249 = dot( input.ase_normal , normalizeResult244 );
				float lerpResult254 = lerp( _SideFadeMin , _SideFadeMax , saturate( ( ( 1.0 - abs( dotResult249 ) ) * _SideFadeMultiply ) ));
				float lerpResult236 = lerp( temp_output_231_0 , saturate( ( temp_output_231_0 * saturate( ( 1.0 - saturate( lerpResult254 ) ) ) ) ) , _UseSideFade);
				float eyeDepth = input.ase_texcoord4.x;
				float cameraDepthFade206 = (( eyeDepth -_ProjectionParams.y - _CamDepthFadeOffset ) / _CamDepthFadeLength);
				float camFade208 = saturate( cameraDepthFade206 );
				

				float3 BaseColor = lerpResult219.rgb;
				float Alpha = saturate( ( saturate( lerpResult236 ) * camFade208 ) );
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

			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_SCREEN_POSITION_NORMALIZED
			#define ASE_NEEDS_WORLD_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_POSITION


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
				float3 ase_normal : NORMAL;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float _Cull1;
			float _UseSideFade;
			float _SideFadeMultiply;
			float _SideFadeMax;
			float _SideFadeMin;
			float _OpacityMultiply;
			float _OpacityPower;
			float _DepthFadeDistance;
			float _Smoothness;
			float _Specular;
			float _CamDepthFadeLength;
			float _MVOffsetFrame;
			float _CustomTimeFlipbookLerp;
			float _FlipbookStartFrame;
			float _FlipbookSpeed;
			float _FlipbookRows;
			float _FlipbookColumns;
			float _ZWrite1;
			float _ZTest1;
			float _Dst1;
			float _Src1;
			float _MVInfluence;
			float _CamDepthFadeOffset;
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

			sampler2D _Flipbook;
			sampler2D _MotionVector;


			
			PackedVaryings VertexFunction( Attributes input  )
			{
				PackedVaryings output = (PackedVaryings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				float3 objectToViewPos = TransformWorldToView( TransformObjectToWorld( input.positionOS.xyz ) );
				float eyeDepth = -objectToViewPos.z;
				output.ase_texcoord4.x = eyeDepth;
				
				output.ase_color = input.ase_color;
				output.ase_texcoord3 = input.texcoord;
				output.ase_normal = input.normalOS;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord4.yzw = 0;
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

				float Erosion146 = input.ase_texcoord3.w;
				float2 texCoord78 = input.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult259 = lerp( input.ase_texcoord3.z , _TimeParameters.x , _CustomTimeFlipbookLerp);
				float time144 = lerpResult259;
				// *** BEGIN Flipbook UV Animation vars ***
				// Total tiles of Flipbook Texture
				float fbtotaltiles82 = _FlipbookColumns * _FlipbookRows;
				// Offsets for cols and rows of Flipbook Texture
				float fbcolsoffset82 = 1.0f / _FlipbookColumns;
				float fbrowsoffset82 = 1.0f / _FlipbookRows;
				// Speed of animation
				float fbspeed82 = time144 * _FlipbookSpeed;
				// UV Tiling (col and row offset)
				float2 fbtiling82 = float2(fbcolsoffset82, fbrowsoffset82);
				// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
				// Calculate current tile linear index
				float fbcurrenttileindex82 = floor( fmod( fbspeed82 + _FlipbookStartFrame, fbtotaltiles82) );
				fbcurrenttileindex82 += ( fbcurrenttileindex82 < 0) ? fbtotaltiles82 : 0;
				// Obtain Offset X coordinate from current tile linear index
				float fblinearindextox82 = round ( fmod ( fbcurrenttileindex82, _FlipbookColumns ) );
				// Multiply Offset X by coloffset
				float fboffsetx82 = fblinearindextox82 * fbcolsoffset82;
				// Obtain Offset Y coordinate from current tile linear index
				float fblinearindextoy82 = round( fmod( ( fbcurrenttileindex82 - fblinearindextox82 ) / _FlipbookColumns, _FlipbookRows ) );
				// Reverse Y to get tiles from Top to Bottom
				fblinearindextoy82 = (int)(_FlipbookRows-1) - fblinearindextoy82;
				// Multiply Offset Y by rowoffset
				float fboffsety82 = fblinearindextoy82 * fbrowsoffset82;
				// UV Offset
				float2 fboffset82 = float2(fboffsetx82, fboffsety82);
				// Flipbook UV
				float2 fbuv82 = texCoord78 * fbtiling82 + fboffset82;
				// *** END Flipbook UV Animation vars ***
				int flipbookFrame82 = ( ( int )fbcurrenttileindex82);
				float2 temp_cast_0 = (1.0).xx;
				float temp_output_140_0 = frac( time144 );
				float fbtotaltiles134 = _FlipbookColumns * _FlipbookRows;
				float fbcolsoffset134 = 1.0f / _FlipbookColumns;
				float fbrowsoffset134 = 1.0f / _FlipbookRows;
				float fbspeed134 = ( time144 + _MVOffsetFrame ) * _FlipbookSpeed;
				float2 fbtiling134 = float2(fbcolsoffset134, fbrowsoffset134);
				float fbcurrenttileindex134 = floor( fmod( fbspeed134 + _FlipbookStartFrame, fbtotaltiles134) );
				fbcurrenttileindex134 += ( fbcurrenttileindex134 < 0) ? fbtotaltiles134 : 0;
				float fblinearindextox134 = round ( fmod ( fbcurrenttileindex134, _FlipbookColumns ) );
				float fboffsetx134 = fblinearindextox134 * fbcolsoffset134;
				float fblinearindextoy134 = round( fmod( ( fbcurrenttileindex134 - fblinearindextox134 ) / _FlipbookColumns, _FlipbookRows ) );
				fblinearindextoy134 = (int)(_FlipbookRows-1) - fblinearindextoy134;
				float fboffsety134 = fblinearindextoy134 * fbrowsoffset134;
				float2 fboffset134 = float2(fboffsetx134, fboffsety134);
				float2 fbuv134 = texCoord78 * fbtiling134 + fboffset134;
				int flipbookFrame134 = ( ( int )fbcurrenttileindex134);
				float2 temp_cast_1 = (1.0).xx;
				float4 lerpResult150 = lerp( tex2D( _Flipbook, ( fbuv82 - ( ( ( ( (tex2D( _MotionVector, fbuv82 )).rg * 2.0 ) - temp_cast_0 ) * temp_output_140_0 ) * _MVInfluence ) ) ) , tex2D( _Flipbook, ( ( ( ( ( (tex2D( _MotionVector, fbuv134 )).rg * 2.0 ) - temp_cast_1 ) * ( 1.0 - temp_output_140_0 ) ) * _MVInfluence ) + fbuv134 ) ) , temp_output_140_0);
				float4 break151 = lerpResult150;
				float smoothstepResult213 = smoothstep( Erosion146 , ( Erosion146 + 1.0 ) , saturate( break151.a ));
				float temp_output_215_0 = saturate( smoothstepResult213 );
				float lerpResult227 = lerp( ( _DepthFadeDistance * 3.0 ) , _DepthFadeDistance , temp_output_215_0);
				float screenDepth176 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ScreenPosNorm.xy ),_ZBufferParams);
				float distanceDepth176 = saturate( ( screenDepth176 - LinearEyeDepth( ScreenPosNorm.z,_ZBufferParams ) ) / ( lerpResult227 ) );
				float temp_output_231_0 = saturate( ( saturate( pow( saturate( ( saturate( ( input.ase_color.a * temp_output_215_0 ) ) * distanceDepth176 ) ) , _OpacityPower ) ) * _OpacityMultiply ) );
				float3 normalizeResult244 = normalize( ( _WorldSpaceCameraPos - PositionWS ) );
				float dotResult249 = dot( input.ase_normal , normalizeResult244 );
				float lerpResult254 = lerp( _SideFadeMin , _SideFadeMax , saturate( ( ( 1.0 - abs( dotResult249 ) ) * _SideFadeMultiply ) ));
				float lerpResult236 = lerp( temp_output_231_0 , saturate( ( temp_output_231_0 * saturate( ( 1.0 - saturate( lerpResult254 ) ) ) ) ) , _UseSideFade);
				float eyeDepth = input.ase_texcoord4.x;
				float cameraDepthFade206 = (( eyeDepth -_ProjectionParams.y - _CamDepthFadeOffset ) / _CamDepthFadeLength);
				float camFade208 = saturate( cameraDepthFade206 );
				

				float3 Normal = float3(0, 0, 1);
				float Alpha = saturate( ( saturate( lerpResult236 ) * camFade208 ) );
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

			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_TEXTURE_COORDINATES1
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES1
			#define ASE_NEEDS_FRAG_SCREEN_POSITION_NORMALIZED
			#define ASE_NEEDS_WORLD_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_POSITION


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
				float4 ase_color : COLOR;
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_texcoord7 : TEXCOORD7;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord8 : TEXCOORD8;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float _Cull1;
			float _UseSideFade;
			float _SideFadeMultiply;
			float _SideFadeMax;
			float _SideFadeMin;
			float _OpacityMultiply;
			float _OpacityPower;
			float _DepthFadeDistance;
			float _Smoothness;
			float _Specular;
			float _CamDepthFadeLength;
			float _MVOffsetFrame;
			float _CustomTimeFlipbookLerp;
			float _FlipbookStartFrame;
			float _FlipbookSpeed;
			float _FlipbookRows;
			float _FlipbookColumns;
			float _ZWrite1;
			float _ZTest1;
			float _Dst1;
			float _Src1;
			float _MVInfluence;
			float _CamDepthFadeOffset;
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

			sampler2D _Flipbook;
			sampler2D _MotionVector;


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
				
				output.ase_color = input.ase_color;
				output.ase_texcoord6 = input.texcoord;
				output.ase_texcoord7 = input.texcoord1;
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

				float2 texCoord78 = input.ase_texcoord6.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult259 = lerp( input.ase_texcoord6.z , _TimeParameters.x , _CustomTimeFlipbookLerp);
				float time144 = lerpResult259;
				// *** BEGIN Flipbook UV Animation vars ***
				// Total tiles of Flipbook Texture
				float fbtotaltiles82 = _FlipbookColumns * _FlipbookRows;
				// Offsets for cols and rows of Flipbook Texture
				float fbcolsoffset82 = 1.0f / _FlipbookColumns;
				float fbrowsoffset82 = 1.0f / _FlipbookRows;
				// Speed of animation
				float fbspeed82 = time144 * _FlipbookSpeed;
				// UV Tiling (col and row offset)
				float2 fbtiling82 = float2(fbcolsoffset82, fbrowsoffset82);
				// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
				// Calculate current tile linear index
				float fbcurrenttileindex82 = floor( fmod( fbspeed82 + _FlipbookStartFrame, fbtotaltiles82) );
				fbcurrenttileindex82 += ( fbcurrenttileindex82 < 0) ? fbtotaltiles82 : 0;
				// Obtain Offset X coordinate from current tile linear index
				float fblinearindextox82 = round ( fmod ( fbcurrenttileindex82, _FlipbookColumns ) );
				// Multiply Offset X by coloffset
				float fboffsetx82 = fblinearindextox82 * fbcolsoffset82;
				// Obtain Offset Y coordinate from current tile linear index
				float fblinearindextoy82 = round( fmod( ( fbcurrenttileindex82 - fblinearindextox82 ) / _FlipbookColumns, _FlipbookRows ) );
				// Reverse Y to get tiles from Top to Bottom
				fblinearindextoy82 = (int)(_FlipbookRows-1) - fblinearindextoy82;
				// Multiply Offset Y by rowoffset
				float fboffsety82 = fblinearindextoy82 * fbrowsoffset82;
				// UV Offset
				float2 fboffset82 = float2(fboffsetx82, fboffsety82);
				// Flipbook UV
				float2 fbuv82 = texCoord78 * fbtiling82 + fboffset82;
				// *** END Flipbook UV Animation vars ***
				int flipbookFrame82 = ( ( int )fbcurrenttileindex82);
				float2 temp_cast_0 = (1.0).xx;
				float temp_output_140_0 = frac( time144 );
				float fbtotaltiles134 = _FlipbookColumns * _FlipbookRows;
				float fbcolsoffset134 = 1.0f / _FlipbookColumns;
				float fbrowsoffset134 = 1.0f / _FlipbookRows;
				float fbspeed134 = ( time144 + _MVOffsetFrame ) * _FlipbookSpeed;
				float2 fbtiling134 = float2(fbcolsoffset134, fbrowsoffset134);
				float fbcurrenttileindex134 = floor( fmod( fbspeed134 + _FlipbookStartFrame, fbtotaltiles134) );
				fbcurrenttileindex134 += ( fbcurrenttileindex134 < 0) ? fbtotaltiles134 : 0;
				float fblinearindextox134 = round ( fmod ( fbcurrenttileindex134, _FlipbookColumns ) );
				float fboffsetx134 = fblinearindextox134 * fbcolsoffset134;
				float fblinearindextoy134 = round( fmod( ( fbcurrenttileindex134 - fblinearindextox134 ) / _FlipbookColumns, _FlipbookRows ) );
				fblinearindextoy134 = (int)(_FlipbookRows-1) - fblinearindextoy134;
				float fboffsety134 = fblinearindextoy134 * fbrowsoffset134;
				float2 fboffset134 = float2(fboffsetx134, fboffsety134);
				float2 fbuv134 = texCoord78 * fbtiling134 + fboffset134;
				int flipbookFrame134 = ( ( int )fbcurrenttileindex134);
				float2 temp_cast_1 = (1.0).xx;
				float4 lerpResult150 = lerp( tex2D( _Flipbook, ( fbuv82 - ( ( ( ( (tex2D( _MotionVector, fbuv82 )).rg * 2.0 ) - temp_cast_0 ) * temp_output_140_0 ) * _MVInfluence ) ) ) , tex2D( _Flipbook, ( ( ( ( ( (tex2D( _MotionVector, fbuv134 )).rg * 2.0 ) - temp_cast_1 ) * ( 1.0 - temp_output_140_0 ) ) * _MVInfluence ) + fbuv134 ) ) , temp_output_140_0);
				float4 break151 = lerpResult150;
				float3 appendResult216 = (float3(break151.r , break151.g , break151.b));
				float4 lerpResult223 = lerp( input.ase_color , float4( ( (input.ase_color).rgb * appendResult216 ) , 0.0 ) , break151.a);
				float AO_Strength221 = input.ase_texcoord7.z;
				float4 lerpResult219 = lerp( input.ase_color , lerpResult223 , AO_Strength221);
				
				float3 temp_cast_4 = (_Specular).xxx;
				
				float3 temp_cast_5 = (0.0).xxx;
				
				float Erosion146 = input.ase_texcoord6.w;
				float smoothstepResult213 = smoothstep( Erosion146 , ( Erosion146 + 1.0 ) , saturate( break151.a ));
				float temp_output_215_0 = saturate( smoothstepResult213 );
				float lerpResult227 = lerp( ( _DepthFadeDistance * 3.0 ) , _DepthFadeDistance , temp_output_215_0);
				float screenDepth176 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ScreenPosNorm.xy ),_ZBufferParams);
				float distanceDepth176 = saturate( ( screenDepth176 - LinearEyeDepth( ScreenPosNorm.z,_ZBufferParams ) ) / ( lerpResult227 ) );
				float temp_output_231_0 = saturate( ( saturate( pow( saturate( ( saturate( ( input.ase_color.a * temp_output_215_0 ) ) * distanceDepth176 ) ) , _OpacityPower ) ) * _OpacityMultiply ) );
				float3 normalizeResult244 = normalize( ( _WorldSpaceCameraPos - PositionWS ) );
				float dotResult249 = dot( input.ase_normal , normalizeResult244 );
				float lerpResult254 = lerp( _SideFadeMin , _SideFadeMax , saturate( ( ( 1.0 - abs( dotResult249 ) ) * _SideFadeMultiply ) ));
				float lerpResult236 = lerp( temp_output_231_0 , saturate( ( temp_output_231_0 * saturate( ( 1.0 - saturate( lerpResult254 ) ) ) ) ) , _UseSideFade);
				float eyeDepth = input.ase_texcoord8.x;
				float cameraDepthFade206 = (( eyeDepth -_ProjectionParams.y - _CamDepthFadeOffset ) / _CamDepthFadeLength);
				float camFade208 = saturate( cameraDepthFade206 );
				

				float3 BaseColor = lerpResult219.rgb;
				float3 Normal = float3(0, 0, 1);
				float3 Specular = temp_cast_4;
				float Metallic = 0;
				float Smoothness = _Smoothness;
				float Occlusion = 1;
				float3 Emission = temp_cast_5;
				float Alpha = saturate( ( saturate( lerpResult236 ) * camFade208 ) );
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

			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_SCREEN_POSITION_NORMALIZED
			#define ASE_NEEDS_WORLD_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_POSITION


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
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float3 positionWS : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float _Cull1;
			float _UseSideFade;
			float _SideFadeMultiply;
			float _SideFadeMax;
			float _SideFadeMin;
			float _OpacityMultiply;
			float _OpacityPower;
			float _DepthFadeDistance;
			float _Smoothness;
			float _Specular;
			float _CamDepthFadeLength;
			float _MVOffsetFrame;
			float _CustomTimeFlipbookLerp;
			float _FlipbookStartFrame;
			float _FlipbookSpeed;
			float _FlipbookRows;
			float _FlipbookColumns;
			float _ZWrite1;
			float _ZTest1;
			float _Dst1;
			float _Src1;
			float _MVInfluence;
			float _CamDepthFadeOffset;
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

			sampler2D _Flipbook;
			sampler2D _MotionVector;


			
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
				output.ase_texcoord2.x = eyeDepth;
				
				output.ase_color = input.ase_color;
				output.ase_texcoord1 = input.ase_texcoord;
				output.ase_normal = input.normalOS;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord2.yzw = 0;

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

				float Erosion146 = input.ase_texcoord1.w;
				float2 texCoord78 = input.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult259 = lerp( input.ase_texcoord1.z , _TimeParameters.x , _CustomTimeFlipbookLerp);
				float time144 = lerpResult259;
				// *** BEGIN Flipbook UV Animation vars ***
				// Total tiles of Flipbook Texture
				float fbtotaltiles82 = _FlipbookColumns * _FlipbookRows;
				// Offsets for cols and rows of Flipbook Texture
				float fbcolsoffset82 = 1.0f / _FlipbookColumns;
				float fbrowsoffset82 = 1.0f / _FlipbookRows;
				// Speed of animation
				float fbspeed82 = time144 * _FlipbookSpeed;
				// UV Tiling (col and row offset)
				float2 fbtiling82 = float2(fbcolsoffset82, fbrowsoffset82);
				// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
				// Calculate current tile linear index
				float fbcurrenttileindex82 = floor( fmod( fbspeed82 + _FlipbookStartFrame, fbtotaltiles82) );
				fbcurrenttileindex82 += ( fbcurrenttileindex82 < 0) ? fbtotaltiles82 : 0;
				// Obtain Offset X coordinate from current tile linear index
				float fblinearindextox82 = round ( fmod ( fbcurrenttileindex82, _FlipbookColumns ) );
				// Multiply Offset X by coloffset
				float fboffsetx82 = fblinearindextox82 * fbcolsoffset82;
				// Obtain Offset Y coordinate from current tile linear index
				float fblinearindextoy82 = round( fmod( ( fbcurrenttileindex82 - fblinearindextox82 ) / _FlipbookColumns, _FlipbookRows ) );
				// Reverse Y to get tiles from Top to Bottom
				fblinearindextoy82 = (int)(_FlipbookRows-1) - fblinearindextoy82;
				// Multiply Offset Y by rowoffset
				float fboffsety82 = fblinearindextoy82 * fbrowsoffset82;
				// UV Offset
				float2 fboffset82 = float2(fboffsetx82, fboffsety82);
				// Flipbook UV
				float2 fbuv82 = texCoord78 * fbtiling82 + fboffset82;
				// *** END Flipbook UV Animation vars ***
				int flipbookFrame82 = ( ( int )fbcurrenttileindex82);
				float2 temp_cast_0 = (1.0).xx;
				float temp_output_140_0 = frac( time144 );
				float fbtotaltiles134 = _FlipbookColumns * _FlipbookRows;
				float fbcolsoffset134 = 1.0f / _FlipbookColumns;
				float fbrowsoffset134 = 1.0f / _FlipbookRows;
				float fbspeed134 = ( time144 + _MVOffsetFrame ) * _FlipbookSpeed;
				float2 fbtiling134 = float2(fbcolsoffset134, fbrowsoffset134);
				float fbcurrenttileindex134 = floor( fmod( fbspeed134 + _FlipbookStartFrame, fbtotaltiles134) );
				fbcurrenttileindex134 += ( fbcurrenttileindex134 < 0) ? fbtotaltiles134 : 0;
				float fblinearindextox134 = round ( fmod ( fbcurrenttileindex134, _FlipbookColumns ) );
				float fboffsetx134 = fblinearindextox134 * fbcolsoffset134;
				float fblinearindextoy134 = round( fmod( ( fbcurrenttileindex134 - fblinearindextox134 ) / _FlipbookColumns, _FlipbookRows ) );
				fblinearindextoy134 = (int)(_FlipbookRows-1) - fblinearindextoy134;
				float fboffsety134 = fblinearindextoy134 * fbrowsoffset134;
				float2 fboffset134 = float2(fboffsetx134, fboffsety134);
				float2 fbuv134 = texCoord78 * fbtiling134 + fboffset134;
				int flipbookFrame134 = ( ( int )fbcurrenttileindex134);
				float2 temp_cast_1 = (1.0).xx;
				float4 lerpResult150 = lerp( tex2D( _Flipbook, ( fbuv82 - ( ( ( ( (tex2D( _MotionVector, fbuv82 )).rg * 2.0 ) - temp_cast_0 ) * temp_output_140_0 ) * _MVInfluence ) ) ) , tex2D( _Flipbook, ( ( ( ( ( (tex2D( _MotionVector, fbuv134 )).rg * 2.0 ) - temp_cast_1 ) * ( 1.0 - temp_output_140_0 ) ) * _MVInfluence ) + fbuv134 ) ) , temp_output_140_0);
				float4 break151 = lerpResult150;
				float smoothstepResult213 = smoothstep( Erosion146 , ( Erosion146 + 1.0 ) , saturate( break151.a ));
				float temp_output_215_0 = saturate( smoothstepResult213 );
				float lerpResult227 = lerp( ( _DepthFadeDistance * 3.0 ) , _DepthFadeDistance , temp_output_215_0);
				float screenDepth176 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ScreenPosNorm.xy ),_ZBufferParams);
				float distanceDepth176 = saturate( ( screenDepth176 - LinearEyeDepth( ScreenPosNorm.z,_ZBufferParams ) ) / ( lerpResult227 ) );
				float temp_output_231_0 = saturate( ( saturate( pow( saturate( ( saturate( ( input.ase_color.a * temp_output_215_0 ) ) * distanceDepth176 ) ) , _OpacityPower ) ) * _OpacityMultiply ) );
				float3 normalizeResult244 = normalize( ( _WorldSpaceCameraPos - PositionWS ) );
				float dotResult249 = dot( input.ase_normal , normalizeResult244 );
				float lerpResult254 = lerp( _SideFadeMin , _SideFadeMax , saturate( ( ( 1.0 - abs( dotResult249 ) ) * _SideFadeMultiply ) ));
				float lerpResult236 = lerp( temp_output_231_0 , saturate( ( temp_output_231_0 * saturate( ( 1.0 - saturate( lerpResult254 ) ) ) ) ) , _UseSideFade);
				float eyeDepth = input.ase_texcoord2.x;
				float cameraDepthFade206 = (( eyeDepth -_ProjectionParams.y - _CamDepthFadeOffset ) / _CamDepthFadeLength);
				float camFade208 = saturate( cameraDepthFade206 );
				

				surfaceDescription.Alpha = saturate( ( saturate( lerpResult236 ) * camFade208 ) );
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

			#define ASE_NEEDS_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
			#define ASE_NEEDS_FRAG_SCREEN_POSITION_NORMALIZED
			#define ASE_NEEDS_WORLD_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_POSITION


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
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryings
			{
				ASE_SV_POSITION_QUALIFIERS float4 positionCS : SV_POSITION;
				float3 positionWS : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float _Cull1;
			float _UseSideFade;
			float _SideFadeMultiply;
			float _SideFadeMax;
			float _SideFadeMin;
			float _OpacityMultiply;
			float _OpacityPower;
			float _DepthFadeDistance;
			float _Smoothness;
			float _Specular;
			float _CamDepthFadeLength;
			float _MVOffsetFrame;
			float _CustomTimeFlipbookLerp;
			float _FlipbookStartFrame;
			float _FlipbookSpeed;
			float _FlipbookRows;
			float _FlipbookColumns;
			float _ZWrite1;
			float _ZTest1;
			float _Dst1;
			float _Src1;
			float _MVInfluence;
			float _CamDepthFadeOffset;
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

			sampler2D _Flipbook;
			sampler2D _MotionVector;


			
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
				output.ase_texcoord2.x = eyeDepth;
				
				output.ase_color = input.ase_color;
				output.ase_texcoord1 = input.ase_texcoord;
				output.ase_normal = input.normalOS;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord2.yzw = 0;

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

				float Erosion146 = input.ase_texcoord1.w;
				float2 texCoord78 = input.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult259 = lerp( input.ase_texcoord1.z , _TimeParameters.x , _CustomTimeFlipbookLerp);
				float time144 = lerpResult259;
				// *** BEGIN Flipbook UV Animation vars ***
				// Total tiles of Flipbook Texture
				float fbtotaltiles82 = _FlipbookColumns * _FlipbookRows;
				// Offsets for cols and rows of Flipbook Texture
				float fbcolsoffset82 = 1.0f / _FlipbookColumns;
				float fbrowsoffset82 = 1.0f / _FlipbookRows;
				// Speed of animation
				float fbspeed82 = time144 * _FlipbookSpeed;
				// UV Tiling (col and row offset)
				float2 fbtiling82 = float2(fbcolsoffset82, fbrowsoffset82);
				// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
				// Calculate current tile linear index
				float fbcurrenttileindex82 = floor( fmod( fbspeed82 + _FlipbookStartFrame, fbtotaltiles82) );
				fbcurrenttileindex82 += ( fbcurrenttileindex82 < 0) ? fbtotaltiles82 : 0;
				// Obtain Offset X coordinate from current tile linear index
				float fblinearindextox82 = round ( fmod ( fbcurrenttileindex82, _FlipbookColumns ) );
				// Multiply Offset X by coloffset
				float fboffsetx82 = fblinearindextox82 * fbcolsoffset82;
				// Obtain Offset Y coordinate from current tile linear index
				float fblinearindextoy82 = round( fmod( ( fbcurrenttileindex82 - fblinearindextox82 ) / _FlipbookColumns, _FlipbookRows ) );
				// Reverse Y to get tiles from Top to Bottom
				fblinearindextoy82 = (int)(_FlipbookRows-1) - fblinearindextoy82;
				// Multiply Offset Y by rowoffset
				float fboffsety82 = fblinearindextoy82 * fbrowsoffset82;
				// UV Offset
				float2 fboffset82 = float2(fboffsetx82, fboffsety82);
				// Flipbook UV
				float2 fbuv82 = texCoord78 * fbtiling82 + fboffset82;
				// *** END Flipbook UV Animation vars ***
				int flipbookFrame82 = ( ( int )fbcurrenttileindex82);
				float2 temp_cast_0 = (1.0).xx;
				float temp_output_140_0 = frac( time144 );
				float fbtotaltiles134 = _FlipbookColumns * _FlipbookRows;
				float fbcolsoffset134 = 1.0f / _FlipbookColumns;
				float fbrowsoffset134 = 1.0f / _FlipbookRows;
				float fbspeed134 = ( time144 + _MVOffsetFrame ) * _FlipbookSpeed;
				float2 fbtiling134 = float2(fbcolsoffset134, fbrowsoffset134);
				float fbcurrenttileindex134 = floor( fmod( fbspeed134 + _FlipbookStartFrame, fbtotaltiles134) );
				fbcurrenttileindex134 += ( fbcurrenttileindex134 < 0) ? fbtotaltiles134 : 0;
				float fblinearindextox134 = round ( fmod ( fbcurrenttileindex134, _FlipbookColumns ) );
				float fboffsetx134 = fblinearindextox134 * fbcolsoffset134;
				float fblinearindextoy134 = round( fmod( ( fbcurrenttileindex134 - fblinearindextox134 ) / _FlipbookColumns, _FlipbookRows ) );
				fblinearindextoy134 = (int)(_FlipbookRows-1) - fblinearindextoy134;
				float fboffsety134 = fblinearindextoy134 * fbrowsoffset134;
				float2 fboffset134 = float2(fboffsetx134, fboffsety134);
				float2 fbuv134 = texCoord78 * fbtiling134 + fboffset134;
				int flipbookFrame134 = ( ( int )fbcurrenttileindex134);
				float2 temp_cast_1 = (1.0).xx;
				float4 lerpResult150 = lerp( tex2D( _Flipbook, ( fbuv82 - ( ( ( ( (tex2D( _MotionVector, fbuv82 )).rg * 2.0 ) - temp_cast_0 ) * temp_output_140_0 ) * _MVInfluence ) ) ) , tex2D( _Flipbook, ( ( ( ( ( (tex2D( _MotionVector, fbuv134 )).rg * 2.0 ) - temp_cast_1 ) * ( 1.0 - temp_output_140_0 ) ) * _MVInfluence ) + fbuv134 ) ) , temp_output_140_0);
				float4 break151 = lerpResult150;
				float smoothstepResult213 = smoothstep( Erosion146 , ( Erosion146 + 1.0 ) , saturate( break151.a ));
				float temp_output_215_0 = saturate( smoothstepResult213 );
				float lerpResult227 = lerp( ( _DepthFadeDistance * 3.0 ) , _DepthFadeDistance , temp_output_215_0);
				float screenDepth176 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ScreenPosNorm.xy ),_ZBufferParams);
				float distanceDepth176 = saturate( ( screenDepth176 - LinearEyeDepth( ScreenPosNorm.z,_ZBufferParams ) ) / ( lerpResult227 ) );
				float temp_output_231_0 = saturate( ( saturate( pow( saturate( ( saturate( ( input.ase_color.a * temp_output_215_0 ) ) * distanceDepth176 ) ) , _OpacityPower ) ) * _OpacityMultiply ) );
				float3 normalizeResult244 = normalize( ( _WorldSpaceCameraPos - PositionWS ) );
				float dotResult249 = dot( input.ase_normal , normalizeResult244 );
				float lerpResult254 = lerp( _SideFadeMin , _SideFadeMax , saturate( ( ( 1.0 - abs( dotResult249 ) ) * _SideFadeMultiply ) ));
				float lerpResult236 = lerp( temp_output_231_0 , saturate( ( temp_output_231_0 * saturate( ( 1.0 - saturate( lerpResult254 ) ) ) ) ) , _UseSideFade);
				float eyeDepth = input.ase_texcoord2.x;
				float cameraDepthFade206 = (( eyeDepth -_ProjectionParams.y - _CamDepthFadeOffset ) / _CamDepthFadeLength);
				float camFade208 = saturate( cameraDepthFade206 );
				

				surfaceDescription.Alpha = saturate( ( saturate( lerpResult236 ) * camFade208 ) );
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
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":142,"pos":[-8448,1280],"params":["Inherit","False","Property","_MVOffsetFrame","MV Offset Frame","9","0","Create","True","0","0","0","False","0","False","Object","-1","","1","1","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":143,"pos":[-8448,1152],"params":["Inherit","False","144","time","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor","id":78,"pos":[-8448,384],"params":["Inherit","False","0","-1","2","3","2","SAMPLER2D","","False","0","FLOAT2","1,1","False","1","FLOAT2","0,0","False","5","FLOAT2","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4"]}
{"type":"AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor","id":86,"pos":[-8192,1152],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","1","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.TFHCFlipBookUVAnimation, AmplifyShaderEditor","id":134,"pos":[-8064,1024],"params":["Inherit","False","0","0","7","0","FLOAT2","0,0","False","1","FLOAT","0","False","2","FLOAT","0","False","3","FLOAT","0","False","4","FLOAT","0","False","5","FLOAT","0","False","6","FLOAT","-1","False","4","FLOAT2","0","FLOAT","1","FLOAT","2","INT","3"]}
{"type":"AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor","id":74,"pos":[-7680,16],"params":["Inherit","True","Property","_MotionVector","Motion Vector","3","0","Create","True","0","0","0","False","3","Space(33)","Header(Motion Vector)","Space(13)","False","","c60f9ccc2d6dcec4397ed8d64dd36afd","c60f9ccc2d6dcec4397ed8d64dd36afd","False","white","Auto","Texture2D","False","-1","0","2","SAMPLER2D","0","SAMPLERSTATE","1"]}
{"type":"AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor","id":84,"pos":[-7680,384],"params":["Inherit","True","Property","_TextureSample1","Texture Sample 0","12","0","Create","True","0","0","0","False","0","False","","-1","None","None","True","0","False","white","Auto","False","Instance","-1","Auto","Texture2D","False","8","0","SAMPLER2D","","False","1","FLOAT2","0,0","False","2","FLOAT","0","False","3","FLOAT2","0,0","False","4","FLOAT2","0,0","False","5","FLOAT","1","False","6","FLOAT","0","False","7","SAMPLERSTATE","","False","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor","id":121,"pos":[-7680,1024],"params":["Inherit","True","Property","_TextureSample2","Texture Sample 0","12","0","Create","True","0","0","0","False","0","False","","-1","None","None","True","0","False","white","Auto","False","Instance","-1","Auto","Texture2D","False","8","0","SAMPLER2D","","False","1","FLOAT2","0,0","False","2","FLOAT","0","False","3","FLOAT2","0,0","False","4","FLOAT2","0,0","False","5","FLOAT","1","False","6","FLOAT","0","False","7","SAMPLERSTATE","","False","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.TexCoordVertexDataNode, AmplifyShaderEditor","id":106,"pos":[-8448,1536],"params":["Inherit","False","0","4","0","5","FLOAT4","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4"]}
{"type":"AmplifyShaderEditor.SimpleTimeNode, AmplifyShaderEditor","id":85,"pos":[-8064,1536],"params":["Inherit","False","1","0","FLOAT","1","False","5","FLOAT","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":260,"pos":[-7808,1664],"params":["Inherit","False","Property","_CustomTimeFlipbookLerp","Custom Time Flipbook Lerp","19","0","Create","True","0","0","0","False","0","False","Object","-1","","0","0","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.ComponentMaskNode, AmplifyShaderEditor","id":123,"pos":[-7296,1024],"params":["Inherit","False","True","True","False","False","1","0","COLOR","0,0,0,0","False","1","FLOAT2","0"]}
{"type":"AmplifyShaderEditor.ComponentMaskNode, AmplifyShaderEditor","id":122,"pos":[-7296,384],"params":["Inherit","True","True","True","False","False","1","0","COLOR","0,0,0,0","False","1","FLOAT2","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":136,"pos":[-7040,768],"params":["Inherit","False","Constant","_Float0","Float 0","19","0","Create","True","0","0","0","False","0","False","Object","-1","","2","0","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.LerpOp, AmplifyShaderEditor","id":259,"pos":[-7808,1536],"params":["Inherit","False","3","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":149,"pos":[-6528,640],"params":["Inherit","False","144","time","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":137,"pos":[-6784,768],"params":["Inherit","False","Constant","_Float1","Float 1","19","0","Create","True","0","0","0","False","0","False","Object","-1","","1","0","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":124,"pos":[-7040,1024],"params":["Inherit","False","2","2","0","FLOAT2","0,0","False","1","FLOAT","0","False","1","FLOAT2","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":125,"pos":[-7040,384],"params":["Inherit","False","2","2","0","FLOAT2","0,0","False","1","FLOAT","0","False","1","FLOAT2","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":144,"pos":[-7552,1536],"params":["Inherit","False","time","-1","True","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.FractNode, AmplifyShaderEditor","id":140,"pos":[-6528,768],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.OneMinusNode, AmplifyShaderEditor","id":141,"pos":[-6528,896],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleSubtractOpNode, AmplifyShaderEditor","id":126,"pos":[-6784,384],"params":["Inherit","False","2","0","FLOAT2","0,0","False","1","FLOAT","0","False","1","FLOAT2","0"]}
{"type":"AmplifyShaderEditor.SimpleSubtractOpNode, AmplifyShaderEditor","id":127,"pos":[-6784,1024],"params":["Inherit","False","2","0","FLOAT2","0,0","False","1","FLOAT","0","False","1","FLOAT2","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":77,"pos":[-8448,640],"params":["Inherit","False","Property","_FlipbookColumns","Flipbook Columns","4","0","Create","True","0","0","0","False","0","False","Object","-1","","8","4","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":76,"pos":[-8448,768],"params":["Inherit","False","Property","_FlipbookRows","Flipbook Rows","5","0","Create","True","0","0","0","False","0","False","Object","-1","","8","4","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":80,"pos":[-8448,512],"params":["Inherit","False","Property","_FlipbookStartFrame","Flipbook Start Frame","7","0","Create","True","0","0","0","False","0","False","Object","-1","","0","0","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":79,"pos":[-8448,896],"params":["Inherit","False","Property","_FlipbookSpeed","Flipbook Speed","6","0","Create","True","0","0","0","False","0","False","Object","-1","","64","64","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":148,"pos":[-8064,640],"params":["Inherit","False","144","time","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":129,"pos":[-6528,384],"params":["Inherit","False","2","2","0","FLOAT2","0,0","False","1","FLOAT","0","False","1","FLOAT2","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":138,"pos":[-6272,768],"params":["Inherit","False","Property","_MVInfluence","MV Influence","8","0","Create","True","0","0","0","False","0","False","Object","-1","","0.003","0","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":128,"pos":[-6528,1024],"params":["Inherit","False","2","2","0","FLOAT2","0,0","False","1","FLOAT","0","False","1","FLOAT2","0"]}
{"type":"AmplifyShaderEditor.TFHCFlipBookUVAnimation, AmplifyShaderEditor","id":82,"pos":[-8064,384],"params":["Inherit","False","0","0","7","0","FLOAT2","0,0","False","1","FLOAT","0","False","2","FLOAT","0","False","3","FLOAT","0","False","4","FLOAT","0","False","5","FLOAT","0","False","6","FLOAT","-1","False","4","FLOAT2","0","FLOAT","1","FLOAT","2","INT","3"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":131,"pos":[-6272,384],"params":["Inherit","False","2","2","0","FLOAT2","0,0","False","1","FLOAT","0","False","1","FLOAT2","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":130,"pos":[-6272,1024],"params":["Inherit","False","2","2","0","FLOAT2","0,0","False","1","FLOAT","0","False","1","FLOAT2","0"]}
{"type":"AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor","id":135,"pos":[-6016,1024],"params":["Inherit","False","2","2","0","FLOAT2","0,0","False","1","FLOAT2","0,0","False","1","FLOAT2","0"]}
{"type":"AmplifyShaderEditor.SimpleSubtractOpNode, AmplifyShaderEditor","id":133,"pos":[-6016,256],"params":["Inherit","False","2","0","FLOAT2","0,0","False","1","FLOAT2","0,0","False","1","FLOAT2","0"]}
{"type":"AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor","id":72,"pos":[-6144,-256],"params":["Inherit","True","Property","_Flipbook","Flipbook","2","0","Create","True","0","0","0","False","3","Space(33)","Header(Flipbook)","Space(13)","False","","97dbfe4dfb4f0524f8b644e50ced7497","97dbfe4dfb4f0524f8b644e50ced7497","False","white","Auto","Texture2D","False","-1","0","2","SAMPLER2D","0","SAMPLERSTATE","1"]}
{"type":"AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor","id":83,"pos":[-5760,0],"params":["Inherit","True","Property","_TextureSample0","Texture Sample 0","12","0","Create","True","0","0","0","False","0","False","","-1","None","None","True","0","False","white","Auto","False","Instance","-1","Auto","Texture2D","False","8","0","SAMPLER2D","","False","1","FLOAT2","0,0","False","2","FLOAT","0","False","3","FLOAT2","0,0","False","4","FLOAT2","0,0","False","5","FLOAT","1","False","6","FLOAT","0","False","7","SAMPLERSTATE","","False","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor","id":132,"pos":[-5760,1024],"params":["Inherit","True","Property","_TextureSample3","Texture Sample 0","12","0","Create","True","0","0","0","False","0","False","","-1","None","None","True","0","False","white","Auto","False","Instance","-1","Auto","Texture2D","False","8","0","SAMPLER2D","","False","1","FLOAT2","0,0","False","2","FLOAT","0","False","3","FLOAT2","0,0","False","4","FLOAT2","0,0","False","5","FLOAT","1","False","6","FLOAT","0","False","7","SAMPLERSTATE","","False","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.WorldSpaceCameraPos, AmplifyShaderEditor","id":241,"pos":[-4480,2304],"params":["Inherit","False","0","4","FLOAT3","0","FLOAT","1","FLOAT","2","FLOAT","3"]}
{"type":"AmplifyShaderEditor.WorldPosInputsNode, AmplifyShaderEditor","id":247,"pos":[-4480,2560],"params":["Inherit","False","0","4","FLOAT3","0","FLOAT","1","FLOAT","2","FLOAT","3"]}
{"type":"AmplifyShaderEditor.LerpOp, AmplifyShaderEditor","id":150,"pos":[-5248,0],"params":["Inherit","False","3","0","COLOR","0,0,0,0","False","1","COLOR","0,0,0,0","False","2","FLOAT","0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.SimpleSubtractOpNode, AmplifyShaderEditor","id":242,"pos":[-4096,2304],"params":["Inherit","False","2","0","FLOAT3","0,0,0","False","1","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":146,"pos":[-8064,1792],"params":["Inherit","False","Erosion","-1","True","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.BreakToComponentsNode, AmplifyShaderEditor","id":151,"pos":[-4992,0],"params":["Inherit","False","COLOR","1","0","COLOR","0,0,0,0","False","16","FLOAT","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT","5","FLOAT","6","FLOAT","7","FLOAT","8","FLOAT","9","FLOAT","10","FLOAT","11","FLOAT","12","FLOAT","13","FLOAT","14","FLOAT","15"]}
{"type":"AmplifyShaderEditor.NormalizeNode, AmplifyShaderEditor","id":244,"pos":[-3840,2304],"params":["Inherit","False","False","1","0","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.NormalVertexDataNode, AmplifyShaderEditor","id":248,"pos":[-3840,2048],"params":["Inherit","False","0","5","FLOAT3","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":212,"pos":[-5248,1408],"params":["Inherit","False","146","Erosion","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":105,"pos":[-4864,1152],"params":["Inherit","True","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor","id":214,"pos":[-4864,1536],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","1","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.DotProductOpNode, AmplifyShaderEditor","id":249,"pos":[-3584,2048],"params":["Inherit","False","2","0","FLOAT3","0,0,0","False","1","FLOAT3","0,0,0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SmoothstepOpNode, AmplifyShaderEditor","id":213,"pos":[-4864,1408],"params":["Inherit","False","3","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","1","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":225,"pos":[-3840,1024],"params":["Inherit","False","Property","_DepthFadeDistance","Depth Fade Distance","12","0","Create","True","0","0","0","False","0","False","Object","-1","","2","2","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.AbsOpNode, AmplifyShaderEditor","id":250,"pos":[-3456,2048],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":215,"pos":[-4608,1408],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.VertexColorNode, AmplifyShaderEditor","id":37,"pos":[-4480,-512],"params":["Inherit","False","0","5","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":226,"pos":[-3584,896],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","3","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.OneMinusNode, AmplifyShaderEditor","id":251,"pos":[-3328,2048],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":263,"pos":[-3072,2176],"params":["Inherit","False","Property","_SideFadeMultiply","Side Fade Multiply","16","0","Create","True","0","0","0","False","0","False","Object","-1","","1.15","1.15","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":228,"pos":[-4224,512],"params":["Inherit","True","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.LerpOp, AmplifyShaderEditor","id":227,"pos":[-3328,896],"params":["Inherit","False","3","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":252,"pos":[-3072,2048],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","2","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":229,"pos":[-3968,512],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.DepthFade, AmplifyShaderEditor","id":176,"pos":[-3200,768],"params":["Inherit","False","True","True","False","2","1","FLOAT3","0,0,0","False","0","FLOAT","1","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":262,"pos":[-2816,2048],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":256,"pos":[-2560,2304],"params":["Inherit","False","Property","_SideFadeMax","Side Fade Max","18","0","Create","True","0","0","0","False","0","False","Object","-1","","1","1","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":255,"pos":[-2560,2176],"params":["Inherit","False","Property","_SideFadeMin","Side Fade Min","17","0","Create","True","0","0","0","False","0","False","Object","-1","","0","0","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":177,"pos":[-3200,640],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.LerpOp, AmplifyShaderEditor","id":254,"pos":[-2560,2048],"params":["Inherit","False","3","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":234,"pos":[-2560,640],"params":["Inherit","False","Property","_OpacityPower","Opacity Power","13","0","Create","True","0","0","0","False","0","False","Object","-1","","1","1","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":182,"pos":[-2944,640],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":240,"pos":[-2304,2048],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.PowerNode, AmplifyShaderEditor","id":232,"pos":[-2560,512],"params":["Inherit","False","False","2","0","FLOAT","0","False","1","FLOAT","1","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.OneMinusNode, AmplifyShaderEditor","id":264,"pos":[-2048,2048],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":233,"pos":[-2304,512],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":235,"pos":[-2048,640],"params":["Inherit","False","Property","_OpacityMultiply","Opacity Multiply","14","0","Create","True","0","0","0","False","0","False","Object","-1","","1","1","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":204,"pos":[-512,768],"params":["Inherit","False","Property","_CamDepthFadeLength","Cam Depth Fade Length","10","0","Create","True","0","0","0","False","3","Space(33)","Header(Cam Depth Fade)","Space(13)","False","Object","-1","","1","5","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":205,"pos":[-512,896],"params":["Inherit","False","Property","_CamDepthFadeOffset","Cam Depth Fade Offset","11","0","Create","True","0","0","0","False","0","False","Object","-1","","0","1","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":265,"pos":[-1792,2048],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":230,"pos":[-2048,512],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.CameraDepthFade, AmplifyShaderEditor","id":206,"pos":[-512,640],"params":["Inherit","False","3","2","FLOAT3","0,0,0","False","0","FLOAT","1","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":104,"pos":[-1536,896],"params":["Inherit","True","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":231,"pos":[-1792,512],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":207,"pos":[-256,640],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":237,"pos":[-1280,640],"params":["Inherit","False","Property","_UseSideFade","Use Side Fade","15","0","Create","True","0","0","0","False","0","False","Object","-1","","1","1","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":165,"pos":[-1280,896],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":208,"pos":[0,640],"params":["Inherit","False","camFade","-1","True","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.LerpOp, AmplifyShaderEditor","id":236,"pos":[-1280,512],"params":["Inherit","False","3","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":210,"pos":[-640,384],"params":["Inherit","False","208","camFade","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":266,"pos":[-1024,512],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor","id":49,"pos":[459.26,31.68577],"params":["Inherit","False","1238","166","Auto Register Variables","5","54","53","52","51","50","Lush was here! <3","0.4872068,0.2971698,1,1","0","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":211,"pos":[-640,256],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":50,"pos":[507.2599,79.68589],"params":["Inherit","False","Property","_Cull1","Cull","20","0","Create","True","0","0","0","True","3","Space(13)","Header(AR)","Space(13)","False","Object","-1","","2","2","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":51,"pos":[763.2599,79.68589],"params":["Inherit","False","Property","_Src1","Src","21","0","Create","True","0","0","0","True","0","False","Object","-1","","5","5","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":52,"pos":[1019.26,79.68589],"params":["Inherit","False","Property","_Dst1","Dst","22","0","Create","True","0","0","0","True","0","False","Object","-1","","10","10","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":53,"pos":[1531.26,79.68589],"params":["Inherit","False","Property","_ZTest1","ZTest","24","0","Create","True","0","0","0","True","0","False","Object","-1","","2","2","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":54,"pos":[1275.26,79.68589],"params":["Inherit","False","Property","_ZWrite1","ZWrite","23","0","Create","True","0","0","0","True","0","False","Object","-1","","0","0","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":107,"pos":[-640,0],"params":["Inherit","False","Property","_Specular","Specular","0","0","Create","True","0","0","0","False","0","False","Object","-1","","0","0","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":108,"pos":[-640,128],"params":["Inherit","False","Property","_Smoothness","Smoothness","1","0","Create","True","0","0","0","False","0","False","Object","-1","","0","0","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":209,"pos":[-256,256],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":222,"pos":[-640,-256],"params":["Inherit","False","221","AO Strength","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":217,"pos":[-1152,-128],"params":["Inherit","False","2","2","0","FLOAT3","0,0,0","False","1","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.ComponentMaskNode, AmplifyShaderEditor","id":218,"pos":[-1408,-128],"params":["Inherit","False","True","True","True","False","1","0","COLOR","0,0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.LerpOp, AmplifyShaderEditor","id":223,"pos":[-896,-256],"params":["Inherit","False","3","0","COLOR","0,0,0,0","False","1","COLOR","0,0,0,0","False","2","FLOAT","0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.LerpOp, AmplifyShaderEditor","id":219,"pos":[-640,-384],"params":["Inherit","False","3","0","COLOR","0,0,0,0","False","1","COLOR","0,0,0,0","False","2","FLOAT","0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.DynamicAppendNode, AmplifyShaderEditor","id":216,"pos":[-4736,0],"params":["Inherit","False","FLOAT3","4","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","0","False","3","FLOAT","0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":258,"pos":[-640,-128],"params":["Inherit","False","Constant","_Float5","Float 5","22","0","Create","True","0","0","0","False","0","False","Object","-1","","0","0","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":221,"pos":[-8064,1920],"params":["Inherit","False","AO Strength","-1","True","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.TexCoordVertexDataNode, AmplifyShaderEditor","id":220,"pos":[-8448,1920],"params":["Inherit","False","1","4","0","5","FLOAT4","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":91,"pos":[0,0],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphLitGUI","0","1","New Amplify Shader","94348b07e5e8bab40bd6c8a1e3df54cd","True","ExtraPrePass","0","0","ExtraPrePass","6","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","False","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","4","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Lit","True","3","True","12","all","0","False","True","1","1","False","","0","False","","0","1","False","","0","False","","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","0","False","False","0","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":92,"pos":[0,0],"params":["Float","False","True","-1","2","UnityEditor.ShaderGraphLitGUI","0","15","Vefects/SH_Vefects_URP_VFX_Ambient_Sand_MV","94348b07e5e8bab40bd6c8a1e3df54cd","True","Forward","0","1","Forward","21","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","True","True","0","True","_Cull1","False","False","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","2","False","","True","3","True","_ZTest1","True","True","0","False","","0","False","","False","True","4","RenderPipeline=UniversalPipeline","RenderType=Transparent=RenderType","Queue=Transparent=Queue=0","UniversalMaterialType=Lit","True","4","True","12","all","0","True","True","1","5","True","_Src1","10","True","_Dst1","2","5","False","","10","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","True","True","1","True","_ZWrite1","True","3","True","_ZTest1","True","True","0","False","","0","False","","False","True","1","LightMode=UniversalForward","False","False","0","","0","0","Standard","48","Category","0","0","  Instanced Terrain Normals","1","0","Lighting Model","0","0","Workflow","0","638489975902210172","Surface","1","638489974111807992","  Keep Alpha","0","0","  Refraction Model","0","0","  Blend","0","0","Two Sided","1","0","Alpha Clipping","0","638726435652633129","  Use Shadow Threshold","0","0","Fragment Normal Space","0","0","Forward Only","0","0","Transmission","0","0","  Transmission Shadow","0.5,False,","0","Translucency","0","0","  Translucency Strength","1,False,","0","  Normal Distortion","0.5,False,","0","  Scattering","2,False,","0","  Direct","0.9,False,","0","  Ambient","0.1,False,","0","  Shadow","0.5,False,","0","Cast Shadows","1","0","Receive Shadows","1","0","Specular Highlights","2","0","Environment Reflections","2","0","Receive SSAO","1","0","GPU Instancing","1","0","LOD CrossFade","1","0","Built-in Fog","1","0","_FinalColorxAlpha","0","0","Meta Pass","1","0","Override Baked GI","0","0","Extra Pre Pass","0","0","Tessellation","0","0","  Phong","0","0","  Strength","0.5,False,","0","  Type","0","0","  Tess","16,False,","0","  Min","10,False,","0","  Max","25,False,","0","  Edge Length","16,False,","0","  Max Displacement","25,False,","0","Write Depth","0","0","  Conservative","0","0","Vertex Position","1","0","Debug Display","0","0","Clear Coat","0","0","0","10","False","True","True","True","True","True","True","True","True","True","False","","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":93,"pos":[0,0],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphLitGUI","0","1","New Amplify Shader","94348b07e5e8bab40bd6c8a1e3df54cd","True","ShadowCaster","0","2","ShadowCaster","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","False","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","4","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Lit","True","3","True","12","all","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","False","False","True","False","False","False","False","0","False","","False","False","False","False","False","False","False","False","False","True","1","False","","True","3","False","","False","False","True","1","LightMode=ShadowCaster","False","False","0","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":94,"pos":[0,0],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphLitGUI","0","1","New Amplify Shader","94348b07e5e8bab40bd6c8a1e3df54cd","True","DepthOnly","0","3","DepthOnly","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","False","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","4","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Lit","True","3","True","12","all","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","False","False","True","False","False","False","False","0","False","","False","False","False","False","False","False","False","False","False","True","1","False","","False","False","False","True","1","LightMode=DepthOnly","False","False","0","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":95,"pos":[0,0],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphLitGUI","0","1","New Amplify Shader","94348b07e5e8bab40bd6c8a1e3df54cd","True","Meta","0","4","Meta","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","False","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","4","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Lit","True","3","True","12","all","0","False","False","False","False","False","False","False","False","False","False","False","False","False","False","True","2","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","True","1","LightMode=Meta","False","False","0","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":96,"pos":[0,0],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphLitGUI","0","1","New Amplify Shader","94348b07e5e8bab40bd6c8a1e3df54cd","True","Universal2D","0","5","Universal2D","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","False","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","4","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Lit","True","3","True","12","all","0","False","True","1","5","True","_Src1","10","True","_Dst1","2","5","False","","10","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","False","False","True","1","True","","True","3","True","","True","True","0","False","","0","False","","False","True","1","LightMode=Universal2D","False","False","0","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":97,"pos":[0,0],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphLitGUI","0","1","New Amplify Shader","94348b07e5e8bab40bd6c8a1e3df54cd","True","DepthNormals","0","6","DepthNormals","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","False","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","4","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Lit","True","3","True","12","all","0","False","True","1","1","False","","0","False","","0","1","False","","0","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","True","1","False","","True","3","False","","False","False","True","1","LightMode=DepthNormals","False","False","0","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":98,"pos":[0,0],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphLitGUI","0","1","New Amplify Shader","94348b07e5e8bab40bd6c8a1e3df54cd","True","GBuffer","0","7","GBuffer","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","False","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","4","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Lit","True","3","True","12","all","0","False","True","1","5","True","_Src1","10","True","_Dst1","2","5","False","","10","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","True","","True","3","True","","True","True","0","False","","0","False","","False","True","1","LightMode=UniversalGBuffer","False","True","10","d3d11","gles","metal","vulkan","xboxone","xboxseries","playstation","ps4","ps5","switch","0","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":99,"pos":[0,0],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphLitGUI","0","1","New Amplify Shader","94348b07e5e8bab40bd6c8a1e3df54cd","True","SceneSelectionPass","0","8","SceneSelectionPass","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","False","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","4","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Lit","True","3","True","12","all","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","2","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","True","1","LightMode=SceneSelectionPass","False","False","0","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":100,"pos":[0,0],"params":["Float","False","False","-1","2","UnityEditor.ShaderGraphLitGUI","0","1","New Amplify Shader","94348b07e5e8bab40bd6c8a1e3df54cd","True","ScenePickingPass","0","9","ScenePickingPass","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","False","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","4","RenderPipeline=UniversalPipeline","RenderType=Opaque=RenderType","Queue=Geometry=Queue=0","UniversalMaterialType=Lit","True","3","True","12","all","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","False","True","1","LightMode=Picking","False","False","0","","0","0","Standard","0","False","0"]}
{"wire":[86,0,143,0]}
{"wire":[86,1,142,0]}
{"wire":[134,0,78,0]}
{"wire":[134,1,77,0]}
{"wire":[134,2,76,0]}
{"wire":[134,3,79,0]}
{"wire":[134,4,80,0]}
{"wire":[134,5,86,0]}
{"wire":[84,0,74,0]}
{"wire":[84,1,82,0]}
{"wire":[121,0,74,0]}
{"wire":[121,1,134,0]}
{"wire":[123,0,121,0]}
{"wire":[122,0,84,0]}
{"wire":[259,0,106,3]}
{"wire":[259,1,85,0]}
{"wire":[259,2,260,0]}
{"wire":[124,0,123,0]}
{"wire":[124,1,136,0]}
{"wire":[125,0,122,0]}
{"wire":[125,1,136,0]}
{"wire":[144,0,259,0]}
{"wire":[140,0,149,0]}
{"wire":[141,0,140,0]}
{"wire":[126,0,125,0]}
{"wire":[126,1,137,0]}
{"wire":[127,0,124,0]}
{"wire":[127,1,137,0]}
{"wire":[129,0,126,0]}
{"wire":[129,1,140,0]}
{"wire":[128,0,127,0]}
{"wire":[128,1,141,0]}
{"wire":[82,0,78,0]}
{"wire":[82,1,77,0]}
{"wire":[82,2,76,0]}
{"wire":[82,3,79,0]}
{"wire":[82,4,80,0]}
{"wire":[82,5,148,0]}
{"wire":[131,0,129,0]}
{"wire":[131,1,138,0]}
{"wire":[130,0,128,0]}
{"wire":[130,1,138,0]}
{"wire":[135,0,130,0]}
{"wire":[135,1,134,0]}
{"wire":[133,0,82,0]}
{"wire":[133,1,131,0]}
{"wire":[83,0,72,0]}
{"wire":[83,1,133,0]}
{"wire":[132,0,72,0]}
{"wire":[132,1,135,0]}
{"wire":[150,0,83,0]}
{"wire":[150,1,132,0]}
{"wire":[150,2,140,0]}
{"wire":[242,0,241,0]}
{"wire":[242,1,247,0]}
{"wire":[146,0,106,4]}
{"wire":[151,0,150,0]}
{"wire":[244,0,242,0]}
{"wire":[105,0,151,3]}
{"wire":[214,0,212,0]}
{"wire":[249,0,248,0]}
{"wire":[249,1,244,0]}
{"wire":[213,0,105,0]}
{"wire":[213,1,212,0]}
{"wire":[213,2,214,0]}
{"wire":[250,0,249,0]}
{"wire":[215,0,213,0]}
{"wire":[226,0,225,0]}
{"wire":[251,0,250,0]}
{"wire":[228,0,37,4]}
{"wire":[228,1,215,0]}
{"wire":[227,0,226,0]}
{"wire":[227,1,225,0]}
{"wire":[227,2,215,0]}
{"wire":[252,0,251,0]}
{"wire":[252,1,263,0]}
{"wire":[229,0,228,0]}
{"wire":[176,0,227,0]}
{"wire":[262,0,252,0]}
{"wire":[177,0,229,0]}
{"wire":[177,1,176,0]}
{"wire":[254,0,255,0]}
{"wire":[254,1,256,0]}
{"wire":[254,2,262,0]}
{"wire":[182,0,177,0]}
{"wire":[240,0,254,0]}
{"wire":[232,0,182,0]}
{"wire":[232,1,234,0]}
{"wire":[264,0,240,0]}
{"wire":[233,0,232,0]}
{"wire":[265,0,264,0]}
{"wire":[230,0,233,0]}
{"wire":[230,1,235,0]}
{"wire":[206,0,204,0]}
{"wire":[206,1,205,0]}
{"wire":[104,0,231,0]}
{"wire":[104,1,265,0]}
{"wire":[231,0,230,0]}
{"wire":[207,0,206,0]}
{"wire":[165,0,104,0]}
{"wire":[208,0,207,0]}
{"wire":[236,0,231,0]}
{"wire":[236,1,165,0]}
{"wire":[236,2,237,0]}
{"wire":[266,0,236,0]}
{"wire":[211,0,266,0]}
{"wire":[211,1,210,0]}
{"wire":[209,0,211,0]}
{"wire":[217,0,218,0]}
{"wire":[217,1,216,0]}
{"wire":[218,0,37,0]}
{"wire":[223,0,37,0]}
{"wire":[223,1,217,0]}
{"wire":[223,2,151,3]}
{"wire":[219,0,37,0]}
{"wire":[219,1,223,0]}
{"wire":[219,2,222,0]}
{"wire":[216,0,151,0]}
{"wire":[216,1,151,1]}
{"wire":[216,2,151,2]}
{"wire":[221,0,220,3]}
{"wire":[92,0,219,0]}
{"wire":[92,9,107,0]}
{"wire":[92,4,108,0]}
{"wire":[92,2,258,0]}
{"wire":[92,6,209,0]}
ASEEND*/
//CHKSM=C3A69E6093F349979DB5D33E519176F1D26B49CA