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
        if (SystemInfo.supportsImageEffects == false)
        {
            Debug.Log("SystemInfo not supportsImageEffects");
            return false;
        }
        return true;
    }

    protected Material CheckShaderAndCreateMaterial(Shader shader, Material material)
    {
        if (shader == null)
            return null;

        if (!shader.isSupported)
        {
            Debug.Log("shader is not Supported!");
            return null;
        }

        if (material && (material.shader == shader))
        {
            //Debug.Log("Material ready!");
            return material;
        }
        else
        {
            material = new Material(shader);
            material.hideFlags = HideFlags.DontSave;
            if (material)
            {
                //Debug.Log("Material ready!");
                return material;
            }
            else
            {
                Debug.Log("Material not ready!");
                return null;
            }
        }

    }
}
