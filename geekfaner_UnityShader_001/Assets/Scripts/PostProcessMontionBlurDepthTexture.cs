using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostProcessMontionBlurDepthTexture : PostProcessBase {

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

    [Range(0.0f, 1.0f)]
    public float BlueSize = 0.9f;

    private Matrix4x4 previousViewProjectionMatrix;

    private void Awake()
    {
        myCamera = gameObject.GetComponent<Camera>();
        myCamera.depthTextureMode = DepthTextureMode.Depth;
        previousViewProjectionMatrix = myCamera.projectionMatrix * myCamera.worldToCameraMatrix;
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(material != null)
        {
            material.SetFloat("_BlurSize", BlueSize);
            material.SetMatrix("_PreviousViewProjectionMatrix", previousViewProjectionMatrix);
            Matrix4x4 transformFromPToW = myCamera.projectionMatrix * myCamera.worldToCameraMatrix;
            Matrix4x4 transformFromPToWinverse = transformFromPToW.inverse;
            material.SetMatrix("_CurrentViewProjectionMatrix", transformFromPToWinverse);
            previousViewProjectionMatrix = transformFromPToW;

            Graphics.Blit(src, dest, material);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
