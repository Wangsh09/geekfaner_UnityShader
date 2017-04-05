using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostProcessEdgeDetect : PostProcessBase {

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

    [Range(0.0f, 1.0f)]
    public float RenderColorOrBackGroundColor = 0.5f;

    public Color EdgeColor = Color.black;

    public Color BackgroundColor = Color.white;

    // Use this for initialization
    public void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(material != null)
        {
            material.SetFloat("_RenderColorOrBackGroundColor", RenderColorOrBackGroundColor);
            material.SetColor("_EdgeColor", EdgeColor);
            material.SetColor("_BackGroundColor", BackgroundColor);

            Graphics.Blit(src, dest, material);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
