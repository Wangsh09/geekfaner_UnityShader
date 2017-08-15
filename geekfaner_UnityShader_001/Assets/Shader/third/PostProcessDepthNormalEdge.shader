Shader "Geekfaner/DepthNormalEdge"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
	}

	SubShader
	{
		Pass
		{
			CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

			struct a2v
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 uv_depth[4] :TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			sampler2D _CameraDepthTexture;
			fixed4 _EdgeColor;
			float _sampleDistance;

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				o.uv_depth[0] = float2(v.uv.x, 1 - v.uv.y);
				o.uv_depth[1] = o.uv_depth[0] + float2(-1, 1) * _MainTex_TexelSize.xy * _sampleDistance;
				o.uv_depth[2] = o.uv_depth[0] + float2(0, 1) * _MainTex_TexelSize.xy * _sampleDistance;
				o.uv_depth[3] = o.uv_depth[0] + float2(-1, 0) * _MainTex_TexelSize.xy * _sampleDistance;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed d[4];
				d[0] = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth[1]));
				d[1] = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth[2]));
				d[2] = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth[3]));
				d[3] = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth[0]));

				fixed edge = 1 - (-1 * d[0] + 1 * d[3]) - (-1 * d[1] + 1 * d[2]);

				fixed4 color = tex2D(_MainTex, i.uv);
				
				fixed4 realColor = lerp(color, _EdgeColor, 1 - edge);

				return fixed4(realColor.rgb, 1.0);
			}
			
			ENDCG
		}
	}
}