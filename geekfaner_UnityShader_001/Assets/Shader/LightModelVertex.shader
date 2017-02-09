Shader "geekfaner/Light Model Vertex"
{
	Properties
	{
		_Diffuse("Diffuse", Color) = (1.0, 1.0, 1.0, 1.0)
	}

	SubShader{
		Tags{
		}

		Pass{
			Tags{
				"LightMode" = "ForwardBase"
			}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			fixed4 _Diffuse;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				fixed4 color : COLOR;
			};

			v2f vert(appdata_full v) {
				v2f o;

				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

				fixed3 diffuse = _LightColor0.xyz * _Diffuse.xyz * saturate(dot(worldNormal, worldLight));
				o.color = fixed4(diffuse + ambient, 1.0);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				return i.color;
			}

			ENDCG
		}
	}

	FallBack "Diffuse"
}
