using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostProcessDepthTextureEdge : PostProcessBase {

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

    public Color EdgeColor = Color.red;
    public Color backGroundColor = Color.white;
    public int EdgeSize = 1;
    [Range(0.0f, 1.0f)]
    public float EdgeFactor = 0.5f;

    private void Awake()
    {
        gameObject.GetComponent<Camera>().depthTextureMode = DepthTextureMode.DepthNormals;
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(material != null)
        {
            material.SetColor("_EdgeColor", EdgeColor);
            material.SetColor("_backGroundColor", backGroundColor);
            material.SetInt("_EdgeSize", EdgeSize);
            material.SetFloat("_EdgeFactor", EdgeFactor);

            Graphics.Blit(src, dest, material);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
