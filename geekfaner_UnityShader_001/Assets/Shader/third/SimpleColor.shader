Shader "Geekfaner/SimpleColor"
{
	Properties
	{
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
	}

	SubShader
	{
		Pass
		{

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			fixed4 _Color;

			float4 vert(float4 v : POSITION) : SV_POSITION
			{
				return mul(UNITY_MATRIX_MVP, v);
			}

			fixed4 frag() : SV_Target
			{
				return _Color;
			}

			ENDCG
		}
	}
}