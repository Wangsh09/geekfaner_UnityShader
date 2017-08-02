Shader "Geekfaner/VertexLit"
{
	Properties
	{
		_Diffuse("Diffuse", Color) = (1.0, 1.0, 1.0, 1.0)
		_MainTex("MainTex", 2D) = "white"{}
		_BumpTex("BumpTex", 2D) = "Bump" {}
		_BumpScale("BumpScale", Range(-1.0, 1.0)) = 1.0
		_RampTex("RampTex", 2D) = "Ramp"{}
		_Specular("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
		_Gloss("Gloss", Range(1.0, 100)) = 8
		_vertex_diffuse("vertex_diffuse", Float) = 0.0
		_fragment_diffuse("fragment_diffuse", Float) = 0.0
		_Lambert("Lambert", Float) = 0.0
		_vertex_specular("vertex_specular", Float) = 0.0
		_fragment_specular("fragment_specular", Float) = 0.0
		_Phong("Phong", Float) = 0.0
		_object_normal("object_normal", Float) = 1.0
		_ramp_tex("ramp_tex", Float) = 0.0
		_alpha_test("Alpha_test", Float) = 1.0
		_alpha_threshold("Alpha_Threshold", Range(0.0, 1.0)) = 1.0
		_alpha_blend("Alpha_blend", Float) = 0.0
		_cull("Cull", Float) = 1.0
		_vertex_lit("Vertex_lit", Float) = 0.0
		_fragment_lit("Fragment_lit", Float) = 0.0
		_atten_texture("Atten_Texture", Float) = 0.0
	}

	Subshader
	{
		Tags
		{
			"Queue" = "Transparent"	//"AlphaTest"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"	//"TransparentCutOff"
		}

		//当开启alpha blend的时候，需要先绘制一个Z pass，以防同一个物体的不同部位发生穿插
		Pass
		{
			ZWrite On
			ColorMask 0

			/*
			CGPROGRAM
#pragma skip_variants FOG_EXP FOG_EXP2 FOG_LINEAR
#pragma vertex vert
#pragma fragment frag

			float4 vert(float4 v : POSITION) : SV_POSITION
			{
				return mul(UNITY_MATRIX_MVP, v);
			}

			fixed4 frag() : SV_Target
			{
				return fixed4(0.0, 0.0, 0.0, 1.0);
			}
			ENDCG
			*/
		}

			
		//双面渲染的透明效果，为了满足先绘制背面再绘制前面的渲染顺序，所以用了两个pass
		Pass
		{
			Tags
			{
				"LightMode" = "ForwardBase"
			}

			Cull Front
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM

#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#include "Lighting.cginc"


			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float2 uv : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				fixed3 color : COLOR0;
				float3 normal : COLOR1;
				float4 vertex : COLOR2;
				float2 texcoord : COLOR3;
				float4 tangent : COLOR4;
			};

			fixed4 _Diffuse;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpTex;
			float _BumpScale;
			sampler2D _RampTex;
			fixed4 _Specular;
			float _Gloss;
			float _vertex_diffuse;
			float _fragment_diffuse;
			float _Lambert;
			float _vertex_specular;
			float _fragment_specular;
			float _Phong;
			float _object_normal;
			float _ramp_tex;
			float _alpha_test;
			float _alpha_threshold;
			float _alpha_blend;
			float _cull;

			v2f vert(a2v v) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				o.color = fixed4(0.0, 0.0, 0.0, 0.0);
				fixed4 diffuse = fixed4(0.0, 0.0, 0.0, 0.0);

				if (_vertex_diffuse != 0.0)
				{

					if (_Lambert != 0.0)
						diffuse = _Diffuse * _LightColor0 * saturate(dot(normalize(v.normal), normalize(ObjSpaceLightDir(v.vertex))));
					else
						diffuse = _Diffuse * _LightColor0 * ((dot(normalize(v.normal), normalize(ObjSpaceLightDir(v.vertex)))) + 1) / 2;

				}
				if (_fragment_diffuse != 0.0)
				{
					o.normal = v.normal;
					o.vertex = v.vertex;
					o.tangent = v.tangent;
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
					o.tangent = v.tangent;
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
				if (_alpha_test && (albedo.a < _alpha_threshold))
					discard;

				fixed4 PackageNormal = tex2D(_BumpTex, i.texcoord);
				fixed3 TangentNormal = UnpackNormal(PackageNormal);
				TangentNormal.xy = TangentNormal.xy * _BumpScale;
				TangentNormal.z = 1 - sqrt(dot(TangentNormal.xy, TangentNormal.xy));

				fixed3 tangent = normalize(i.tangent.xyz);
				fixed3 normal = normalize(i.normal);
				fixed3 bitangent = normalize(cross(tangent, normal)) * i.tangent.w;
				float3x3 bToO = float3x3(tangent.x, bitangent.x, normal.x, tangent.y, bitangent.y, normal.y, tangent.z, bitangent.z, normal.z);

				fixed3 ObjectNormal = normalize(mul(bToO, TangentNormal));

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
					fixed4 ramp = fixed4(1.0, 1.0, 1.0, 1.0);

					if (_object_normal)
					{
						if (_Lambert != 0.0)
						{
							fixed Lambert = saturate(dot(ObjectNormal, normalize(ObjSpaceLightDir(i.vertex))));

							if (_ramp_tex)
							{
								ramp = tex2D(_RampTex, float2(Lambert, Lambert));
								diffuse = _Diffuse * _LightColor0 * ramp;
							}
							else
							{
								diffuse = _Diffuse * albedo * _LightColor0 * Lambert;
							}
						}
						else
						{
							fixed HalfLambert = (dot(ObjectNormal, normalize(ObjSpaceLightDir(i.vertex))) + 1) / 2;

							if (_ramp_tex)
							{
								ramp = tex2D(_RampTex, float2(HalfLambert, HalfLambert));
								diffuse = _Diffuse * _LightColor0 * ramp;
							}
							else
							{
								diffuse = _Diffuse * albedo * _LightColor0 * HalfLambert;
							}
						}
					}
					else
					{
						if (_Lambert != 0.0)
						{
							fixed Lambert = saturate(dot(normalize(i.normal), normalize(ObjSpaceLightDir(i.vertex))));

							if (_ramp_tex)
							{
								ramp = tex2D(_RampTex, float2(Lambert, Lambert));
								diffuse = _Diffuse * _LightColor0 * ramp;
							}
							else
							{
								diffuse = _Diffuse * albedo * _LightColor0 * Lambert;
							}
						}
						else
						{
							fixed HalfLambert = (dot(normalize(i.normal), normalize(ObjSpaceLightDir(i.vertex))) + 1) / 2;

							if (_ramp_tex)
							{
								ramp = tex2D(_RampTex, float2(HalfLambert, HalfLambert));
								diffuse = _Diffuse * _LightColor0 * ramp;
							}
							else
							{
								diffuse = _Diffuse * albedo * _LightColor0 * HalfLambert;
							}


						}
					}

				}

				if ((_vertex_specular == 0.0) && (_fragment_specular != 0.0))
				{
					if (_object_normal)
					{
						if (_Phong != 0.0)
						{
							float3 reflect = 2 * (dot(ObjectNormal, normalize(ObjSpaceLightDir(i.vertex)))) * ObjectNormal - normalize(ObjSpaceLightDir(i.vertex));
							specular = _Specular * _LightColor0 * pow(saturate(dot(normalize(ObjSpaceViewDir(i.vertex)), normalize(reflect))), _Gloss);
						}
						else
						{
							float3 halfPhone = (normalize(ObjSpaceViewDir(i.vertex)) + normalize(ObjSpaceLightDir(i.vertex))) / 2;
							specular = _Specular * _LightColor0 * pow(saturate(dot(ObjectNormal, normalize(halfPhone))), _Gloss);
						}
					}
					else
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
				}

				if ((_vertex_diffuse != 0.0) && (_vertex_specular != 0.0))
					color = ambient + diffuseSpecular;
				else
					color = ambient + diffuse + specular;

				if (!_cull)
				{
					if (_alpha_blend)
					{
						return fixed4(color.rgb, albedo.a);
					}
					else
					{
						return fixed4(color.rgb, 1.0);
					}
				}
				else
				{
					return fixed4(0.26, 0.38, 0.56, 1.0);
				}
				
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
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#include "Lighting.cginc"

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float2 uv : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				fixed3 color : COLOR0;
				float3 normal : COLOR1;
				float4 vertex : COLOR2;
				float2 texcoord : COLOR3;
				float4 tangent : COLOR4;
			};

			fixed4 _Diffuse;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpTex;
			float _BumpScale;
			sampler2D _RampTex;
			fixed4 _Specular;
			float _Gloss;
			float _vertex_diffuse;
			float _fragment_diffuse;
			float _Lambert;
			float _vertex_specular;
			float _fragment_specular;
			float _Phong;
			float _object_normal;
			float _ramp_tex;
			float _alpha_test;
			float _alpha_threshold;
			float _alpha_blend;
			float _vertex_lit;
		
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
					o.tangent = v.tangent;
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
					o.tangent = v.tangent;
				}

				/*
				fixed4 vertex_diffuse = fixed4(0.0, 0.0, 0.0, 0.0);

				if (_vertex_lit)
				{
					fixed3 vertex_lightDir[4];
					vertex_lightDir[0] = normalize(mul(unity_WorldToObject, float4(unity_4LightPosX0.x, unity_4LightPosY0.x, unity_4LightPosZ0.x, 1.0)) - v.vertex);
					if (_Lambert != 0.0)
						vertex_diffuse = _Diffuse * unity_LightColor[0] * saturate(dot(normalize(v.normal), vertex_lightDir[0]));
					else
						vertex_diffuse = _Diffuse * unity_LightColor[0] * ((dot(normalize(v.normal), vertex_lightDir[0])) + 1) / 2;
					
					o.color += vertex_diffuse * unity_4LightAtten0.x;
				}
				*/
				//Vertex Light
				o.color += Shade4PointLights(unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0, unity_LightColor[0], unity_LightColor[1], unity_LightColor[2], unity_LightColor[3], unity_4LightAtten0, mul(unity_ObjectToWorld, v.vertex), UnityObjectToWorldNormal(v.normal));



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

				fixed atten = 1.0;
				
				fixed4 ambient = UNITY_LIGHTMODEL_AMBIENT;

				fixed4 albedo = tex2D(_MainTex, i.texcoord);
				if (_alpha_test && (albedo.a < _alpha_threshold))
					discard;

				fixed4 PackageNormal = tex2D(_BumpTex, i.texcoord);
				fixed3 TangentNormal = UnpackNormal(PackageNormal);
				TangentNormal.xy = TangentNormal.xy * _BumpScale;
				TangentNormal.z = 1 - sqrt(dot(TangentNormal.xy, TangentNormal.xy));

				fixed3 tangent = normalize(i.tangent.xyz);
				fixed3 normal = normalize(i.normal);
				fixed3 bitangent = normalize(cross(tangent, normal)) * i.tangent.w;
				float3x3 bToO = float3x3(tangent.x, bitangent.x, normal.x, tangent.y, bitangent.y, normal.y, tangent.z, bitangent.z, normal.z);

				fixed3 ObjectNormal = normalize(mul(bToO, TangentNormal));

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
					fixed4 ramp = fixed4(1.0, 1.0, 1.0, 1.0);

					if (_object_normal)
					{
						if (_Lambert != 0.0)
						{
							fixed Lambert = saturate(dot(ObjectNormal, normalize(ObjSpaceLightDir(i.vertex))));
							
							if (_ramp_tex)
							{
								ramp = tex2D(_RampTex, float2(Lambert, Lambert));
								diffuse = _Diffuse * _LightColor0 * ramp;
							}
							else
							{
								diffuse = _Diffuse * albedo * _LightColor0 * Lambert;
							}
						}
						else
						{
							fixed HalfLambert = (dot(ObjectNormal, normalize(ObjSpaceLightDir(i.vertex))) + 1) / 2;
							
							if (_ramp_tex)
							{
								ramp = tex2D(_RampTex, float2(HalfLambert, HalfLambert));
								diffuse = _Diffuse * _LightColor0 * ramp;
							}
							else
							{
								diffuse = _Diffuse * albedo * _LightColor0 * HalfLambert;
							}
						}
					}
					else
					{
						if (_Lambert != 0.0)
						{
							fixed Lambert = saturate(dot(normalize(i.normal), normalize(ObjSpaceLightDir(i.vertex))));

							if (_ramp_tex)
							{
								ramp = tex2D(_RampTex, float2(Lambert, Lambert));
								diffuse = _Diffuse * _LightColor0 * ramp;
							}
							else
							{
								diffuse = _Diffuse * albedo * _LightColor0 * Lambert;
							}
						}
						else
						{
							fixed HalfLambert = (dot(normalize(i.normal), normalize(ObjSpaceLightDir(i.vertex))) + 1) / 2;

							if (_ramp_tex)
							{
								ramp = tex2D(_RampTex, float2(HalfLambert, HalfLambert));
								diffuse = _Diffuse * _LightColor0 * ramp;
							}
							else
							{
								diffuse = _Diffuse * albedo * _LightColor0 * HalfLambert;
							}

							
						}
					}

					diffuse = diffuse * atten;
					
				}

				if ((_vertex_specular == 0.0) && (_fragment_specular != 0.0))
				{
					if (_object_normal)
					{
						if (_Phong != 0.0)
						{
							float3 reflect = 2 * (dot(ObjectNormal, normalize(ObjSpaceLightDir(i.vertex)))) * ObjectNormal - normalize(ObjSpaceLightDir(i.vertex));
							specular = _Specular * _LightColor0 * pow(saturate(dot(normalize(ObjSpaceViewDir(i.vertex)), normalize(reflect))), _Gloss);
						}
						else
						{
							float3 halfPhone = (normalize(ObjSpaceViewDir(i.vertex)) + normalize(ObjSpaceLightDir(i.vertex))) / 2;
							specular = _Specular * _LightColor0 * pow(saturate(dot(ObjectNormal, normalize(halfPhone))), _Gloss);
						}
					}
					else
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

					specular = specular * atten;
				}

				if ((_vertex_diffuse != 0.0) && (_vertex_specular != 0.0))
					color = ambient + diffuseSpecular;
				else
					color = ambient + diffuse + specular;
				
				if (_alpha_blend)
				{
					return fixed4(color.rgb, albedo.a);
				}
				else
				{
					return fixed4(color.rgb, 1.0);
				}
			}
			ENDCG

		}

		Pass
		{
			Tags
			{
				"LightMode" = "ForwardAdd"
			}

			Blend One One

			CGPROGRAM

#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"
#pragma multi_compile_fwdadd

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float2 uv : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float3 normal : COLOR1;
				float4 vertex : COLOR2;
				float2 texcoord : COLOR3;
				float4 tangent : COLOR4;
			};

			fixed4 _Diffuse;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpTex;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;
			float _Lambert;
			float _Phong;
			float _object_normal;
			float _vertex_lit;
			float _fragment_lit;
			float _atten_texture;

			v2f vert(a2v v) {
				v2f o;

				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				o.normal = v.normal;
				o.vertex = v.vertex;
				o.tangent = v.tangent;

				o.texcoord = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 color;

				fixed4 albedo = tex2D(_MainTex, i.texcoord);

				fixed4 PackageNormal = tex2D(_BumpTex, i.texcoord);
				fixed3 TangentNormal = UnpackNormal(PackageNormal);
				TangentNormal.xy = TangentNormal.xy * _BumpScale;
				TangentNormal.z = 1 - sqrt(dot(TangentNormal.xy, TangentNormal.xy));

				fixed3 tangent = normalize(i.tangent.xyz);
				fixed3 normal = normalize(i.normal);
				fixed3 bitangent = normalize(cross(tangent, normal)) * i.tangent.w;
				float3x3 bToO = float3x3(tangent.x, bitangent.x, normal.x, tangent.y, bitangent.y, normal.y, tangent.z, bitangent.z, normal.z);

				fixed3 ObjectNormal = normalize(mul(bToO, TangentNormal));

				fixed4 diffuse = fixed4(0.0, 0.0, 0.0, 0.0);

#ifdef UNITY_DIRECTIONAL_LIGHT
				fixed atten = 1.0;
#else
				float3 lightcoord = mul(unity_WorldToLight, mul(unity_ObjectToWorld, i.vertex)).xyz;
				fixed atten = tex2D(_LightTexture0, dot(lightcoord, lightcoord).rr).UNITY_ATTEN_CHANNEL;
#endif

				if (!_atten_texture)
				{
					float distance = length(_WorldSpaceLightPos0.xyz - mul(unity_ObjectToWorld, i.vertex).xyz);
					fixed atten = 1 / distance;
				}
				if (_object_normal)
				{
					if (_Lambert != 0.0)
					{
						fixed Lambert = saturate(dot(ObjectNormal, normalize(ObjSpaceLightDir(i.vertex))));

						diffuse = _Diffuse * albedo * _LightColor0 * Lambert;
					}
					else
					{
						fixed HalfLambert = (dot(ObjectNormal, normalize(ObjSpaceLightDir(i.vertex))) + 1) / 2;

						diffuse = _Diffuse * albedo * _LightColor0 * HalfLambert;
					}
				}
				else
				{
					if (_Lambert != 0.0)
					{
						fixed Lambert = saturate(dot(normalize(i.normal), normalize(ObjSpaceLightDir(i.vertex))));

						diffuse = _Diffuse * albedo * _LightColor0 * Lambert;
					}
					else
					{
						fixed HalfLambert = (dot(normalize(i.normal), normalize(ObjSpaceLightDir(i.vertex))) + 1) / 2;

						diffuse = _Diffuse * albedo * _LightColor0 * HalfLambert;
					}
				}

				if (_fragment_lit)
					return diffuse * atten;
				else
					return fixed4(0.0, 0.0, 0.0, 1.0);
			}
			ENDCG

		}
	}
}
