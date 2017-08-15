Shader "Geekfaner/Hatching"
{
	Properties
	{
		_EdgeSize("EdgeSize", Range(0.01, 0.1)) = 1.0
		_EdgeColor("EdgeColor", Color) = (1.0, 1.0, 1.0, 1.0)
		_TextureUVScale("TexUVScale", float) = 1.0
		_Hatch1("Hatch1", 2D) = "white" {}
		_Hatch2("Hatch2", 2D) = "white" {}
		_Hatch3("Hatch3", 2D) = "white" {}
		_Hatch4("Hatch4", 2D) = "white" {}
		_Hatch5("Hatch5", 2D) = "white" {}
		_Hatch6("Hatch6", 2D) = "white" {}
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
	}

	SubShader
	{
		//UsePass "Geekfaner/ToneBaseShading/ToneBase"
		UsePass "Geekfaner/ToneBaseShading/TONEBASE"

		Pass
		{
			Cull Back

			Tags
			{
				"LightMode" = "ForwardBase"
			}

			CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#include "Lighting.cginc"

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				fixed3 factor1 : TEXCOORD1;
				fixed3 factor2 : TEXCOORD2;
			};

			float _TextureUVScale;
			sampler2D _Hatch1;
			sampler2D _Hatch2;
			sampler2D _Hatch3;
			sampler2D _Hatch4;
			sampler2D _Hatch5;
			sampler2D _Hatch6;
			fixed4 _Color;

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				float diff = saturate(dot(normalize(v.normal), ObjSpaceLightDir(v.vertex)));

				diff = diff * 7;

				o.factor1 = fixed3(0.0, 0.0, 0.0);
				o.factor2 = fixed3(0.0, 0.0, 0.0);

				if (diff > 5.0)
				{
					o.factor1.x = diff - 5.0;
				}
				else if (diff > 4.0)
				{
					o.factor1.x = diff - 4.0;
					o.factor1.y = 1 - o.factor1.x;
				}
				else if (diff > 3.0)
				{
					o.factor1.y = diff - 3.0;
					o.factor1.z = 1 - o.factor1.y;
				}
				else if (diff > 2.0)
				{
					o.factor1.z = diff - 2.0;
					o.factor2.x = 1 - o.factor1.z;
				}
				else if (diff > 1.0)
				{
					o.factor2.x = diff - 1.0;
					o.factor2.y = 1 - o.factor2.x;
				}
				else
				{
					o.factor2.y = diff;
					o.factor2.z = 1 - o.factor2.y;
				}

				o.uv = v.uv * _TextureUVScale;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 color1 = tex2D(_Hatch1, i.uv).rgb * i.factor1.x;
				fixed3 color2 = tex2D(_Hatch2, i.uv).rgb * i.factor1.y;
				fixed3 color3 = tex2D(_Hatch3, i.uv).rgb * i.factor1.z;
				fixed3 color4 = tex2D(_Hatch4, i.uv).rgb * i.factor2.x;
				fixed3 color5 = tex2D(_Hatch5, i.uv).rgb * i.factor2.y;
				fixed3 color6 = tex2D(_Hatch6, i.uv).rgb * i.factor2.z;
				fixed3 whiteColor = fixed3(1.0, 1.0, 1.0) * (1 - i.factor1.x - i.factor1.y - i.factor1.z - i.factor2.x - i.factor2.y - i.factor2.z);

				//return fixed4(i.factor1, 1.0);
				return fixed4((color1 + color2 + color3 + color4 + color5 + color6 + whiteColor) * _Color, 1.0);
			}


			ENDCG
		}
	}
}