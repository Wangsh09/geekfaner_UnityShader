using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostProcessFog : PostProcessBase {

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

    private Camera myCamera;

    public Color FogColor = Color.white;
    public float FogStart = -0.5f;
    [Range(-0.5f, 0.5f)]
    public float FogEnd = 0.5f;
    [Range(0.0f, 1.0f)]
    public float FogFactor;

    private void Awake()
    {
        myCamera = gameObject.GetComponent<Camera>();
        myCamera.depthTextureMode |= DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(material != null)
        {
            Matrix4x4 transformWtoP = myCamera.projectionMatrix * myCamera.worldToCameraMatrix;
            Matrix4x4 transformPtoW = transformWtoP.inverse;
            material.SetMatrix("_CurrentTransformPtoW", transformPtoW);

            material.SetColor("_FogColor", FogColor);
            material.SetFloat("_FogStart", FogStart);
            material.SetFloat("_FogEnd", FogEnd);
            material.SetFloat("_FogFactor", FogFactor);

            Graphics.Blit(src, dest, material);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
    
}
