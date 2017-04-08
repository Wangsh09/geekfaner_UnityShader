using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Move : MonoBehaviour {

    private float positionX;

    public float speed = 0.05f;

	// Use this for initialization
	void Start () {
        positionX = gameObject.transform.position.x;
    }
	
	// Update is called once per frame
	void Update () {
		if(positionX <= 4)
        {
            positionX += speed;
        }
        else
        {
            positionX = -4.0f;
        }
        
        gameObject.transform.position = new Vector3(positionX, gameObject.transform.position.y, gameObject.transform.position.z);
    }
}
