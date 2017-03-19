Shader "geekfaner/Fresnel Material"
{
	Properties
	{
		_Color("_Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_ReflectColor("_ReflectColor", Color) = (1.0, 1.0, 1.0, 1.0)
		_FresnelScale("_FresnelScale", Range(0, 1)) = 0.5
		_ReflectCube("_ReflectCube", Cube) = "_skybox"{}
	}

		SubShader{
			Pass
			{
				Tags{
					"LightMode" = "ForwardBase"
				}

				CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag
				#include "Lighting.cginc"
				#include "AutoLight.cginc"

				fixed4 _Color;
				fixed4 _ReflectColor;
				fixed _FresnelScale;
				samplerCUBE _ReflectCube;

				struct a2v {
					float4 vertex : POSITION;
					float4 normal : NORMAL;
				};

				struct v2f {
					float4 pos : SV_POSITION;
					float3 WorldNormal : TEXCOORD0;
					float4 WorldPos : TEXCOORD1;
					float3 WorldReflect : TEXCOORD2;
					SHADOW_COORDS(3)
				};

				v2f vert(a2v v) {
					v2f o;
					o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
					o.WorldPos = mul(unity_ObjectToWorld, v.vertex);
					o.WorldNormal = UnityObjectToWorldNormal(v.normal);

					fixed3 WorldView = WorldSpaceViewDir(v.vertex);
					o.WorldReflect = reflect(-WorldView, o.WorldNormal);
					TRANSFER_SHADOW(o);
					return o;
				}

				fixed4 frag(v2f i) : SV_Target {
					fixed3 WorldNormal = normalize(i.WorldNormal);
					fixed3 WorldLight = normalize(UnityWorldSpaceLightDir(i.pos));
					fixed3 WorldView = normalize(UnityWorldSpaceViewDir(i.WorldPos));

					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

#ifdef _Lambert
					fixed Lambert = saturate(dot(WorldNormal, WorldLight));
					fixed3 diffuse = _LightColor0.rgb * _Color.rgb * Lambert;
#else
					fixed HalfLambert = dot(WorldNormal, WorldLight) * 0.5 + 0.5;
					fixed3 diffuse = _LightColor0.rgb * _Color.rgb * HalfLambert;
#endif

					fixed3 reflect = texCUBE(_ReflectCube, i.WorldReflect).rgb * _ReflectColor.rgb;

					float fresnel = _FresnelScale + (1 - _FresnelScale) * pow(1 - dot(WorldView, WorldNormal), 5);

					UNITY_LIGHT_ATTENUATION(atten, i, i.WorldPos);

					fixed3 color = ambient + lerp(diffuse, reflect, saturate(fresnel)) * atten;

					return fixed4(color, 1.0);
				}

				ENDCG
		}
	}

	Fallback "Diffuse"
}
