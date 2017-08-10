using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BasePostProcess : MonoBehaviour {

	// Use this for initialization
	void Start () {
        if (!CheckResource())
            enabled = false;
	}
	
    private bool CheckResource()
    {
        if ((SystemInfo.supportsRenderTextures == false) || (SystemInfo.supportsImageEffects == false))
            return false;
        return true;
    }

    protected Material CheckShaderAndCreateMaterial(Shader shader, Material material)
    {
        if (shader == null)
            return null;

        if (!shader.isSupported)
            return null;

        if (material && (material.shader == shader))
            return material;
        else
        {
            material = new Material(shader);
            material.hideFlags = HideFlags.DontSave;
            if (material)
                return material;
            else
                return null;
        }

    }
}
