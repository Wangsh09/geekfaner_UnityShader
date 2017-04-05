Shader "geekfaner/Billboard Shader"
{
	Properties
	{
		_MainTex("_MainTex", 2D) = "white" {}
		_Color("_Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_VerticalBillboarding("_VerticalBillboarding", Range(0, 1)) = 1.0
	}

		Subshader
		{
			Tags
			{
				"Queue" = "Transparent"
				"IgnoreProjector" = "True"
				"RenderType" = "Transparent"
				"DisableBatching" = "True"
			}

			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off

			Pass
			{
				Tags
				{
					"LightMode" = "ForwardBase"
				}

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"

				sampler2D _MainTex;
				float4 _MainTex_ST;
				fixed4 _Color;
				float _VerticalBillboarding;

				struct a2v {
					float4 vertex : POSITION;
					float2 texcoord : TEXCOORD;
				};

				struct v2f {
					float4 pos : SV_POSITION;
					float2 uv : TEXCOORD0;
				};

				v2f vert(a2v i) {
					v2f o;

					float3 center = float3(0, 0, 0);
					float3 view = ObjSpaceViewDir(float4(center, 1));
					float3 normal = view - center;
					normal.y = normal.y * _VerticalBillboarding;
					normal = normalize(normal);
					float3 upDir = abs(normal.y) > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);
					float3 rightDir = normalize(cross(upDir, normal));
					upDir = normalize(cross(normal, rightDir));
					float3 centerOff = i.vertex.xyz - center;
					float3 vertex = center + rightDir * centerOff.x + upDir * centerOff.y + normal * centerOff.z;
					o.pos = mul(UNITY_MATRIX_MVP, float4(vertex, 1.0));
					o.uv = TRANSFORM_TEX(i.texcoord, _MainTex);

					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					fixed4 color = tex2D(_MainTex, i.uv);
					color.rgb *= _Color.rgb;
					return color;
				}

				ENDCG
		}
	}

	Fallback "Transparent/VertexLit"
}
