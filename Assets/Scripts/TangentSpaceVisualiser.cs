using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[RequireComponent(typeof(MeshFilter))]
public class TangentSpaceVisualiser : MonoBehaviour
{
    MeshFilter meshFilter;

    float scale = 0.1f;
    void OnDrawGizmos()
    {
        meshFilter = this.GetComponent<MeshFilter>();
        Mesh mesh = meshFilter.sharedMesh;

        Vector3[] vertices = mesh.vertices;
        Vector3[] normals = mesh.normals;
        Vector4[] tangents = mesh.tangents;

        for(int i=0; i < vertices.Length; i++){
            VisualizeTangentSpace(transform.TransformPoint(vertices[i]), transform.TransformDirection(normals[i]), transform.TransformDirection(tangents[i]), tangents[i].w);
        }
    }

    void VisualizeTangentSpace(Vector3 vertex, Vector3 normal, Vector3 tangent, float binormalSign){
        Debug.DrawLine(vertex, vertex+normal*scale, Color.green);
        Debug.DrawLine(vertex, vertex+tangent*scale, Color.red);
        
        Vector3 binormal = Vector3.Cross(normal, tangent) * binormalSign;
        Debug.DrawLine(vertex, vertex+binormal*scale, Color.blue);

    }
}
