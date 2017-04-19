using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DepthNormalCamera : MonoBehaviour {

    void Awake()
    {
        Camera camera = gameObject.GetComponent<Camera>();
        camera.depthTextureMode = DepthTextureMode.DepthNormals;
    }
	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}
}
