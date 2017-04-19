using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Move : MonoBehaviour {


    private float positionX;
    public bool MovePositionX;
    public float MovePositionXStart = -4;
    public float MovePositionXEnd = 4;
    [Range(0.0f, 100.0f)]
    public float MovePositionXSpeed = 0.05f;

    private float RotationY;
    private Vector3 RotationYAxis;
    public bool MoveRotationY;
    public float MoveRotationYStart = 15;
    public float MoveRotationYEnd = 60;

    [Range(0.0f, 1.0f)]
    public float MoveRotationYSpeed = 0.1f;

    // Use this for initialization
    void Start () {
        positionX = gameObject.transform.position.x;

        gameObject.transform.rotation.ToAngleAxis(out RotationY, out RotationYAxis);
        //Debug.Log("RotationY : " + RotationY + "; RotationYAxis : " + RotationYAxis);
    }
	
	// Update is called once per frame
	void Update () {
        if(MovePositionX)
        {
            if (positionX <= MovePositionXEnd)
            {
                positionX += MovePositionXSpeed;
            }
            else
            {
                positionX = MovePositionXStart;
            }

            gameObject.transform.position = new Vector3(positionX, gameObject.transform.position.y, gameObject.transform.position.z);
        }

        if (MoveRotationY)
        {
            if (RotationY <= MoveRotationYEnd)
            {
                RotationY += MoveRotationYSpeed;
            }
            else
            {
                RotationY = MoveRotationYStart;
            }

            gameObject.transform.rotation = Quaternion.AngleAxis(RotationY, RotationYAxis);
        }


        
    }
}
