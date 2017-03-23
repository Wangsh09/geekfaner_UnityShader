Shader "geekfaner/Grab Pass Shader"
{
	Properties
	{
		_AmbientCubemap("_AmbientCubemap", Cube) = "_skybox"{}
		_BumpTex("_BumpTex", 2D) = "_Bump" {}
		_GrabPassNormalFactor("_GrabPassNormalFactor", Range(0, 100)) = 10
		_GrabPassScale("_GrabPass", Range(0, 1)) = 0.5
	}

		SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"RenderType" = "Opaque"
		}

		GrabPass
		{
			"_RefractionTex"
		}

		Pass
		{
			Tags
			{
				"LightMode" = "ForwardBase"
			}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			samplerCUBE _AmbientCubemap;
			sampler2D _RefractionTex;
			float4 _RefractionTex_TexelSize;
			sampler2D _BumpTex;
			float4 _BumpTex_ST;
			float _GrabPassNormalFactor;
			float _GrabPassScale;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float2 texcoord : TEXCOORD;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float4 screenPos : TEXCOORD1;
				float4 TtoW0 : TEXCOORD2;
				float4 TtoW1 : TEXCOORD3;
				float4 TtoW2 : TEXCOORD4;
				float2 uv : TEXCOORD5;
			};

			v2f vert(a2v i) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, i.vertex);
				o.screenPos = ComputeGrabScreenPos(o.pos);

				o.uv = i.texcoord * _BumpTex_ST.xy + _BumpTex_ST.zw;

				float3 WorldPos = mul(unity_ObjectToWorld, i.vertex).xyz;
				fixed3 WorldNormal = UnityObjectToWorldNormal(i.normal);
				fixed3 WorldTangent = UnityObjectToWorldDir(i.tangent.xyz);
				fixed3 WorldBiNormal = cross(WorldNormal, WorldTangent) * i.tangent.w;

				o.TtoW0 = float4(WorldTangent.x, WorldBiNormal.x, WorldNormal.x, WorldPos.x);
				o.TtoW1 = float4(WorldTangent.y, WorldBiNormal.y, WorldNormal.y, WorldPos.y);
				o.TtoW2 = float4(WorldTangent.z, WorldBiNormal.z, WorldNormal.z, WorldPos.z);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				float3 WorldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				fixed3 WorldView = normalize(UnityWorldSpaceViewDir(WorldPos));
				fixed3 normal = normalize(float3(i.TtoW0.z, i.TtoW1.z, i.TtoW2.z));
				fixed3 TangentNormal = UnpackNormal(tex2D(_BumpTex, i.uv));

				fixed2 offset = TangentNormal.xy * _GrabPassNormalFactor * _RefractionTex_TexelSize;
				i.screenPos.xy += offset;
				fixed3 grabpass = tex2D(_RefractionTex, i.screenPos.xy/i.screenPos.w).rgb;

				float3 Normal = float3(dot(i.TtoW0.xyz, TangentNormal), dot(i.TtoW1.xyz, TangentNormal), dot(i.TtoW2.xyz, TangentNormal));
				fixed3 WorldNormal = normalize(Normal);
				WorldNormal.z = sqrt(1 - dot(WorldNormal.xy, WorldNormal.xy));

				float3 WorldReflect = reflect(-WorldView, WorldNormal);
				fixed3 reflectLight = texCUBE(_AmbientCubemap, WorldReflect).xyz;

				fixed3 color = reflectLight * (1 - _GrabPassScale) + grabpass * _GrabPassScale;

				return fixed4(color, 1.0);
			}

			ENDCG
		}
	}

	Fallback "Diffuse"
}
