Shader "geekfaner/PostProcess Fog"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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
			float4 _MainTex_TexelSize;
			sampler2D _CameraDepthTexture;
			float4x4 _CurrentTransformPtoW;
			fixed4 _FogColor;
			float _FogFactor;
			float _FogStart;
			float _FogEnd;

			v2f vert(a2v i)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, i.vertex);
				o.uv.xy = i.uv;
				o.uv.zw = i.uv;

#if UNITY_UV_STARTS_AT_TOP
				if (_MainTex_TexelSize.y < 0)
					o.uv.w = 1 - o.uv.w;
#endif

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv.zw);
				float4 H = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, d * 2 - 1, 1);
				float4 worldPos = mul(_CurrentTransformPtoW, H);
				worldPos /= worldPos.w;

				float FogFactor = saturate(_FogFactor * ( _FogEnd - ( - worldPos.y)) / (_FogEnd - _FogStart));

				fixed4 renderColor = tex2D(_MainTex, i.uv.xy);
				renderColor = lerp(renderColor, _FogColor, FogFactor);
				
				return fixed4(renderColor.rgb, 1.0);
			}
			ENDCG
		}
	}
}
