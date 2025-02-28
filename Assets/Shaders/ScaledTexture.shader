// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/ScaledTexture"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _DetailTex("Detail", 2D) = "gray" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex, _DetailTex;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_DetailTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            IN.uv_MainTex = mul(transpose(unity_ObjectToWorld),  float4(IN.uv_MainTex.x, 0, IN.uv_MainTex.y, 1)).xz;
            IN.uv_DetailTex = mul(transpose(unity_ObjectToWorld),  float4(IN.uv_DetailTex.x, 0, IN.uv_DetailTex.y, 1)).xz;
            
            float4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            c *= tex2D(_DetailTex, IN.uv_DetailTex).x * unity_ColorSpaceDouble;
            o.Albedo = c.rgb;


            o.Albedo = c.rgb;

            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    //FallBack "Diffuse"
}
