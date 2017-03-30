Shader "geekfaner/UV Animation Shader"
{
	Properties
	{
		_FrontTex("FrontTex", 2D) = "white" {}
		_BackTex("BackTex", 2D) = "white" {}
		_FrontSpeed("FrontSpeed", Range(0, 1)) =  0.5
		_BackSpeed("BackSpeed", Range(0, 1)) = 0.5
		_Light("Light", float) = 1.0
	}

	SubShader
	{
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

			sampler2D _FrontTex;
			float4 _FrontTex_ST;
			sampler2D _BackTex;
			float4 _BackTex_ST;
			float _FrontSpeed;
			float _BackSpeed;
			float _Light;

			struct a2v {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
			};

			v2f vert(a2v i) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, i.vertex);
				o.uv.xy = TRANSFORM_TEX(i.uv, _FrontTex) + float2(_FrontSpeed, 0) * _Time.y;
				o.uv.zw = TRANSFORM_TEX(i.uv, _BackTex) + float2(_BackSpeed, 0) * _Time.y;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 frontColor = tex2D(_FrontTex, i.uv.xy);
				fixed4 backColor = tex2D(_BackTex, i.uv.zw);
				fixed4 color = frontColor * 0.5 + backColor * 0.5;
				color.rgb *= _Light;
				return color;
			}

			ENDCG
		}
	}

	Fallback "VertexLit"
}
