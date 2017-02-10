// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "geekfaner/Light Model Vertex"
{
	Properties
	{
		_Diffuse("Diffuse", Color) = (1.0, 1.0, 1.0, 1.0)
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

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				fixed4 color : COLOR0;
			};

			v2f vert(appdata_full v) {
				v2f o;

				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

#ifdef _Lambert 
				fixed3 Lambert = saturate(dot(worldNormal, worldLightDir));
				fixed3 diffuse = _LightColor0.xyz * _Diffuse.xyz * Lambert;
#else
				fixed3 HalfLambert = (dot(worldNormal, worldLightDir) * 0.5 + 0.5);
				fixed3 diffuse = _LightColor0.xyz * _Diffuse.xyz * HalfLambert;
#endif

				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
#ifdef _Phong
				fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
				float phong = dot(viewDir, reflectDir);
				fixed3 specular = _LightColor0.xyz * _Specular.xyz * pow(saturate(phong), _Gloss);
#else
				fixed3 halfDir = normalize(viewDir + worldLightDir);
				float blinn_phong = dot(worldNormal, halfDir);
				fixed3 specular = _LightColor0.xyz * _Specular.xyz * pow(saturate(blinn_phong), _Gloss);
#endif

				o.color = fixed4(diffuse + ambient + specular, 1.0);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				return i.color;
			}

			ENDCG
		}
	}

	FallBack "Specular"
}
