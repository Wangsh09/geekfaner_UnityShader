Shader "Geekfaner/MirrorTexture"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "White" {}
	}

	SubShader
	{
		Pass
		{
			CGPROGRAM
#pragma vertex vert
#pragma fragment frag

			struct a2v
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.texcoord * _MainTex_ST.xy + _MainTex_ST.zw;

				return o;
			}	

			fixed4 frag(v2f i) : SV_Target
			{
				return tex2D(_MainTex, float2(1 - i.uv.x, i.uv.y));

			}
			ENDCG
		}
	}
}