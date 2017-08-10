using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class PostProcessEdge : BasePostProcess
{
    public Shader shader;
    private Material realMaterial;
    public Material material
    {
        get
        {
            realMaterial = CheckShaderAndCreateMaterial(shader, realMaterial);
            return realMaterial;
        }
    }
    
    [Range(0.0f, 1.0f)]
    public float EdgeOnly = 0.0f;
    public Color BackGounndColor = Color.white;
    public Color EdgeColor = Color.black;


    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(material != null)
        {
            material.SetFloat("_EdgeOnly", EdgeOnly);
            material.SetColor("_BackGounndColor", BackGounndColor);
            material.SetColor("_EdgeColor", EdgeColor);

            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
