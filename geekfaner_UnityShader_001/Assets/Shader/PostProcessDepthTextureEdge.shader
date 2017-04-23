Shader "geekfaner/PostProcess DepthTexture Edge"
{
	Properties
	{
		_MainTex("_MainTex", 2D) = "white" {}
	}

	SubShader
	{
		CGINCLUDE
		#include "UnityCG.cginc"

		struct a2v {
			float4 vertex : POSITION;
			float2 uv : TEXCOORD;
		};

		struct v2f {
			float4 pos : SV_POSITION;
			half2 uv[5] : TEXCOORD;
		};

		sampler2D _MainTex;
		float4 _MainTex_TexelSize;
		sampler2D _CameraDepthNormalsTexture;
		fixed4 _EdgeColor;
		fixed4 _backGroundColor;
		float _EdgeSize;
		float _EdgeFactor;
			

		v2f vert(a2v i) {
			v2f o;
			o.pos = mul(UNITY_MATRIX_MVP, i.vertex);
			o.uv[0] = i.uv;
			fixed2 uv = i.uv;

#if UNITY_UV_STARTS_AT_TOP
			if (_MainTex_TexelSize.y < 0)
				uv.y = 1 - uv.y;
#endif

			o.uv[1] = uv + fixed2(1.0, 1.0) * _MainTex_TexelSize.xy * _EdgeSize;
			o.uv[2] = uv + fixed2(-1.0, 1.0) * _MainTex_TexelSize.xy * _EdgeSize;
			o.uv[3] = uv + fixed2(-1.0, -1.0) * _MainTex_TexelSize.xy * _EdgeSize;
			o.uv[4] = uv + fixed2(1.0, -1.0) * _MainTex_TexelSize.xy * _EdgeSize;

			return o;
		}

		half CheckSame(half4 center, half4 sample) {
			half2 centerNormal = center.xy;
			float centerDepth = DecodeFloatRG(center.zw);
			half2 sampleNormal = sample.xy;
			float sampleDepth = DecodeFloatRG(sample.zw);

			// difference in normals
			// do not bother decoding normals - there's no need here
			half2 diffNormal = abs(centerNormal - sampleNormal);
			int isSameNormal = (diffNormal.x + diffNormal.y) < 0.1;
			// difference in depth
			float diffDepth = abs(centerDepth - sampleDepth);
			// scale the required threshold by the distance
			int isSameDepth = diffDepth < 0.1 * centerDepth;

			// return:
			// 1 - if normals and depth are similar enough
			// 0 - otherwise
			return isSameNormal * isSameDepth ? 1.0 : 0.0;
		}

		fixed4 frag(v2f i) : SV_Target{
			
			float4 sample1 = tex2D(_CameraDepthNormalsTexture, i.uv[1]);
			float4 sample2 = tex2D(_CameraDepthNormalsTexture, i.uv[2]);
			float4 sample3 = tex2D(_CameraDepthNormalsTexture, i.uv[3]);
			float4 sample4 = tex2D(_CameraDepthNormalsTexture, i.uv[4]);

			float edge = 1.0;
			edge *= CheckSame(sample2, sample4);
			edge *= CheckSame(sample1, sample3);

			fixed4 renderColor = tex2D(_MainTex, i.uv[0]);
			fixed4 withEdge = lerp(_EdgeColor, renderColor, edge);
			fixed4 onlyEdge = lerp(_EdgeColor, _backGroundColor, edge);

			return fixed4(lerp(withEdge, onlyEdge, _EdgeFactor).rgb, 1.0);
		}
		ENDCG

		ZTest Off
		Cull Off
		ZWrite Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}
