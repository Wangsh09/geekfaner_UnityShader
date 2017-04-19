Shader "geekfaner/PostProcess MotionBlur Depth"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
	}

	SubShader
	{
		ZTest Always
		Cull Off
		ZWrite Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct a2v {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			float2 _MainTex_TexelSize;
			sampler2D _CameraDepthTexture;
			float _BlurSize;
			float4x4 _PreviousViewProjectionMatrix;
			float4x4 _CurrentViewProjectionMatrix;

			v2f vert(a2v i) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, i.vertex);
				o.uv.xy = i.uv;
				o.uv.zw = i.uv;

#if UNITY_UV_STARTS_AT_TOP
				o.uv.w = 1 - o.uv.w;
#endif

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv.zw);
				float4 H = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, d * 2 - 1, 1);
				float4 D = mul(_CurrentViewProjectionMatrix, H);
				float4 worldPos = D / D.w;

				float4 currentPos = H;
				float4 previousPos = mul(_PreviousViewProjectionMatrix, worldPos);
				previousPos /= previousPos.w;

				float2 velocity = currentPos.xy - previousPos.xy;

				fixed4 renderColor = tex2D(_MainTex, i.uv.xy);
				float2 uv = i.uv.xy + velocity * _BlurSize;
				for (int it = 1; it < 3; it++)
				{
					float4 currentColor = tex2D(_MainTex, uv);
					renderColor += currentColor;
					uv += velocity * _BlurSize;
				}

				renderColor /= 3;

				return fixed4(renderColor.rgb, 1.0);
			}
			ENDCG
		}
	}
}
