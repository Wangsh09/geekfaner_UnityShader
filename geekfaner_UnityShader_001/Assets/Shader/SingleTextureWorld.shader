// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "geekfaner/Single Texture World"
{
	Properties
	{
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_MainTex("MainTex", 2D) = "white" {}
		_BumpTex("BumpTex", 2D) = "bump" {}
		_BumpScale("BumpScale", Range(0,1)) = 1.0
		_Specular("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
		_Gloss("Gloss", Range(8.0, 256)) = 20
	}

	SubShader{
		Tags{
		}

		Pass{
			Tags{
				"LightMode" = "ForwardBase"
			}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			//#define _Lambert
			//#define _Phong

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpTex;
			float4 _BumpTex_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float4 WorldNormal : TEXCOORD1;
				float4 WorldBinormal : TEXCOORD2;
				float4 WolrdTangent : TEXCOORD3;
				float3 WolrdView : TEXCOORD4;
			};

			v2f vert(a2v v) {
				v2f o;

				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpTex);

				float3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;

				o.WorldNormal.xyz = UnityObjectToWorldNormal(v.normal);
				o.WolrdTangent.xyz = UnityObjectToWorldDir(v.tangent);
				o.WorldBinormal.xyz = UnityObjectToWorldDir(binormal);

				float3 WorldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.WorldNormal.w = WorldPos.x;
				o.WolrdTangent.w = WorldPos.y;
				o.WorldBinormal.w = WorldPos.z;

				o.WolrdView = WorldSpaceViewDir(v.vertex);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target{

				float3x3 TtoWRotation = float3x3(float3(i.WolrdTangent.x, i.WorldBinormal.x, i.WorldNormal.x), float3(i.WolrdTangent.y, i.WorldBinormal.y, i.WorldNormal.y), float3(i.WolrdTangent.z, i.WorldBinormal.z, i.WorldNormal.z));
				float3 WorldPos = float3(i.WolrdTangent.w, i.WorldBinormal.w, i.WorldNormal.w);

				fixed3 WorldLightDir = normalize(UnityWorldSpaceLightDir(WorldPos));
				fixed3 WorldView = normalize(i.WolrdView);

				fixed4 packedNormal = tex2D(_BumpTex, i.uv.zw);
				fixed3 TangentNormal = UnpackNormal(packedNormal);
				TangentNormal.xy *= _BumpScale;
				TangentNormal.z = sqrt(1 - saturate(dot(TangentNormal.xy, TangentNormal.xy)));
				fixed3 worldNormal = normalize(mul(TtoWRotation, TangentNormal));

				fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

#ifdef _Lambert
				fixed3 Lambert = saturate(dot(worldNormal, WorldLightDir));
				fixed3 diffuse = _LightColor0.xyz * albedo * Lambert;
#else
				fixed3 HalfLambert = (dot(worldNormal, WorldLightDir) * 0.5 + 0.5);
				fixed3 diffuse = _LightColor0.xyz * albedo * HalfLambert;
#endif

#ifdef _Phong
				fixed3 reflectDir = normalize(reflect(-WorldLightDir, worldNormal));
				float phong = dot(WorldView, reflectDir);
				fixed3 specular = _LightColor0.xyz * _Specular.xyz * pow(saturate(phong), _Gloss);
#else
				fixed3 WorldHalf = normalize(WorldLightDir + WorldView);
				float blinn_phong = dot(worldNormal, WorldHalf);
				fixed3 specular = _LightColor0.xyz * _Specular.xyz * pow(saturate(blinn_phong), _Gloss);
#endif
				return fixed4(diffuse + ambient + specular, 1.0);
			}

			ENDCG
		}
	}

	FallBack "Specular"
}