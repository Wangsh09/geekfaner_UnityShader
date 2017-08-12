Shader "Geekfaner/PostProcessGosses"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
	}

	SubShader
	{
		CGINCLUDE

		#include "UnityCG.cginc"

		sampler2D _MainTex;
		float4 _MainTex_TexelSize;
		float _blurSpread;

		struct a2v
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};

		struct v2f
		{
			float4 pos : SV_POSITION;
			half2 uv[5] : TEXCOORD0;
		};

		v2f vert_v(a2v v)
		{
			v2f o;
			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			o.uv[0] = v.uv + float2(-2, 0) * _MainTex_TexelSize.xy * _blurSpread;
			o.uv[1] = v.uv + float2(-1, 0) * _MainTex_TexelSize.xy * _blurSpread;
			o.uv[2] = v.uv + float2(0, 0) * _MainTex_TexelSize.xy * _blurSpread;
			o.uv[3] = v.uv + float2(1, 0) * _MainTex_TexelSize.xy * _blurSpread;
			o.uv[4] = v.uv + float2(2, 0) * _MainTex_TexelSize.xy * _blurSpread;

			return o;
		}

		v2f vert_h(a2v v)
		{
			v2f o;
			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

			o.uv[0] = v.uv + float2(0, -2) * _MainTex_TexelSize.xy * _blurSpread;
			o.uv[1] = v.uv + float2(0, -1) * _MainTex_TexelSize.xy * _blurSpread;
			o.uv[2] = v.uv + float2(0, 0) * _MainTex_TexelSize.xy * _blurSpread;
			o.uv[3] = v.uv + float2(0, 1) * _MainTex_TexelSize.xy * _blurSpread;
			o.uv[4] = v.uv + float2(0, 2) * _MainTex_TexelSize.xy * _blurSpread;

			return o;
		}

		fixed4 frag(v2f i) : SV_Target
		{
			fixed3 color[5];
			color[0] = tex2D(_MainTex, i.uv[0]).rgb;
			color[1] = tex2D(_MainTex, i.uv[1]).rgb;
			color[2] = tex2D(_MainTex, i.uv[2]).rgb;
			color[3] = tex2D(_MainTex, i.uv[3]).rgb;
			color[4] = tex2D(_MainTex, i.uv[4]).rgb;

			fixed3 realColor = color[0] * 0.0545 + color[1] * 0.2442 + color[2] * 0.4026 + color[3] * 0.2442 + color[4] * 0.0545;

			return fixed4(realColor, 1.0);
		}

		ENDCG
		ZWrite Off
		ZTest Always
		Cull Off

		Pass
		{
			NAME "GossesBlurV"
			CGPROGRAM
#pragma vertex vert_v
#pragma fragment frag
			
			ENDCG
		}

		Pass
		{
			NAME "GossesBlurH"

			CGPROGRAM
#pragma vertex vert_h
#pragma fragment frag

			ENDCG
		}
	}
}