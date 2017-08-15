using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostProcessDepthNormal2 : BasePostProcess
{

    private void Awake()
    {
        Camera camera = gameObject.GetComponent<Camera>();
        camera.depthTextureMode = DepthTextureMode.DepthNormals | DepthTextureMode.Depth;
    }

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

    public Color EdgeColor = Color.black;
    public float sampleDistance = 1.0f;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(material != null)
        {
            material.SetColor("_EdgeColor", EdgeColor);
            material.SetFloat("_sampleDistance", sampleDistance);
            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
