using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostProcessGaussianBlur : PostProcessBase {

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

    public int scaleFactor = 1;

    public int BlurAccount = 1;

    public int BlurSize = 1;

    public void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(material != null)
        {
            int rtW = src.width / scaleFactor;
            int rtH = src.height / scaleFactor;
            RenderTexture rb0 = RenderTexture.GetTemporary(rtW, rtH, 0);
            rb0.filterMode = FilterMode.Bilinear;

            Graphics.Blit(src, rb0);
            for(int i = 0; i < BlurAccount; i++)
            {
                material.SetFloat("_BlurSize", 1 + BlurSize);
                RenderTexture rb1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                Graphics.Blit(rb0, rb1, material, 0);
                RenderTexture.ReleaseTemporary(rb0);

                rb0 = rb1;
                rb1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                Graphics.Blit(rb0, rb1, material, 1);
                RenderTexture.ReleaseTemporary(rb0);

                rb0 = rb1;
            }

            Graphics.Blit(rb0, dest);
            RenderTexture.ReleaseTemporary(rb0);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
