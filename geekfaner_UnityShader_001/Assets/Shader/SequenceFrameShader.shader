Shader "geekfaner/Sequence Frame Shader"
{
	Properties
	{
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_MainTex("MainTex", 2D) = "white" {}
		_HorizonAccount("HorizonAccount", Float) = 4
		_VerticalAccount("VerticalAccount", Float) = 4
		_Speed("Speed", Range(1, 100)) = 1
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}

		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

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

			fixed4 _Color;
			sampler2D _MainTex;
			float _HorizonAccount;
			float _VerticalAccount;
			float _Speed;

			struct a2v {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float2 texcoord : TEXCOORD0;
			};

			v2f vert(a2v i) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, i.vertex);
				float time = floor(_Time.y * _Speed);
				float row = floor(time / _HorizonAccount);
				float column = time - row * _HorizonAccount;

				half2 uv = i.uv + half2(column, -row);
				uv.x /= _HorizonAccount;
				uv.y /= _VerticalAccount;
				o.texcoord = uv;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				return tex2D(_MainTex, i.texcoord) * _Color;
			}

			ENDCG
		}
	}

	Fallback "Transparent/VertexLit"
}
