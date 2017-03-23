Shader "geekfaner/Mirror Texture Shader"
{
	Properties
	{
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_MainTex("MainTex", 2D) = "white" {}
	}

	SubShader
	{
		Pass
		{
			Tags{
				"LightMode" = "ForwardBase"
			}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;

			struct a2v {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert(a2v i) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, i.vertex);
				o.uv = i.uv;
				o.uv.x = 1 - o.uv.x;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target {
				return tex2D(_MainTex, i.uv);
			}

			ENDCG
		
		}
	}

	Fallback "Diffuse"
}
