using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System;

public class LitShaderGUI : ShaderGUI
{
    MaterialEditor editor;
    MaterialProperty[] properties;
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        this.editor = materialEditor;   // Preventing duplicated code
        this.properties = properties;

        DoMain();                       // Displaying main maps
        DoSecondary();                  // Display Secondary Maps
    }

    MaterialProperty FindProperty(string name){ // Single parameter method for legibility
        return FindProperty(name, properties);
    }

    // Convenience methods for creating labels
    static GUIContent staticLabel = new GUIContent();

    static GUIContent MakeLabel(string text, string tooltip=null){
        staticLabel.text =text;
        staticLabel.tooltip = tooltip;
        return staticLabel;
    }

    static GUIContent MakeLabel(MaterialProperty property, string tooltip=null){
        staticLabel.text = property.displayName;
        staticLabel.tooltip = tooltip;
        return staticLabel;
    }

    void DoMain(){
        GUILayout.Label("Main Maps", EditorStyles.boldLabel);   // Bold label

        MaterialProperty mainTex = FindProperty("_MainTex");   // Find MainTex property
        MaterialProperty tint = FindProperty("_Tint");
        GUIContent albedoLabel = MakeLabel(mainTex, "Albedo (RGB)"); // Use display name in shader and tooltip

        editor.TexturePropertySingleLine(albedoLabel, mainTex, tint); // Display as texture with label and property
        DoMetallic();
        DoSmoothness();
        DoNormals();
        editor.TextureScaleOffsetProperty(mainTex);                 // Display Scale/Offset
    }

    void DoMetallic(){
        MaterialProperty metallic = FindProperty("_Metallic");
        EditorGUI.indentLevel += 2;
        editor.ShaderProperty(metallic, MakeLabel(metallic));
        EditorGUI.indentLevel -= 2;

    }

    void DoSmoothness(){
        EditorGUI.indentLevel += 2; // Static variable to align indentation
        MaterialProperty smoothness = FindProperty("_Smoothness");
        editor.ShaderProperty(smoothness, MakeLabel(smoothness));
        EditorGUI.indentLevel -= 2;
    }

    void DoNormals(){
        MaterialProperty normals = FindProperty("_NormalMap");
        editor.TexturePropertySingleLine(MakeLabel(normals), normals, 
        normals.textureValue ? FindProperty("_BumpScale") : null);
    }

    void DoSecondary(){
        GUILayout.Label("Secondary Maps", EditorStyles.boldLabel);

        MaterialProperty detailTex = FindProperty("_DetailTex");
        editor.TexturePropertySingleLine(MakeLabel(detailTex), detailTex);
        DoSecondaryNormals();
        editor.TextureScaleOffsetProperty(detailTex);
    }

    void DoSecondaryNormals(){
        MaterialProperty detailNormal = FindProperty("_DetailNormalMap");
        editor.TexturePropertySingleLine(MakeLabel(detailNormal), detailNormal,
        detailNormal.textureValue ? FindProperty("_DetailBumpScale") : null);
    }
}
