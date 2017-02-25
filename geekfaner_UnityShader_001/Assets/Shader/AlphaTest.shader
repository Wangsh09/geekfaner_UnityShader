Shader "geekfaner/Alpha Test"
{
	Properties
	{
		_Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_MainTex ("Texture", 2D) = "white" {}
		_CutOff ("CutOff", Range(0, 1)) = 0.5
	}

	SubShader
	{
		Tags { "Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout" }

		Pass
		{
			Tags {"LightMode" = "ForwardBase"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"
			
			#define _Lambert

			struct a2v
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 WorldNormal : TEXCOORD1;
				float3 WorldLight : TEXCOORD2;
			};

			float4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _CutOff;
			
			v2f vert (a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.WorldNormal = UnityObjectToWorldNormal(v.normal);
				o.WorldLight = WorldSpaceLightDir(v.vertex);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 WorldNormal = normalize(i.WorldNormal);
				fixed3 WorldLight = normalize(i.WorldLight);

				fixed4 color = tex2D(_MainTex, i.uv);
				clip(color.a - _CutOff);

				fixed3 albedo = color.rgb * _Color;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;

#ifdef _Lambert
				fixed Lambert = saturate(dot(WorldNormal, WorldLight));
				fixed3 diffuse = unity_LightColor0.rgb * albedo * Lambert;
#else
				fixed HalfLambert = dot(WorldNormal, WorldLight) * 0.5 + 0.5;
				fixed3 diffuse = unity_LightColor0.rgb * albedo * HalfLambert;
#endif

				return fixed4(ambient + diffuse, 1.0);
			}
			ENDCG
		}
	}

	Fallback "Transparent/Cutout/VertexLit"
}
