Shader "geekfaner/Gradient Texture"
{
	Properties
	{
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Gradient("Gradient", 2D) = "white" {}
		_Specular("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
		_Gloss("Gloss", Range(8, 256)) = 20
	}

	SubShader
	{
		Tags{}

		Pass{
			Tags{
				"LightMode" = "ForwardBase"
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _Gradient;
			float4 _Gradient_ST;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal: NORMAL;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 WorldNormal : TEXCOORD0;
				float3 WorldLight : TEXCOORD1;
				float3 WorldHalf : TEXCOORD2;
				float2 uv : TEXCOORD3;
			};

			v2f vert(a2v i)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, i.vertex);
				o.WorldNormal = UnityObjectToWorldNormal(i.normal);
				o.WorldLight = normalize(WorldSpaceLightDir(i.vertex));
				
				fixed3 WorldView = normalize(WorldSpaceViewDir(i.vertex));
				o.WorldHalf = WorldView + o.WorldLight;
				o.uv = TRANSFORM_TEX(i.texcoord, _Gradient);
				return o;
			}

			fixed4 frag(v2f v) : SV_Target
			{
				fixed3 WorldNormal = normalize(v.WorldNormal);
				fixed3 WorldLight = normalize(v.WorldLight);
				fixed3 WorldHalf = normalize(v.WorldHalf);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed HalfLambert = dot(WorldNormal, WorldLight) * 0.5 + 0.5;
				fixed3 albedo = tex2D(_Gradient, fixed2(HalfLambert, HalfLambert)).rgb * _Color.rgb;

				fixed3 diffuse = unity_LightColor0.rgb * albedo;

				fixed3 specular = unity_LightColor0.rgb * _Specular.rgb * pow(saturate(dot(WorldNormal, WorldHalf)), _Gloss);

				return fixed4(ambient + diffuse + specular, 1.0);
				
			}

			ENDCG
		}
	}

	Fallback "Specular"
}
