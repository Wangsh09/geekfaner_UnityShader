Shader "geekfaner/PostProcess Bloom"
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

		struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};
		ENDCG
		
		ZTest Always
		Cull Off
		ZWrite Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			float _LuminanceFactor;

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed luminance = 0.2125 * col.r + 0.7154 * col.g + 0.0721 * col.b;
				fixed luminanceVal = clamp(luminance - _LuminanceFactor, 0, 1);

				return fixed4(col.rgb * luminanceVal, col.a);
			}
			ENDCG
		}

		UsePass "geekfaner/PostProcess GaussianBlur/GAUSSIANBLURH"  

		UsePass "geekfaner/PostProcess GaussianBlur/GAUSSIANBLURV"  
		
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			sampler2D _BloomTex;

			struct v2f{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
			};

			v2f vert(appdata v){
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv.xy = v.uv;
				o.uv.zw = v.uv;

				#if UNITY_UV_STARTS_AT_TOP
				if(_MainTex_TexelSize.y < 0)
				{
					o.uv.w = 1 - o.uv.w;
				}
				#endif

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				return tex2D(_MainTex, i.uv.xy) + tex2D(_BloomTex, i.uv.zw);
			}

			ENDCG
		}
	}

	Fallback Off
}
