Shader "Geekfaner/PostProcessBloom2"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_BloomTex("BloomTex", 2D) = "white" {}
	}

	SubShader
	{
		CGINCLUDE

		struct a2v1
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};

		struct v2f1
		{
			float4 pos : SV_POSITION;
			float2 uv : TEXCOORD0;
		};

		sampler2D _MainTex;
		float4 _MainTex_TexelSize;
		float _BlurSize;
		sampler2D _BloomTex;
		fixed _BloomColor;

		v2f1 vert1(a2v1 v)
		{
			v2f1 o;
			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			o.uv = v.uv;

			return o;
		}

		fixed luminance(fixed4 color)
		{
			return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
		}

		fixed4 frag1(v2f1 i) : SV_Target
		{
			fixed4 color = tex2D(_MainTex, i.uv);
			if (luminance(color) < _BloomColor)
			{
				color = fixed4(0.0, 0.0, 0.0, 1.0);
			}

			return color;
		}

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
			o.uv[1] = v.uv + float2(_MainTex_TexelSize.x * 1, 0.0) * _BlurSize;
			o.uv[2] = v.uv + float2(_MainTex_TexelSize.x * (-1), 0.0) * _BlurSize;
			o.uv[3] = v.uv + float2(_MainTex_TexelSize.x * 2, 0.0) * _BlurSize;
			o.uv[4] = v.uv + float2(_MainTex_TexelSize.x * (-2), 0.0) * _BlurSize;
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

		ZWrite Off
		ZTest Always
		Cull Off

		Pass
		{
			CGPROGRAM
#pragma vertex vert1
#pragma fragment frag1


			ENDCG
		}

		Pass
		{

			CGPROGRAM
#pragma vertex vertH
#pragma fragment frag

			ENDCG
		}

		Pass
		{

			CGPROGRAM
#pragma vertex vertV
#pragma fragment frag

			ENDCG
		}

		Pass
		{
			CGPROGRAM
#pragma vertex vert3
#pragma fragment frag3

			struct a2v3
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f3
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;

			};


			v2f3 vert3(a2v3 v)
			{
				v2f3 o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;

				return o;
			}

			fixed4 frag3(v2f3 i) : SV_Target
			{
				fixed4 Bloomcolor = tex2D(_BloomTex, float2(i.uv.x, 1 - i.uv.y));
				fixed4 color = tex2D(_MainTex, i.uv);

				return Bloomcolor + color;
			}

			ENDCG
				
		}
	}
}