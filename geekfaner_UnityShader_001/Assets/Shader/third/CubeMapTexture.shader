Shader "Geekfaner/CubemapTexture"
{
	Properties
	{
		_AmbientCube("AmbientCube", Cube) = "white"{}
		_Reflect("Reflect", Float) = 1.0
		_RimColor("RimColor", Color) = (1.0, 1.0, 1.0, 1.0)
	}

		SubShader
	{
		Pass
		{
			CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 uv : TEXCOORD0;
				float4 vertex : TEXCOORD1;
				float3 normal : TEXCOORD2;
			};

			samplerCUBE _AmbientCube;
			float _Reflect;
			fixed4 _RimColor;

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				
				float3 texcoord = float3(0.0, 0.0, 0.0);
				texcoord = normalize(-WorldSpaceViewDir(v.vertex) - 2 * dot(UnityObjectToWorldNormal(v.normal), -WorldSpaceViewDir(v.vertex)) * UnityObjectToWorldNormal(v.normal));
				o.uv = texcoord;

				o.vertex = v.vertex;
				o.normal = v.normal;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float fresnel = 1 - saturate( dot(normalize(ObjSpaceViewDir(i.vertex)), normalize(i.normal)));
				return lerp(texCUBE(_AmbientCube, i.uv), _RimColor, fresnel);
			}
			ENDCG

		}
	}
}