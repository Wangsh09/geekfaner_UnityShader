Shader "geekfaner/PostProcess GaussianBlur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}

	SubShader
	{
		CGINCLUDE

		#include "UnityCG.cginc"

		sampler2D _MainTex;
		float4 _MainTex_TexelSize;
		float _BlurSize;

		struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};

		struct v2f
		{
			float4 pos : SV_POSITION;
			half2 uv[5] : TEXCOORD0;
		};

		v2f vertH(appdata v)
		{
			v2f o;
			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			o.uv[0] = v.uv;
			o.uv[1] = v.uv + float2(0.0, _MainTex_TexelSize.y * 1) * _BlurSize;
			o.uv[2] = v.uv + float2(0.0, _MainTex_TexelSize.y * (-1)) * _BlurSize;
			o.uv[3] = v.uv + float2(0.0, _MainTex_TexelSize.y * 2) * _BlurSize;
			o.uv[4] = v.uv + float2(0.0, _MainTex_TexelSize.y * (-2)) * _BlurSize;
			return o;
		}

		v2f vertV(appdata v)
		{
			v2f o;
			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			o.uv[0] = v.uv;
			o.uv[1] = v.uv + float2(_MainTex_TexelSize.y * 1, 0.0) * _BlurSize;
			o.uv[2] = v.uv + float2(_MainTex_TexelSize.y * (-1), 0.0) * _BlurSize;
			o.uv[3] = v.uv + float2(_MainTex_TexelSize.y * 2, 0.0) * _BlurSize;
			o.uv[4] = v.uv + float2(_MainTex_TexelSize.y * (-2), 0.0) * _BlurSize;
			return o;
		}

		fixed4 frag(v2f i) : SV_Target
		{
			float weight[3] = { 0.4026, 0.2442, 0.0545 };

			fixed4 sum = tex2D(_MainTex, i.uv[0]) * weight[0];
			for (int j = 1; j < 3; j++)
			{
				sum += tex2D(_MainTex, i.uv[j * 2 - 1]) * weight[j];
				sum += tex2D(_MainTex, i.uv[j * 2]) * weight[j];
			}

			return sum;
		}
		ENDCG

		ZTest Always
		Cull Off
		ZWrite Off

		Pass
		{
			NAME "GaussianBlurH"
			
			CGPROGRAM
			#pragma vertex vertH
			#pragma fragment frag

			ENDCG
		}

		Pass
		{
			NAME "GaussianBlurV"

			CGPROGRAM
			#pragma vertex vertV
			#pragma fragment frag

			ENDCG
		}
	}
}
