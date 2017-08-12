using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostProcessGosses : BasePostProcess
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

    [Range(0, 4)]
    public int iterations = 3;
    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.6f;
    [Range(1, 8)]
    public int downSample = 2;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(material != null)
        {
            material.SetFloat("_blurSpread", blurSpread);
            RenderTexture rt1 = RenderTexture.GetTemporary(Screen.width / downSample, Screen.height / downSample, 0);
            rt1.filterMode = FilterMode.Bilinear;
            RenderTexture rt2 = RenderTexture.GetTemporary(Screen.width / downSample, Screen.height / downSample, 0);
            rt2.filterMode = FilterMode.Bilinear;
            Graphics.Blit(source, rt1);
            for(int i = 0; i < iterations; i++)
            {
                Graphics.Blit(rt1, rt2, material, 0);
                RenderTexture.ReleaseTemporary(rt1);
                rt1 = RenderTexture.GetTemporary(Screen.width / downSample, Screen.height / downSample, 0);

                Graphics.Blit(rt2, rt1, material, 1);
                RenderTexture.ReleaseTemporary(rt2);
                rt2 = RenderTexture.GetTemporary(Screen.width / downSample, Screen.height / downSample, 0);
            }
            Graphics.Blit(rt1, destination);
            RenderTexture.ReleaseTemporary(rt1);
            RenderTexture.ReleaseTemporary(rt2);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}