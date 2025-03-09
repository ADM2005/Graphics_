using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Orbit : MonoBehaviour
{
    // Start is called before the first frame update
    float theta = 0f;

    [SerializeField]
    float radius =  1f;

    [SerializeField]
    float speed = 100;
    // Update is called once per frame
    void Update()
    {
        theta += speed * Time.deltaTime;
        transform.localPosition = RelativePosition();
    }

    Vector3 RelativePosition(){
        float x = radius * Mathf.Sin(theta);
        float z = radius * Mathf.Cos(theta);
        return new Vector3(x,0,z); 
    }
}
