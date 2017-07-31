Shader "Geekfaner/VertexLit"
{
	Properties
	{
		_Diffuse("Diffuse", Color) = (1.0, 1.0, 1.0, 1.0)
		_MainTex("MainTex", 2D) = "white"{}
		_Specular("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
		_Gloss("Gloss", Range(1.0, 100)) = 8
		_vertex_diffuse("vertex_diffuse", Float) = 0.0
		_fragment_diffuse("fragment_diffuse", Float) = 0.0
		_Lambert("Lambert", Float) = 0.0
		_vertex_specular("vertex_specular", Float) = 0.0
		_fragment_specular("fragment_specular", Float) = 0.0
		_Phong("Phong", Float) = 0.0
	}

	Subshader
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
#include "Lighting.cginc"

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				fixed3 color : COLOR0;
				float3 normal : COLOR1;
				float4 vertex : COLOR2;
				float2 texcoord : COLOR3;
			};

			fixed4 _Diffuse;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Specular;
			float _Gloss;
			float _vertex_diffuse;
			float _fragment_diffuse;
			float _Lambert;
			float _vertex_specular;
			float _fragment_specular;
			float _Phong;
		
			v2f vert(a2v v) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				o.color = fixed4(0.0, 0.0, 0.0, 0.0);
				fixed4 diffuse = fixed4(0.0, 0.0, 0.0, 0.0);

				if (_vertex_diffuse != 0.0)
				{
					
					if(_Lambert != 0.0)
						diffuse = _Diffuse * _LightColor0 * saturate(dot(normalize(v.normal), normalize(ObjSpaceLightDir(v.vertex))));
					else
						diffuse = _Diffuse * _LightColor0 * ((dot(normalize(v.normal), normalize(ObjSpaceLightDir(v.vertex)))) + 1) / 2;

				}
				if (_fragment_diffuse != 0.0)
				{
					o.normal = v.normal;
					o.vertex = v.vertex;
				}

				fixed4 specular = fixed4(0.0, 0.0, 0.0, 0.0);
				if (_vertex_specular != 0.0)
				{
					if (_Phong != 0.0)
					{
						float3 reflect = 2 * (dot(normalize(v.normal), normalize(ObjSpaceLightDir(v.vertex)))) * normalize(v.normal) - normalize(ObjSpaceLightDir(v.vertex));
						specular = _Specular * _LightColor0 * pow(saturate(dot(normalize(ObjSpaceViewDir(v.vertex)), normalize(reflect))), _Gloss);
					}
					else
					{
						float3 halfPhone = (normalize(ObjSpaceViewDir(v.vertex)) + normalize(ObjSpaceLightDir(v.vertex))) / 2;
						specular = _Specular * _LightColor0 * pow(saturate(dot(normalize(v.normal), normalize(halfPhone))), _Gloss);
					}
				}
				if (_fragment_specular != 0.0)
				{
					o.normal = v.normal;
					o.vertex = v.vertex;
				}


				if (_vertex_diffuse != 0.0)
					o.color += diffuse.rgb;

				if (_vertex_specular != 0.0)
					o.color += specular.rgb;

				o.texcoord = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 color;
				
				fixed4 ambient = UNITY_LIGHTMODEL_AMBIENT;

				fixed4 albedo = tex2D(_MainTex, i.texcoord);
				albedo.w = 1.0;

				fixed4 diffuse = fixed4(0.0, 0.0, 0.0, 0.0);
				fixed4 diffuseSpecular = fixed4(0.0, 0.0, 0.0, 0.0);
				fixed4 specular = fixed4(0.0, 0.0, 0.0, 0.0);

				if ((_vertex_diffuse != 0.0) && (_vertex_specular == 0.0))
				{
					diffuse = fixed4(i.color, 1.0) * albedo;
				}

				if ((_vertex_diffuse != 0.0) && (_vertex_specular != 0.0))
				{
					diffuseSpecular = fixed4(i.color, 1.0) * albedo;
				}
				if ((_vertex_diffuse == 0.0) && (_vertex_specular != 0.0))
				{
					specular = fixed4(i.color, 1.0);
				}

				if ((_vertex_diffuse == 0.0) && (_fragment_diffuse != 0.0))
				{
					if (_Lambert != 0.0)
						diffuse = _Diffuse * albedo * _LightColor0 * saturate(dot(normalize(i.normal), normalize(ObjSpaceLightDir(i.vertex))));
					else
						diffuse = _Diffuse * albedo * _LightColor0 * (dot(normalize(i.normal), normalize(ObjSpaceLightDir(i.vertex))) + 1) / 2;
				}

				if ((_vertex_specular == 0.0) && (_fragment_specular != 0.0))
				{
					if (_Phong != 0.0)
					{
						float3 reflect = 2 * (dot(normalize(i.normal), normalize(ObjSpaceLightDir(i.vertex)))) * normalize(i.normal) - normalize(ObjSpaceLightDir(i.vertex));
						specular = _Specular * _LightColor0 * pow(saturate(dot(normalize(ObjSpaceViewDir(i.vertex)), normalize(reflect))), _Gloss);
					}
					else
					{
						float3 halfPhone = (normalize(ObjSpaceViewDir(i.vertex)) + normalize(ObjSpaceLightDir(i.vertex))) / 2;
						specular = _Specular * _LightColor0 * pow(saturate(dot(normalize(i.normal), normalize(halfPhone))), _Gloss);
					}
				}

				if ((_vertex_diffuse != 0.0) && (_vertex_specular != 0.0))
					color = ambient + diffuseSpecular;
				else
					color = ambient + diffuse + specular;

				return color;
			}
			ENDCG

		}
	}
}
