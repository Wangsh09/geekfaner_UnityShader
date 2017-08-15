Shader "Geekfaner/ToneBaseShading"
{
	Properties
	{
		_EdgeSize("EdgeSize", Range(0.0, 0.1)) = 1.0
		_EdgeColor("EdgeColor", Color) = (1.0, 1.0, 1.0, 1.0)
		_aa("AA", float) = 1.0
		_specular("Specular", Range(0.0, 1.0)) = 1.0
		_diffuseColor("DiffuseColor", float) = 1.0
		_SpecularColor("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
		_RampTex("RampTex", 2D) = "white" {}
	}

	SubShader
	{
		Pass
		{
			NAME "ToneBase"

			Cull Front

			CGPROGRAM

#pragma vertex vert
#pragma fragment frag

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos :SV_POSITION;
			};

			float _EdgeSize;
			fixed4 _EdgeColor;

			v2f vert(a2v v)
			{
				v2f o;

				float4 ViewPos = mul(UNITY_MATRIX_MV, v.vertex);
				float3 ViewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
				ViewNormal.z = -0.5;
				fixed3 normal = normalize(ViewNormal);

				ViewPos = ViewPos + float4(normal * _EdgeSize, 0.0);

				o.pos = mul(UNITY_MATRIX_P, ViewPos);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				return _EdgeColor;
			}

			ENDCG

		}


		Pass
		{
			Tags
			{
				"LightMode" = "ForwardBase"
			}

			Cull Back

			CGPROGRAM

#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#include "Lighting.cginc"

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 normal : TEXCOORD0;
				float3 halfDir : TEXCOORD1;
				float3 lightDir : TEXCOORD2;
			};

			float _aa;
			float _specular;
			float _diffuseColor;
			fixed4 _SpecularColor;
			sampler2D _RampTex;

			v2f vert(a2v v)
			{
				v2f o;

				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				o.lightDir = ObjSpaceLightDir(v.vertex);
				float3 viewDir = ObjSpaceViewDir(v.vertex);
				o.halfDir = o.lightDir + viewDir;
				o.normal = v.normal;
				

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 normal = normalize(i.normal);
				fixed3 lightDir = normalize(i.lightDir);

				fixed uv = dot(normal, lightDir) * 0.5 + 0.5;
				fixed4 _diffuse = _LightColor0 * tex2D(_RampTex, float2(uv, uv));

				fixed specular = smoothstep(-_aa, _aa, (saturate(dot(normal, normalize(i.halfDir))) - _specular));
			
				return _diffuse + _SpecularColor * specular;
			}

			ENDCG

		}
		
	}
}