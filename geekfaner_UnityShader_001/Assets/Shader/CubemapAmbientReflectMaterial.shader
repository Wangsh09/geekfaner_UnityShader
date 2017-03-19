Shader "geekfaner/Cubemap Ambient Reflect Material"
{
	Properties
	{
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_CubemapAmbientScale("CubemapAmbientScale", Color) = (1.0, 1.0, 1.0, 1.0)
		_CubemapAmbientEffect("CubemapAmbientEffect", Range(0, 1)) = 1.0
		_CubemapAmbient("CubemapAmbient", Cube) = "_Skybox" {}
	}

	SubShader
	{
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
			fixed4 _CubemapAmbientScale;
			fixed _CubemapAmbientEffect;
			samplerCUBE _CubemapAmbient;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float3 WorldNormal : TEXCOORD0;
				float3 WorldReflect : TEXCOORD1;
				float3 WorldPos : TEXCOORD2;
				SHADOW_COORDS(3)
			};

			v2f vert(a2v i) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, i.vertex);
				o.WorldNormal = UnityObjectToWorldNormal(i.normal);

				float3 WorldView = WorldSpaceViewDir(i.vertex);
				//Reflect can be computed by PS, more compute and better effect.
				o.WorldReflect = reflect(-WorldView, o.WorldNormal);
				o.WorldPos = mul(unity_ObjectToWorld, i.vertex);
				TRANSFER_SHADOW(o);
				return o;
			}

			fixed4 frag(v2f v) : SV_Target{
				fixed3 WorldNormal = normalize(v.WorldNormal);
				fixed3 WorldLight = normalize(UnityWorldSpaceLightDir(v.WorldPos));

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//_CubemapAmbient is got from Camera.RenderToCubemap at this position
				//Cube do not need uv, but only direction(do not need normalize) 
				fixed3 ambientCube = texCUBE(_CubemapAmbient, v.WorldReflect).xyz * _CubemapAmbientScale.xyz;

#ifdef _Lambert
				fixed Lambert = saturate(dot(WorldNormal, WorldLight));
				fixed3 diffuse = _LightColor0.xyz * _Color.xyz * Lambert;
#else
				fixed HalfLambert = dot(WorldNormal, WorldLight) * 0.5 + 0.5;
				fixed3 diffuse = _LightColor0.xyz * _Color.xyz * HalfLambert;
#endif

				UNITY_LIGHT_ATTENUATION(atten, v, v.WorldPos);

				fixed3 color = ambient + lerp(diffuse, ambientCube, _CubemapAmbientEffect) * atten;

				return fixed4(color, 1.0);

			}

			ENDCG
		}
	}

	Fallback "Diffuse"
}
