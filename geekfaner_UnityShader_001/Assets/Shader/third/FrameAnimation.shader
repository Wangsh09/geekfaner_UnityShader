Shader "Geekfaner/FrameAnimation"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white"{}
		_TimeScale("TimeScale", float) = 1.0
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
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _TimeScale;

			v2f vert(a2v v)
			{
				v2f o;
				
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float time = floor(_Time.y * _TimeScale);
				float row = floor(time / 4) % 2;
				float column = time - row * 4;
				float2 uv = i.uv + float2(column, row);
				uv.x = uv.x / 4;
				uv.y = uv.y / 2;
				return tex2D(_MainTex, uv);
			}


			ENDCG
		}
	}
}