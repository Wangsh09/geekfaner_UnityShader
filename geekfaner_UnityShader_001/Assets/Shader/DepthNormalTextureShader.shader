Shader "geekfaner/Depth Normal Texture Shader"
{
	Properties
	{

	}

	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			#define DEPTH

#ifdef DEPTH
			sampler2D _CameraDepthTexture;
#else
			sampler2D _CameraDepthNormalsTexture;
#endif

			struct a2v
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD;
			};

			v2f vert(a2v i)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, i.vertex);
				o.uv = i.uv;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
#ifdef DEPTH
				float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
				float linearDepth = Linear01Depth(d);
				return fixed4(linearDepth, linearDepth, linearDepth, 1.0);
#else
				float4 dn = tex2D(_CameraDepthNormalsTexture, i.uv);
				float depth;
				float3 normal;
				DecodeDepthNormal(dn, depth, normal);
				//float3 normal = DecodeViewNormalStereo(tex2D(_CameraDepthNormalsTexture, i.uv));
				return fixed4(normal * 0.5 + 0.5, 1.0);
#endif
			}

			ENDCG
		}
	}
}
