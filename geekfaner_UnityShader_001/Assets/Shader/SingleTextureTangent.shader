Shader "geekfaner/Single Texture Tangent"
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
				float3 TangentLightDir : TEXCOORD0;
				float4 uv : TEXCOORD1;
#ifdef _Phong
				float3 TangentView : TEXCOORD2;
#else
				float3 TangentHalf : TEXCOORD2;
#endif
			};

			v2f vert(a2v v) {
				v2f o;

				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpTex);

				fixed3 normal = normalize(v.normal);
				fixed3 tangent = normalize(v.tangent.xyz);
				fixed3 binormal = normalize(cross(normal, tangent) * v.tangent.w);
				float3x3 rotation = float3x3(tangent, binormal, normal);

				o.TangentLightDir = mul(rotation, ObjSpaceLightDir(v.vertex));
				float3 TangentView = mul(rotation, ObjSpaceViewDir(v.vertex));

#ifdef _Phong
				o.TangentView = TangentView;
#else
				o.TangentHalf = normalize(o.TangentLightDir) + normalize(TangentView);
#endif
				return o;
			}

			fixed4 frag(v2f i) : SV_Target{

				fixed3 TangentLightDir = normalize(i.TangentLightDir);

				fixed4 packedNormal = tex2D(_BumpTex, i.uv.zw);
				fixed3 TangentNormal = UnpackNormal(packedNormal);
				TangentNormal.xy *= _BumpScale;
				TangentNormal.z = sqrt(1 - saturate(dot(TangentNormal.xy, TangentNormal.xy)));

				fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

#ifdef _Lambert
				fixed3 Lambert = saturate(dot(TangentNormal, TangentLightDir));
				fixed3 diffuse = _LightColor0.xyz * albedo * Lambert;
#else
				fixed3 HalfLambert = (dot(TangentNormal, TangentLightDir) * 0.5 + 0.5);
				fixed3 diffuse = _LightColor0.xyz * albedo * HalfLambert;
#endif

#ifdef _Phong
				fixed3 TangentView = normalize(i.TangentView);
				fixed3 reflectDir = normalize(reflect(-TangentLightDir, TangentNormal));
				float phong = dot(TangentView, reflectDir);
				fixed3 specular = _LightColor0.xyz * _Specular.xyz * pow(saturate(phong), _Gloss);
#else
				fixed3 TangentHalf = normalize(i.TangentHalf);
				float blinn_phong = dot(TangentNormal, TangentHalf);
				fixed3 specular = _LightColor0.xyz * _Specular.xyz * pow(saturate(blinn_phong), _Gloss);
#endif
				return fixed4(diffuse + ambient + specular, 1.0);
			}

			ENDCG
		}
	}

	FallBack "Specular"
}