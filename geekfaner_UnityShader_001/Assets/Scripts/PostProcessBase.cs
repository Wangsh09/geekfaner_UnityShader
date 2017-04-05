using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
public class PostProcessBase : MonoBehaviour {

    private bool CheckSupport()
    {
        if (SystemInfo.supportsImageEffects == true)
            return true;

        Debug.Log("ImageEffect do not support");
        return false;
    }

    // Use this for initialization
    void Start () {
        enabled = CheckSupport();
	}

    protected Material CheckShaderAndMaterial(Shader shader, Material material)
    {
        if (shader == null)
            return null;

        if (shader.isSupported == true && material && material.shader == shader)
            return material;

        if (shader.isSupported != true)
            return null;
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
