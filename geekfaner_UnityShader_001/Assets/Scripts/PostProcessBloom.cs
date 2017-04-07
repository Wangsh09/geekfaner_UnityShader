using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostProcessBloom :  PostProcessBase{

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
    public float luminanceFactor = 0.5f;

    public int ScaleFactor = 1;

    public int GassuianTime = 1;

    public int GassuianScope = 1;
	
    public void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(material != null)
        {
            int rtW = src.width / ScaleFactor;
            int rtH = src.height / ScaleFactor;
            RenderTexture rt0 = RenderTexture.GetTemporary(rtW, rtH, 0);
            rt0.filterMode = FilterMode.Bilinear;

            material.SetFloat("_LuminanceFactor", luminanceFactor);

            Graphics.Blit(src, rt0, material, 0);

            for(int i = 0; i < GassuianTime; i++)
            {
                material.SetFloat("_GassuianScope", GassuianScope);
                RenderTexture rt1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                Graphics.Blit(rt0, rt1, material, 1);
                RenderTexture.ReleaseTemporary(rt0);

                rt0 = rt1;
                rt1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                Graphics.Blit(rt0, rt1, material, 2);
                RenderTexture.ReleaseTemporary(rt0);

                rt0 = rt1;
            }

            material.SetTexture("_BloomTex", rt0);
            Graphics.Blit(src, dest, material, 3);
            //Graphics.Blit(rt0, dest);
            RenderTexture.ReleaseTemporary(rt0);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
