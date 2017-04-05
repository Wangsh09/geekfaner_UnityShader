using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostProceesBrightnessSaturationAndContrast : PostProcessBase {

    public Shader shader;
    private Material realMaterial;
    public Material material
    {
        get
        {
            realMaterial = CheckShaderAndMaterial(shader, realMaterial);
            return realMaterial;
        }
    }

    [Range(0.0f, 3.0f)]
    public float Brightness = 1.0f;

    [Range(0.0f, 3.0f)]
    public float Saturation = 1.0f;

    [Range(0.0f, 3.0f)]
    public float Contrast = 1.0f;

    // Use this for initialization
    public void OnRenderImage (RenderTexture src, RenderTexture dest) {
		if(material != null)
        {
            material.SetFloat("_Brightness", Brightness);
            material.SetFloat("_Saturation", Saturation);
            material.SetFloat("_Contrast", Contrast);
            Graphics.Blit(src, dest, material);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
	}
}
