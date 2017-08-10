Shader "Geekfaner/VertexAnimation"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_Frequncy("Frequncy", Float) = 1.0
		_nvWaveLength("nvWaveLength", Float) = 1.0
		_Magnitude("Magnitude", Float) = 1.0
		_Speed("Speed", Float) = 1.0
	}

	SubShader
	{
		Pass
		{
			Tags
			{
				"IgnoreProjector" = "True"
				"DisableBatching" = "True"
			}

			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off

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
			float _Frequncy;
			float _nvWaveLength;
			float _Magnitude;
			float _Speed;

			v2f vert(a2v v)
			{
				v2f o;
				float4 offset = float4(0.0, 0.0, 0.0, 0.0);

				offset.z = sin(_Frequncy * _Time.x + v.vertex.x * _nvWaveLength) * _Magnitude;

				o.pos = mul(UNITY_MATRIX_MVP, v.vertex + offset);
				o.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv += float2(_Time.x * _Speed, 0.0);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				return tex2D(_MainTex, i.uv);
			}

			ENDCG
		}
	}
}