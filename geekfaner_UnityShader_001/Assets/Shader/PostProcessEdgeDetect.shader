Shader "geekfaner/PostProcess Edge Detect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			half4 _MainTex_TexelSize;
			fixed _RenderColorOrBackGroundColor;
			fixed4 _EdgeColor;
			fixed4 _BackGroundColor;

			struct appdata
			{
				float4 vertex : POSITION;
				half2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				half2 uv[9] : TEXCOORD0;
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				o.uv[0] = v.uv + _MainTex_TexelSize * half2(-1, 1);
				o.uv[1] = v.uv + _MainTex_TexelSize * half2(0, 1);
				o.uv[2] = v.uv + _MainTex_TexelSize * half2(1, 1);
				o.uv[3] = v.uv + _MainTex_TexelSize * half2(-1, 0);
				o.uv[4] = v.uv + _MainTex_TexelSize * half2(0, 0);
				o.uv[5] = v.uv + _MainTex_TexelSize * half2(1, 0);
				o.uv[6] = v.uv + _MainTex_TexelSize * half2(-1, -1);
				o.uv[7] = v.uv + _MainTex_TexelSize * half2(0, -1);
				o.uv[8] = v.uv + _MainTex_TexelSize * half2(1, -1);
				return o;
			}

			fixed luminance(fixed3 i)
			{
				return 0.2125 * i.x + 0.7154 * i.y + 0.0721 * i.z;
			}

			fixed CheckSobel(v2f i)
			{
				float Gx[9] = { -1, -2, -1, 0, 0, 0, 1, 2, 1 };
				float Gy[9] = { -1, 0, 1, -2, 0, 2, -1, 0, 1 };
				float EdgeX = 0.0f;
				float EdgeY = 0.0f;
				for (int j = 0; j < 9; j++)
				{
					fixed luminanceColor = luminance(tex2D(_MainTex, i.uv[j]));
					EdgeX += luminanceColor * Gx[j];
					EdgeY += luminanceColor * Gy[j];
				}

				return 1 - abs(EdgeX) - abs(EdgeY);
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed sobel = CheckSobel(i);

				fixed4 renderTex = tex2D(_MainTex, i.uv[4]);

				fixed4 withEdge = lerp(_EdgeColor, renderTex, sobel);
				fixed4 OnlyEdge = lerp(_EdgeColor, _BackGroundColor, sobel);

				return lerp(withEdge, OnlyEdge, _RenderColorOrBackGroundColor);
			}

			ENDCG
		}
	}
}
