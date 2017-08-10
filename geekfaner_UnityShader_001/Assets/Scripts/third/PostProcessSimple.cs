using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class PostProcessSimple : BasePostProcess
{
    public Shader shader;
    private Material realmaterial;
    public Material material
    {
        get
        {
            realmaterial = CheckShaderAndCreateMaterial(shader, realmaterial);
            return realmaterial;
        }
    }

    [Range(0.0f, 3.0f)]
    public float Brightness = 1.0f;
    [Range(0.0f, 3.0f)]
    public float Saturation = 1.0f;
    [Range(0.0f, 3.0f)]
    public float Contrast = 1.0f;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            material.SetFloat("_Brightness", Brightness);
            material.SetFloat("_Saturation", Saturation);
            material.SetFloat("_Contrast", Contrast);

            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
