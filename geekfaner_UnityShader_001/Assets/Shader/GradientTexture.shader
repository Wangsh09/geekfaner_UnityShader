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

			#define _Lambert
			//#define _Phong

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
#ifdef _Phong
				float3 WorldView : TEXCOORD2;
#else
				float3 WorldHalf : TEXCOORD2;
#endif
				float2 uv : TEXCOORD3;
			};

			v2f vert(a2v i)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, i.vertex);
				o.WorldNormal = UnityObjectToWorldNormal(i.normal);
				o.WorldLight = normalize(WorldSpaceLightDir(i.vertex));
				
				float3 WorldView = WorldSpaceViewDir(i.vertex);
#ifdef _Phong
				o.WorldView = WorldView;
#else
				o.WorldHalf = normalize(WorldView) + o.WorldLight;
#endif
				o.uv = TRANSFORM_TEX(i.texcoord, _Gradient);
				return o;
			}

			fixed4 frag(v2f v) : SV_Target
			{
				fixed3 WorldNormal = normalize(v.WorldNormal);
				fixed3 WorldLight = normalize(v.WorldLight);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

#ifdef _Lambert
				fixed Lambert = saturate(dot(WorldNormal, WorldLight));
				fixed3 albedo = tex2D(_Gradient, fixed2(Lambert, Lambert)).rgb * _Color.rgb;
#else
				fixed HalfLambert = dot(WorldNormal, WorldLight) * 0.5 + 0.5;
				fixed3 albedo = tex2D(_Gradient, fixed2(HalfLambert, HalfLambert)).rgb * _Color.rgb;
#endif

				fixed3 diffuse = unity_LightColor0.rgb * albedo;


#ifdef _Phong
				fixed3 WorldView = normalize(v.WorldView);
				fixed3 WorldReflect = normalize(reflect(-WorldLight, WorldNormal));
				fixed3 specular = unity_LightColor0.rgb * _Specular.rgb * pow(saturate(dot(WorldView, WorldReflect)), _Gloss);
#else
				fixed3 WorldHalf = normalize(v.WorldHalf);
				fixed3 specular = unity_LightColor0.rgb * _Specular.rgb * pow(saturate(dot(WorldNormal, WorldHalf)), _Gloss);
#endif

				return fixed4(ambient + diffuse + specular, 1.0);
				
			}

			ENDCG
		}
	}

	Fallback "Specular"
}
