using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostProcessFogOptimize : PostProcessBase {

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
    public float FogFactor;
    public Color FogColor = Color.white;
    public float FogStart = -2;
    [Range(-2.0f, 2.0f)]
    public float FogEnd = 2;

    private void Awake()
    {
        myCamera = gameObject.GetComponent<Camera>();
        myCamera.depthTextureMode = DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(material != null)
        {
            float near = myCamera.nearClipPlane;
            float fov = myCamera.fieldOfView;
            float halfHeight = near * Mathf.Tan(fov *0.5f * Mathf.Deg2Rad);
            float halfWidth = halfHeight * myCamera.aspect;

            Vector3 foward = near * myCamera.transform.forward;
            Vector3 up = halfHeight * myCamera.transform.up;
            Vector3 right = halfWidth * myCamera.transform.right;

            Vector3 TL = foward + up - right;
            Vector3 TR = foward + up + right;
            Vector3 BL = foward - up - right;
            Vector3 BR = foward - up + right;
            TL.Normalize();
            TR.Normalize();
            BL.Normalize();
            BR.Normalize();

            Matrix4x4 TLTRBRBL = Matrix4x4.identity;
            TLTRBRBL.SetRow(0, TL);
            TLTRBRBL.SetRow(1, TR);
            TLTRBRBL.SetRow(2, BR);
            TLTRBRBL.SetRow(3, BL);
            material.SetMatrix("_TLTRBRBL", TLTRBRBL);

            material.SetFloat("_FogFactor", FogFactor);
            material.SetColor("_FogColor", FogColor);
            material.SetFloat("_FogStart", FogStart);
            material.SetFloat("_FogEnd", FogEnd);

            Graphics.Blit(src, dest, material);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
