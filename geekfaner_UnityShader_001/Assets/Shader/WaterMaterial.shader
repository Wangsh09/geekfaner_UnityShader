Shader "geekfaner/Water Material"
{
	Properties
	{
		_Color("_Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_MainTex("_MainTex", 2D) = "white" {}
		_Frequency("_Frequency", float) = 1.0
		_Intensity("_Intensity", float) = 1.0
		_Wavelength("_Wavelength", float) = 1.0
		_Speed("_Speed", float) = 1.0
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
			"DisableBatching" = "True"
		}

		Pass
		{
			Tags
			{
				"LightMode" = "ForwardBase"
			}

			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;
			float _Frequency;
			float _Intensity;
			float _Wavelength;
			float _Speed;

			struct a2v {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert(a2v i) {
				v2f o;
				float4 offset;
				offset.yzw = float3(0.0, 0.0, 0.0);
				offset.x = sin(_Frequency * _Time.y + (/*i.vertex.x + i.vertex.y +*/ i.vertex.z )  * _Wavelength) * _Intensity;
				o.pos = mul(UNITY_MATRIX_MVP, i.vertex + offset);
				o.uv = TRANSFORM_TEX(i.uv, _MainTex) + float2(0, _Time.y * _Speed);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				return tex2D(_MainTex, i.uv) * _Color;
			}

			ENDCG
		}

		Pass
		{
			Tags
			{
				"LightMode" = "ShadowCaster"
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#include "UnityCG.cginc"

			float _Frequency;
			float _Intensity;
			float _Wavelength;

			struct v2f {
				V2F_SHADOW_CASTER;
			};

			v2f vert(appdata_base v)
			{
				v2f o;
				float4 offset;
				offset.yzw = float3(0.0, 0.0, 0.0);
				offset.x = sin(_Frequency * _Time.y + (/*v.vertex.x + v.vertex.y +*/ v.vertex.z)  * _Wavelength) * _Intensity;
				v.vertex = v.vertex + offset;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				SHADOW_CASTER_FRAGMENT(i)
			}
			
			ENDCG
		}
	}

	Fallback "Transparent/VertexLit"
}
