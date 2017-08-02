using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightMove : MonoBehaviour {

    Vector3 location;

    // Update is called once per frame
    void Update()
    {

        location = transform.localPosition;
        location.y += 0.01f;
        transform.localPosition = location;

        if (transform.localPosition.y > 5)
        {
            location.y = 0.01f;
            transform.localPosition = location;
        }
    }
}
