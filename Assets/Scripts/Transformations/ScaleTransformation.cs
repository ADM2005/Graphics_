using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScaleTransformation : Transformation
{
    // Start is called before the first frame update
    public Vector3 scale;
    [SerializeField]
    public override Matrix4x4 Matrix {
        get {
            Matrix4x4 matrix = new Matrix4x4();
            matrix.SetRow(0, new Vector4(scale.x, 0f, 0f, 0f));
	        matrix.SetRow(1, new Vector4(0f, scale.y, 0f, 0f));
	        matrix.SetRow(2, new Vector4(0f, 0f, scale.z, 0f));
	        matrix.SetRow(3, new Vector4(0f, 0f, 0f, 1f));
            return matrix;
        }
    }
}
