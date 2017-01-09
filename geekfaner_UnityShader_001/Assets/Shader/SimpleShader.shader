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
			struct a2v {
				//POSITION contains the coordinate of the vertex in Model Space
				float4 vertex : POSITION;
				//NORMAL contains the direction of normal of the vertex in Model Space
				float3 normal : NORMAL;
				//TEXCOORD0 contains the frist set of UV coordinate of the vertex
				float2 texcoord : TEXCOORD0;
			};
			
			//Setup a struct which is used to contain the output variable of VS/input variable of PS
			struct v2f {
				//SV_POSITION contains the coordinate of the vertex in Clip Space
				//SV_POSITION is mandatory, or GPU cannot get the coordinate in Clip Space, and cannot get the coordinate on Screen
				float4 pos : SV_POSITION;
				//COLOR0 can be used to store anything, and most time the color of the vertex
				fixed4 color : COLOR0;
			};

			//VS is excuted by vertex
			//Input variable "v" is get from the struct a2v
			//Output variable "v2f" is get from the struct v2f
			//Both Position and SV_POSITION is the semantics of CG/HLSL
			v2f vert(a2v v){
				v2f o;
				//UNITY_MARTIX_MVP is the Model##View##Projection martix, which is used to get the coordinate in Clip Space from the coordinate in Model Space
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				//(r, g, b, a), so (0.0, 0.0, 0.0, 1.0) is black and (1.0, 1.0, 1.0, 1.0) is white
				o.color = fixed4(1.0, 1.0, 1.0, 1.0);
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