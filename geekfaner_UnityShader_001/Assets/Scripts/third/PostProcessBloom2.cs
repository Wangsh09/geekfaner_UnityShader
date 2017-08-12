using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostProcessBloom2 : BasePostProcess
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

    [Range(1, 4)]
    public int loop = 1;
    [Range(0.2f, 3.0f)]
    public float size = 0.6f;
    [Range(1, 8)]
    public int scaleFactor = 2;
    [Range(0.0f, 1.0f)]
    public float BloomColor = 0.8f;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(material != null)
        {
            material.SetFloat("_BlurSize", size);
            material.SetFloat("_BloomColor", BloomColor);

            RenderTexture rt1 = RenderTexture.GetTemporary(Screen.width / scaleFactor, Screen.height / scaleFactor, 0);
            rt1.filterMode = FilterMode.Bilinear;
            RenderTexture rt2 = RenderTexture.GetTemporary(Screen.width / scaleFactor, Screen.height / scaleFactor, 0);
            rt2.filterMode = FilterMode.Bilinear;

            Graphics.Blit(source, rt1, material, 0);

            for (int i = 0; i < loop; i++)
            {
                Graphics.Blit(rt1, rt2, material, 1);
                RenderTexture.ReleaseTemporary(rt1);
                rt1 = RenderTexture.GetTemporary(Screen.width / scaleFactor, Screen.height / scaleFactor, 0);

                Graphics.Blit(rt2, rt1, material, 2);
                RenderTexture.ReleaseTemporary(rt2);
                rt2 = RenderTexture.GetTemporary(Screen.width / scaleFactor, Screen.height / scaleFactor, 0);
            }

            material.SetTexture("_BloomTex", rt1);
            Graphics.Blit(source, destination, material, 3);
            RenderTexture.ReleaseTemporary(rt1);
            RenderTexture.ReleaseTemporary(rt2);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
