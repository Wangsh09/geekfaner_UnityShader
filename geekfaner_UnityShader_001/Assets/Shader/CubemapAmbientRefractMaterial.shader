Shader "geekfaner/Cubemap Ambient Refract Material"
{
	Properties
	{
		_Color("_Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_RefractColor("_RefractColor", Color) = (1.0, 1.0, 1.0, 1.0)
		_RefractFactor("_RefractFactor", Range(0, 1)) = 1.0
		_RefractRatio("_RefractRatio", Range(0.1, 1)) = 0.5
		_RefractCubemap("_RefractCubemap", Cube) = "_skybox" {}
	}

	SubShader
	{
		Pass
		{
			Tags{
				"LightMode" = "ForwardBase"
			}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			fixed4 _Color;
			fixed4 _RefractColor;
			fixed _RefractFactor;
			fixed _RefractRatio;
			samplerCUBE _RefractCubemap;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float3 WorldNormal : TEXCOORD0;
				float4 WorldPos : TEXCOORD1;
				float3 WorldRefract : TEXCOORD2;
				SHADOW_COORDS(3)
			};

			v2f vert(a2v i) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, i.vertex);
				o.WorldPos = mul(unity_ObjectToWorld, i.vertex);

				o.WorldNormal = normalize(UnityObjectToWorldNormal(i.normal));
				fixed3 worldView = normalize(WorldSpaceViewDir(i.vertex));
				o.WorldRefract = refract(-worldView, o.WorldNormal, _RefractRatio);
				TRANSFER_SHADOW(o);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target {
				fixed3 WorldNormal = normalize(i.WorldNormal);
				fixed3 WorldLight = normalize(UnityWorldSpaceLightDir(i.WorldPos));

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

#ifdef _Lambert
				fixed Lambert = saturate(dot(WorldNormal, WorldLight));
				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * Lambert;
#else
				fixed HalfLambert = dot(WorldNormal, WorldLight) * 0.5 + 0.5;
				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * HalfLambert;
#endif

				UNITY_LIGHT_ATTENUATION(atten, i, i.WorldPos);

				fixed3 refract = texCUBE(_RefractCubemap, i.WorldRefract).rgb * _RefractColor.rgb;
				fixed3 color = ambient + lerp(diffuse, refract, _RefractFactor) * atten;
				return fixed4(color, 1.0);
			}

			ENDCG
		}
	}

	Fallback "Diffuse"
}
