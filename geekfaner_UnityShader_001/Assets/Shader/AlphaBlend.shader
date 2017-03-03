Shader "geekfaner/Alpha Blend"
{
	Properties{
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_MainTex("MainTex", 2D) = "white"{}
		_AlphaScale("AlphaScale", Range(0, 1)) = 0.5
	}

	SubShader{
		Tags{
			"Queue" = "Transparent+1"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}

		//If the transparent object is across by itself, we should use 2 pass, and the first pass is used to compute the depth value.
		//Then the transparent object will not blend with itself.
		/*
		Pass{
			ColorMask 0
		}
		*/

		Pass{
			Tags{
				"LightMode" = "ForwardBase"
			}

			//The reason for turnning ZWrite Off is : 
			//1. If Transparent A and Transparent B cross, if ZWrite is Off, then A and B are blend, even the blend is incorrect, if ZWrite is On, then only the part of A or B is display.
			//2. If the Render Queue is wrong, ZWrite Off for Transparent object can make sure the opaque object is not effect by the transparent object
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			BlendOp Add
			//Draw the back side first
			Cull Front

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			//#define _Lambert

			struct a2v {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 WorldNormal : TEXCOORD1;
				float3 WorldLight : TEXCOORD2;
			};

			float4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _AlphaScale;

			v2f vert(a2v i) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, i.vertex);
				o.uv = i.texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
				o.WorldNormal = UnityObjectToWorldNormal(i.normal);
				o.WorldLight = WorldSpaceLightDir(i.vertex);

				return o;
			}

			fixed4 frag(v2f v) : SV_Target {
				fixed3 WorldNormal = normalize(v.WorldNormal);
				fixed3 WorldLight = normalize(v.WorldLight);

				float4 color = tex2D(_MainTex, v.uv);
				float3 albedo = color.rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				
#ifdef _Lambert
				fixed Lambert = saturate(dot(WorldNormal, WorldLight));
				fixed3 diffuse = unity_LightColor0.xyz * albedo * Lambert;
#else
				fixed HalfLambert = dot(WorldNormal, WorldLight) * 0.5 + 0.5;
				fixed3 diffuse = unity_LightColor0.xyz * albedo * HalfLambert;
#endif

				return fixed4(ambient + diffuse, color.a * _AlphaScale);
			}

			ENDCG
		}

		Pass{
			Tags{
				"LightMode" = "ForwardBase"
			}

			//The reason for turnning ZWrite Off is : 
			//1. If Transparent A and Transparent B cross, if ZWrite is Off, then A and B are blend, even the blend is incorrect, if ZWrite is On, then only the part of A or B is display.
			//2. If the Render Queue is wrong, ZWrite Off for Transparent object can make sure the opaque object is not effect by the transparent object
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			BlendOp Add
			//Then draw the front side
			Cull Back

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			//#define _Lambert

			struct a2v {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 WorldNormal : TEXCOORD1;
				float3 WorldLight : TEXCOORD2;
			};

			float4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _AlphaScale;

			v2f vert(a2v i) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, i.vertex);
				o.uv = i.texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
				o.WorldNormal = UnityObjectToWorldNormal(i.normal);
				o.WorldLight = WorldSpaceLightDir(i.vertex);

				return o;
			}

			fixed4 frag(v2f v) : SV_Target{
				fixed3 WorldNormal = normalize(v.WorldNormal);
				fixed3 WorldLight = normalize(v.WorldLight);

				float4 color = tex2D(_MainTex, v.uv);
				float3 albedo = color.rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

#ifdef _Lambert
				fixed Lambert = saturate(dot(WorldNormal, WorldLight));
				fixed3 diffuse = unity_LightColor0.xyz * albedo * Lambert;
#else
				fixed HalfLambert = dot(WorldNormal, WorldLight) * 0.5 + 0.5;
				fixed3 diffuse = unity_LightColor0.xyz * albedo * HalfLambert;
#endif

				return fixed4(ambient + diffuse, color.a * _AlphaScale);
			}

			ENDCG
		}
	}

	Fallback "Transparent/VertexLit"
}
