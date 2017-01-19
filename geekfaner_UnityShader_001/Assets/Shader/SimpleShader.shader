/******************************************************************************
*(C) Copyright 2017 Shuo Wang.
* All Rights Reserved
* Owner: Shuo Wang, wangshuo@geekfaner.com
******************************************************************************/
//Shader Name, Which is used for quickly found out the right shader when setup materials
Shader "geekfaner_UnityShader001/Simple Shader"
{
	//Optional
	Properties
	{
		//_Color is the name of the variable in Shader
		//Color Tint is the name of the variable in Editor
		//Color is the type of the variable			Color, Vector	<->		float4, half4, fixed4
		//											Range, Float	<->		float,  half,  fixed
		//											2D				<->		sample2D
		//											Cube			<->		samplerCube	
		//											3D				<->		sampler3D	
		//(1.0, 1.0, 1.0, 1.0) is the default value of the variable
		_Color("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
	}

	SubShader{
		//Will use default tags & render setting if not set
		Tags{
		}

		Pass{
			//Will use default tags & render setting if not set
			Tags{
			}

			//CGPROGRAM and ENDCG contains the most important part "CG Code"
			CGPROGRAM

			//define which function is used to contain VS/PS code(function name can be anything, not only vert/frag)
			#pragma vertex vert
			#pragma fragment frag

			//"UnityCG.cginc" included many useful function/struct/Macrodefine such as appdata_full and so on
			//"UnityShaderVariables.cginc" contains many useful variable such as UNITY_MARTIX_MVP, which is inclued automaticlly.
			#include "UnityCG.cginc"

			//Before use the variable, you must define it. 
			//If the variable name which is defined here is the same with the one in Properties, the type should also be the same, and then, you can change its value by Editor
			//Or it is a private variable in Shader.
			fixed4 _Color;
			//uniform is not the "uniform" in OpenGL(ES), it's just used to indicate the default value of the variable, and where to store the variable. It is optional.
			uniform float x;

			//Setup a struct which is used to contain the input variable of VS
			//Unity support semantics such as POSITION/TANGENT/NORMAL/TEXCOORD0/TEXCOORD1/TEXCOORD2/TEXCOORD3/COLOR for VS Input
			//a2v means application to vertex
			//These data are get from mesh(vertex position/normal/tangent/uv/vertex color and so on)
			//For PC, float/half/fixed will be handled as float
			//For mobile, although fixed is usually handled as float/half, they still have some precision difference.
			//You should use data type with low precision for high performance, for example, using "fixed" for color and unit vector, and make sure you will get the correct result by the real GPU.
			struct a2v {
				//POSITION contains the coordinate of the vertex in Model Space
				float4 vertex : POSITION;
				//NORMAL contains the direction of normal of the vertex in Model Space
				float3 normal : NORMAL;
				//TEXCOORD0 contains the frist set of UV coordinate of the vertex. The type of it can be float2/float4
				//There are many TEXCOORD can be used here. For Shader Model2(default SM of Unity)/Shader Model3(just like platform with OpenGL), n is 8.For SM4/SM5, n is 16.
				//Normally, there are 2 set of UV for one mesh, so just use TEXCOORD0 and TEXCOORD1.
				float2 texcoord : TEXCOORD0;
				//COLOR contains the vertex color
				fixed4 color : COLOR;
			};
			
			//Setup a struct which is used to contain the output variable of VS/input variable of PS
			struct v2f {
				//SV_POSITION contains the coordinate of the vertex in homogenous Space
				//SV_POSITION is mandatory, or GPU cannot get the coordinate in homogenous Space, and cannot get the coordinate on Screen
				float4 pos : SV_POSITION;
				//COLOR0 can be used to store anything, and most time the color of the vertex
				fixed4 color : COLOR0;
			};

			//Position & SV_POSITION and so on are the semantics of CG/HLSL
			//Most time, these semantics do not have their means, but Unity give its means for Convenient data transfer
			//But for the same semantics, it will have different means when it's by the different part.
			//For example, TEXCOORD0 means the frist set of UV coordinate of the vertex when it is in the struct a2v.
			//And it allowed us to define it when it is in the struct v2f.

			//From DX10, some system-value semantics is defined for render pipeline, such as SV_POSITION
			//It means the coordinate of the vertex in homogenous Space, and it will be used to get the position of the vertex on the screen.
			//Since it is new feature of DX10, so we can use COLOR instead of SV_Target, POSITION instean of SV_POSITION. But for PS4, we must use SV_POSITION.

			//VS is excuted by vertex
			//Input variable "v" is get from the struct a2v
			//Output variable "v2f" is get from the struct v2f
			//DX9/11 do not support tex2D since VS in DX could not get the information of LOD, so you can use tex2Dlod instead. Since tex2Dlod is the new feature of SM 3.0, so "#pragma target 3.0" is needed.
			//Since the coordinate of DX and OpenGL is not the same(they have an opposite Y axis), Unity will handle it automaticlly, except handle it when AA is opened, and multi textures are used, then, you need to handle it by yourself.
			//Shader only support few register and command, so Shader must be small, especially for PS, different restrict for different Shader and Shader Model.
			//Avoid if-else and loop. Or, the condition better be constant, and the content better be simple.
			//Never divided by 0, or the result will be undefine.
			v2f vert(appdata_full v){
				v2f o;
				//UNITY_MARTIX_MVP is the Model##View##Projection martix, which is used to get the coordinate in homogenous Space from the coordinate in Model Space
				//If no define UNITY_USE_PREMULTIPLIED_MATRICES, it is better to use "mul(UNITY_MATRIX_VP, mul(unity_ObjectToWorld, float4(pos, 1.0)))" since it's more efficient
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				//(r, g, b, a), so (0.0, 0.0, 0.0, 1.0) is black and (1.0, 1.0, 1.0, 1.0) is white
				//DX do not support fixed4(0.0), and OpenGL support fixed4(0.0) just like fixed4(0.0, 0.0, 0.0, 0.0)
				//visualization the normal direction
				/*o.color = fixed4(v.normal, 1.0);*/
				//visualization the tangent direction
				/*o.color = v.tangent;*/
				//visualization the binormal direction
				/*fixed3 binormal = cross(v.normal, v.tangent.xyz) * v.tangent.w;
				o.color = fixed4(binormal, 1.0);*/
				//visualization the frist set of UV coordinate
				o.color = fixed4(v.texcoord.xy, 0.0, 1.0);
				//visualization the second set of UV coordinate
				/*o.color = fixed4(v.texcoord1.xy, 0.0, 1.0);*/
				//visualization the fractional part of the frist set of UV coordinate
				/*o.color = frac(v.texcoord);
				if (any(saturate(v.texcoord) - v.texcoord)) {
					o.color.b = 0.5;
				}
				o.color.a = 1.0;*/
				//visualization the vertex color
				/*o.color = v.color;*/
				return o;
			}

			//PS is excuted by pixel
			//Input variable "i" is get from the struct v2f, which is acrossed the rasterization, and being interpolated.
			//Output variable variable "fixed4" will written into SV_Target, which means RT, at here it is framebuffer
			//SV_Target is the semantics of HLSL
			fixed4 frag(v2f i) : SV_Target{
				return i.color * _Color;
			}

			ENDCG
		}
	}

	FallBack "Diffuse"
}