using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostProcessMotionBlur : PostProcessBase {

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
    public float BlurScale = 0.9f;

    private RenderTexture rt;

    private void OnDisable()
    {
        DestroyImmediate(rt);
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            if(rt == null || rt.width != src.width || rt.height != src.height)
            {
                DestroyImmediate(rt);
                rt = new RenderTexture(src.width, src.height, 0);
                rt.hideFlags = HideFlags.HideAndDontSave;
            }

            rt.MarkRestoreExpected();

            material.SetFloat("_BlurScale", BlurScale);

            Graphics.Blit(src, rt, material);
            Graphics.Blit(rt, dest);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
