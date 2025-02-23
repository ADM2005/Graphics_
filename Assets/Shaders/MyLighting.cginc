// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

#if !defined(MY_LIGHTING_INCLUDED)
#define MY_LIGHTING_INCLUDED

#include "UnityCG.cginc"
#include "UnityPBSLighting.cginc"
#include "AutoLight.cginc"

sampler2D _MainTex, _DetailTex;
float4 _MainTex_ST, _DetailTex_ST;

sampler2D _NormalTex;

float _Metallic;
float _Smoothness;

struct Interpolators {
    float4 position: SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 normal : TEXCOORD1;
    float3 worldPos : TEXCOORD2;

    float2 uvDetail : TEXCOORD3;

    #if defined(VERTEXLIGHT_ON)
        float3 vertexLightColor : TEXCOORD4;
    #endif
};

struct VertexData {
    float4 position: POSITION;
    float2 uv: TEXCOORD0;
    float3 normal : NORMAL;
};

void ComputeVertexLightColor(inout Interpolators i) { 
    #if defined(VERTEXLIGHT_ON)
        float3 lightPos = float3(
            unity_4LightPosX0.x, unity_4LightPosY0.x, unity_4LightPosZ0.x
        );
        // float3 lightVec = lightPos - i.worldPos;
        // float3 lightDir = normalize(lightVec);
        // float ndotl = DotClamped(i.normal, lightDir);
        // float attenuation = 1/(1 + dot(lightVec, lightVec) * unity_4LightAtten0.x);

        // i.vertexLightColor = unity_LightColor[0].rgb * ndotl * attenuation;
        i.vertexLightColor = Shade4PointLights(unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0, 
            unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,unity_4LightAtten0 ,i.worldPos, i.normal
        );
    #endif
}

Interpolators VertexProgram(VertexData v){
    Interpolators i;
    i.position = UnityObjectToClipPos(v.position);
    i.normal = UnityObjectToWorldNormal(v.normal);
    i.uv = TRANSFORM_TEX(v.uv, _MainTex);
    i.worldPos = mul(unity_ObjectToWorld, v.position);
    i.uvDetail = TRANSFORM_TEX(v.uv, _DetailTex);
    ComputeVertexLightColor(i);
    return i;
}

UnityIndirect CreateIndirectLight(Interpolators i){
    UnityIndirect indirectLight;
    indirectLight.diffuse = 0;
    indirectLight.specular = 0;


    #if defined(VERTEXLIGHT_ON)
        indirectLight.diffuse = i.vertexLightColor;
    #endif

    #if defined(FORWARD_BASE_PASS)
        indirectLight.diffuse += max(0, ShadeSH9(float4(i.normal, 1))); 
    #endif

    return indirectLight;
}

UnityLight CreateLight(Interpolators i){
    UnityLight light;
    //light.dir = _WorldSpaceLightPos0;

    #if defined(POINT) || defined(SPOT)
        light.dir = normalize(_WorldSpaceLightPos0 - i.worldPos); 
    #else
        light.dir = _WorldSpaceLightPos0;
    #endif
    UNITY_LIGHT_ATTENUATION(attenuation, 0, i.worldPos);
    light.color = _LightColor0.rgb * attenuation;
    light.ndotl = DotClamped(i.normal, light.dir);
    return light;
}

float4 FragmentProgram(Interpolators i) : SV_TARGET {
    i.normal = normalize(i.normal);
    float3 albedo = tex2D(_MainTex, i.uv).rgb;
    albedo *= tex2D(_DetailTex, i.uvDetail).rgb *2;
    float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

    float3 specularTint;
    float oneMinusReflectivity;

    albedo = DiffuseAndSpecularFromMetallic(
        albedo, _Metallic, specularTint, oneMinusReflectivity
    );
    return UNITY_BRDF_PBS(
        albedo,
        specularTint,
        oneMinusReflectivity,
        _Smoothness,
        i.normal,
        viewDir,
        CreateLight(i),
        CreateIndirectLight(i)
    );

}

#endif