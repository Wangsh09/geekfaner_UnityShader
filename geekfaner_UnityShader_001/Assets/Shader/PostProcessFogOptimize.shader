Shader "geekfaner/PostProcess Fog Optimize"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white"{}
	}

	SubShader
	{
		ZTest Always
		Cull Off
		ZWrite off

		CGINCLUDE
		#include "unityCG.cginc"

		struct a2v {
			float4 vertex : POSITION;
			float2 uv : TEXCOORD;
		};

		struct v2f {
			float4 pos : SV_POSITION;
			float4 uv : TEXCOORD0;
			float4 cameraEdge : TEXCOORD1;
		};

		sampler2D _MainTex;
		float4 _MainTex_TexelSize;
		sampler2D _CameraDepthTexture;
		float4x4 _TLTRBRBL;
		float _FogFactor;
		fixed4 _FogColor;
		float _FogStart;
		float _FogEnd;

		v2f vert(a2v i) {
			v2f o;
			o.pos = mul(UNITY_MATRIX_MVP, i.vertex);
			o.uv.xy = i.uv;
			o.uv.zw = i.uv;

#if UNITY_UV_STARTS_AT_TOP
			if (_MainTex_TexelSize.y < 0)
				o.uv.w = 1 - o.uv.w;
#endif
			int index = 0;

			if (o.uv.x < 0.5 && o.uv.y > 0.5)
				index = 0;
			if (o.uv.x > 0.5 && o.uv.y > 0.5)
				index = 1;
			if (o.uv.x < 0.5 && o.uv.y < 0.5)
				index = 2;
			if (o.uv.x > 0.5 && o.uv.y < 0.5)
				index = 3;

#if UNITY_UV_STARTS_AT_TOP
			if (_MainTex_TexelSize.y < 0)
				index = 3 - index;
#endif

			o.cameraEdge = _TLTRBRBL[index];

			return o;
		}

		fixed4 frag(v2f i) : SV_Target
		{
			float d = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv.zw));
			float4 worldPos = float4(_WorldSpaceCameraPos, 1.0) + d * i.cameraEdge;

			float FogFactor = saturate(_FogFactor * (_FogEnd - worldPos.y) / (_FogEnd - _FogStart));
			fixed4 renderColor = tex2D(_MainTex, i.uv.xy);

			return fixed4(lerp(renderColor.rgb, _FogColor.rgb, FogFactor), 1.0);
			//return fixed4(FogFactor, FogFactor, FogFactor, 1.0);
		}

		ENDCG

		Pass
		{

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			ENDCG
		}
	}
}
