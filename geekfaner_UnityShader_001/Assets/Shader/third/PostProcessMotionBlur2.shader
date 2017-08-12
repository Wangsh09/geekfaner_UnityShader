Shader "Geekfaner/PostProcessMotionBlur2"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		/*_RenderTexture("RenderTexture", 2D) = "white" {}*/
	}

	SubShader
	{
		ZWrite Off
		ZTest Always
		Cull Off

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMask RGB

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
			/*sampler2D _RenderTexture;*/
			fixed _MotionBlur;

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				/*fixed4 rt = tex2D(_RenderTexture, float2(i.uv.x, i.uv.y));*/
				fixed4 color = tex2D(_MainTex, i.uv);

				return fixed4(color.rgb, 1 - _MotionBlur);
			}

			ENDCG
		}

		Pass
		{
			Blend One Zero
			ColorMask A
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

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 color = tex2D(_MainTex, i.uv);

				return color;
			}

				ENDCG
			}
	}
}