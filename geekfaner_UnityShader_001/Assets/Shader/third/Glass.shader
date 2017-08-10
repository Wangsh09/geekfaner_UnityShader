Shader "Geekfaner/Glaass"
{
	Properties
	{
		_Distortion("Distortion", Range(0, 100)) =  10
	}

	SubShader
	{
		Tags
		{
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
		}

		GrabPass {"_GrabPassTex"}

		Pass
		{
			CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 scrPos : TEXCOORD0;
				float3 normal : TEXCOORD1;
			};

			float _Distortion;
			sampler2D _GrabPassTex;
			float4 _GrabPassTex_TexelSize;

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				o.scrPos = ComputeGrabScreenPos(o.pos);
				o.normal = v.normal;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float2 offset = i.normal.xy * _Distortion * _GrabPassTex_TexelSize.xy;
				i.scrPos.xy = offset + i.scrPos.xy;
				fixed3 refrCol = tex2D(_GrabPassTex, i.scrPos.xy / i.scrPos.w).rgb;

				return fixed4(refrCol, 1.0);
			}
			ENDCG
		}
	}
}