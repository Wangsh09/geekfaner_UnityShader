// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "geekfaner/Light Model Fragment"
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
				float3 worldNormal : TEXCOORD0;
				float3 worldLightDir : TEXCOORD1;
#ifdef _Phong
				float3 worldView : TEXCOORD2;
				float3 worldReflect : TEXCOORD3;
#else
				float3 worldHalf : TEXCOORD2;
#endif
			};

			v2f vert(a2v v) {
				v2f o;

				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
				o.worldLightDir = normalize(WorldSpaceLightDir(v.vertex));
				fixed3 worldView = normalize(WorldSpaceViewDir(v.vertex));

#ifdef _Phong
				o.worldView = worldView;
				o.worldReflect = reflect(-o.worldLightDir, o.worldNormal);
#else
				o.worldHalf = o.worldLightDir + worldView;
#endif

				return o;
			}

			fixed4 frag(v2f i) : SV_Target{

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(i.worldLightDir);

#ifdef _Lambert
				fixed3 Lambert = saturate(dot(worldNormal, worldLightDir));
				fixed3 diffuse = _LightColor0.xyz * _Diffuse.xyz * Lambert;
#else
				fixed3 HalfLambert = (dot(worldNormal, worldLightDir) * 0.5 + 0.5);
				fixed3 diffuse = _LightColor0.xyz * _Diffuse.xyz * HalfLambert;
#endif

#ifdef _Phong
				fixed3 reflectDir = normalize(i.worldReflect);
				fixed3 worldView = normalize(i.worldView);
				float phong = dot(worldView, reflectDir);
				fixed3 specular = _LightColor0.xyz * _Specular.xyz * pow(saturate(phong), _Gloss);
#else
				fixed3 worldHalf = normalize(i.worldHalf);
				float blinn_phong = dot(worldNormal, worldHalf);
				fixed3 specular = _LightColor0.xyz * _Specular.xyz * pow(saturate(blinn_phong), _Gloss);
#endif


				return fixed4(ambient + diffuse + specular, 1.0);
			}

			ENDCG
		}
	}

	FallBack "Specular"
}
