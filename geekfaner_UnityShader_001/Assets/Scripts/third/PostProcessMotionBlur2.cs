using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostProcessMotionBlur2 : BasePostProcess
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

    private RenderTexture rt;

    [Range(0.0f, 0.9f)]
    public float MotionBlur = 0.1f;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(material != null)
        {
            material.SetFloat("_MotionBlur", MotionBlur);
            if(rt == null)
            {
                DestroyImmediate(rt);
                rt = new RenderTexture(Screen.width, Screen.height, 0);
                rt.hideFlags = HideFlags.HideAndDontSave;
                Graphics.Blit(source, rt);
            }

            rt.MarkRestoreExpected();

            //RenderTexture rt2 = RenderTexture.GetTemporary(Screen.width, Screen.height, 0);

            //material.SetTexture("_RenderTexture", rt);

            Graphics.Blit(source, rt, material);

            //Graphics.Blit(rt2, rt);

            Graphics.Blit(rt, destination);

            //RenderTexture.ReleaseTemporary(rt2);

        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }

    private void OnDestroy()
    {
        DestroyImmediate(rt);
    }
}
