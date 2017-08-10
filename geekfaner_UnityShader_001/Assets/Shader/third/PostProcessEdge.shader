Shader "Geekfaner/PostProcessEdge"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
	}

	SubShader
	{
		ZWrite Off
		Cull Off
		ZTest Always

		Pass
		{
			CGPROGRAM
#pragma vertex vert
#pragma fragment frag

			struct a2v
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv[9] : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			float _EdgeOnly;
			fixed4 _BackGounndColor;
			fixed4 _EdgeColor;

			v2f vert(a2v i)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, i.vertex);
				o.uv[0] = i.uv + float2(-1, -1) * _MainTex_TexelSize.xy;
				o.uv[1] = i.uv + float2(0, -1) * _MainTex_TexelSize.xy;
				o.uv[2] = i.uv + float2(1, -1) * _MainTex_TexelSize.xy;
				o.uv[3] = i.uv + float2(-1, 0) * _MainTex_TexelSize.xy;
				o.uv[4] = i.uv + float2(0, 0) * _MainTex_TexelSize.xy;
				o.uv[5] = i.uv + float2(1, 0) * _MainTex_TexelSize.xy;
				o.uv[6] = i.uv + float2(-1, 1) * _MainTex_TexelSize.xy;
				o.uv[7] = i.uv + float2(0, 1) * _MainTex_TexelSize.xy;
				o.uv[8] = i.uv + float2(1, 1) * _MainTex_TexelSize.xy;

				return o;
			}

			fixed luminance(fixed3 color)
			{
				return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed color[9];
				color[0] = luminance(tex2D(_MainTex, i.uv[0]));
				color[1] = luminance(tex2D(_MainTex, i.uv[1]));
				color[2] = luminance(tex2D(_MainTex, i.uv[2]));
				color[3] = luminance(tex2D(_MainTex, i.uv[3]));
				color[4] = luminance(tex2D(_MainTex, i.uv[4]));
				color[5] = luminance(tex2D(_MainTex, i.uv[5]));
				color[6] = luminance(tex2D(_MainTex, i.uv[6]));
				color[7] = luminance(tex2D(_MainTex, i.uv[7]));
				color[8] = luminance(tex2D(_MainTex, i.uv[8]));
				float edgeX = (-1) * color[0] + (-2) * color[1] + (-1) * color[2] + (1) * color[6] + (2) * color[7] + (1) * color[8];
				float edgeY = (-1) * color[0] + (1) * color[2] + (-2) * color[3] + (2) * color[5] + (-1) * color[6] + (1) * color[8];
				float edge = 1 - abs(edgeX) - abs(edgeY);
				fixed3 edgeOnlyColor = lerp(_EdgeColor, _BackGounndColor, edge).rgb;
				fixed3 edgeWithColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv[4]), edge).rgb;
				fixed3 finalColor = lerp(edgeWithColor, edgeOnlyColor, _EdgeOnly);
				return fixed4(finalColor, 1.0);
			}


			ENDCG

		}
	}
}