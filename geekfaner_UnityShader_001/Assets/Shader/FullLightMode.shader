// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

Shader "geekfaner/Full Light Model"
{
	Properties{
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_MainTex("MainTex", 2D) = "white"{}
		_Specular("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
		_Gloss("Gloss", Range(8.0, 256)) = 20
	}

	SubShader{
		Tags{
		}

		Pass{
			Tags{
				//If there is no Direct Light or the Direct Light is setting as Not Important, then there will be not pixel light here.
				"LightMode" = "ForwardBase"
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			//make sure the variables for lighting attenuation and so on can be used
			#pragma multi_compile_fwdbase

			#define _Lambert

			float4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Specular;
			float _Gloss;

			struct a2v {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 WorldNormal : TEXCOORD1;
				float3 WorldLight : TEXCOORD2;
				float3 WorldHalf : TEXCOORD3;
				float3 VertexColor : TEXCOORD4;
				//UV for Shadow Map
				SHADOW_COORDS(5)
			};

			v2f vert(a2v v) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.texcoord * _MainTex_ST.xy + _MainTex_ST.zw;

				o.WorldNormal = UnityObjectToWorldNormal(v.normal);
				o.WorldLight = WorldSpaceLightDir(v.vertex);
				
				float3 WorldView = WorldSpaceViewDir(v.vertex);
				o.WorldHalf = normalize(WorldView) + normalize(o.WorldLight);
				float3 WorldPos = mul(unity_ObjectToWorld, v.vertex);

				//SH Light
				float3 shLight = ShadeSH9(float4(o.WorldNormal, 1.0));
				o.VertexColor = shLight;
				
				//Vertex Light
				o.VertexColor += Shade4PointLights(unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0, unity_LightColor[0], unity_LightColor[1], unity_LightColor[2], unity_LightColor[3], unity_4LightAtten0, WorldPos, o.WorldNormal);
				
				//Transfer vertex from object to shadaw map space.
				TRANSFER_SHADOW(o);
				return o;
			}

			fixed4 frag(v2f v) : SV_Target {
				fixed3 WorldNormal = normalize(v.WorldNormal);
				fixed3 WorldLight = normalize(v.WorldLight);
				fixed3 WorldHalf = normalize(v.WorldHalf);

				fixed3 albedo = tex2D(_MainTex, v.uv).rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

#ifdef _Lambert
				float Lambert = saturate(dot(WorldNormal, WorldLight));
				//_LightColor0 is got from the color and intensity of the light
				fixed3 diffuse = _LightColor0.xyz * albedo * Lambert;
				diffuse = diffuse + v.VertexColor * albedo;
#else
				float HalfLambert = dot(WorldNormal, WorldLight) * 0.5 + 0.5;
				fixed3 diffuse = _LightColor0.xyz * albedo * HalfLambert;
				diffuse = diffuse + v.VertexColor * albedo;
#endif

				float blinn_phong = pow(saturate(dot(WorldNormal, WorldHalf)), _Gloss);
				fixed3 specular = _LightColor0.xyz * _Specular.xyz * blinn_phong;

				//The attenuation of the direct light is 1.0
				fixed atten = 1.0;

				//Sample shadow value from shadow map by UV
				//1.Make the light to cast shadow(better soft shadow).
				//2.Make the object to cast shadow(for compute shadow map by ShadowCaster pass)
				//3.Get shadow map or screen space shadow map
				fixed shadow = SHADOW_ATTENUATION(v);

				return fixed4(ambient + (diffuse + specular) * atten * shadow, 1.0);
			}

			ENDCG
		}

		Pass{
			Tags{
				//Update the pixel light source account from "Edit->ProjectSetting->Quality->Pixel Light Count", the default value is 4;
				//Light that not effect the object , Unity will not handle the light for the object by this pass.
				//The order of handle lights is base on the distance, color, intensive.
				//If light is being set as Not Important, the light will be handled by vertex light or SH.
				"LightMode" = "ForwardAdd"
			}

			//make sure this pass will blend with framebuffer, or it will cover the framebuffer
			Blend One One

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"
			//include the variable for lighting attention
			#include "AutoLight.cginc"
			#pragma multi_compile_fwdadd

			#define _Lambert
			//#define USING_ATTEN_TEXTURE

			float4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Specular;
			float _Gloss;

			struct a2v {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 WorldNormal : TEXCOORD1;
				float3 WorldPos : TEXCOORD2;
				SHADOW_COORDS(3)
			};

			v2f vert(a2v v) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
				o.WorldNormal = UnityObjectToWorldNormal(v.normal);
				o.WorldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				TRANSFER_SHADOW(v);
				return o;
			}

			fixed4 frag(v2f v) : SV_Target{
				fixed3 WorldNormal = normalize(v.WorldNormal);
				fixed3 WorldLight = normalize(UnityWorldSpaceLightDir(v.WorldPos));
				fixed3 WorldView = normalize(UnityWorldSpaceViewDir(v.WorldPos));
				fixed3 WorldHalf = normalize(WorldView + WorldLight);

				fixed3 albedo = tex2D(_MainTex, v.uv).rgb * _Color.rgb;

#ifdef _Lambert
				float Lambert = saturate(dot(WorldNormal, WorldLight));
				fixed3 diffuse = _LightColor0.xyz * albedo * Lambert;
#else
				float HalfLambert = dot(WorldNormal, WorldLight) * 0.5 + 0.5;
				fixed3 diffuse = _LightColor0.xyz * albedo * HalfLambert;
#endif

				float blinn_phong = pow(saturate(dot(WorldNormal, WorldHalf)), _Gloss);
				fixed3 specular = _LightColor0.xyz * _Specular.xyz * blinn_phong;

#ifdef USING_DIRECTIONAL_LIGHT
				fixed atten = 1.0;
#else
#ifdef USING_ATTEN_TEXTURE
				//get attention from a texture by uv as position in LightSpace
				//If cookie the light, we should use _LightTextureB0 instead of _LightTexture0
				UNITY_LIGHT_ATTENUATION(atten, v, v.WorldPos);
				//float3 lightCoord = mul(unity_WorldToLight, float4(v.WorldPos, 1.0)).xyz;
				//fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				
#else
				//Since it is not easy to get the information of light scope, spot light direction, angle, we cannot get the exact atten.
				//Especially when the object leave the light, the atten will fall from i to 0.
				float distance = length(_WorldSpaceLightPos0.xyz - v.WorldPos.xyz);
				fixed atten = 1.0 / distance;
#endif
#endif

				return fixed4((diffuse + specular) * atten, 1.0);
			}

			ENDCG
		}
	}

	Fallback "Specular"
}
