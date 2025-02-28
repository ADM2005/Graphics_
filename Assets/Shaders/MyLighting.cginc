// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

#if !defined(MY_LIGHTING_INCLUDED)
#define MY_LIGHTING_INCLUDED

#include "UnityCG.cginc"
#include "UnityPBSLighting.cginc"
#include "AutoLight.cginc"

sampler2D _MainTex, _DetailTex;
float4 _MainTex_ST, _DetailTex_ST;

sampler2D _Normal, _NormalDetail;
float _BumpScale, _NormalDetailScale;

float _Metallic;
float _Smoothness;

struct Interpolators {
    float4 pos: SV_POSITION;
    float4 uv : TEXCOORD0;
    float3 normal : TEXCOORD1;
    float3 worldPos : TEXCOORD2;
    #if defined(BINORMAL_PER_FRAGMENT)
        float4 tangent: TEXCOORD3;
    #else
        float3 tangent: TEXCOORD3;
        float3 binormal: TEXCOORD4;
    #endif
    #if defined(VERTEXLIGHT_ON)
        float3 vertexLightColor : TEXCOORD5;
    #endif

    // #if defined(SHADOWS_SCREEN)
    //     float4 shadowCoordinates : TEXCOORD6;
    // #endif

    SHADOW_COORDS(6)
};

struct VertexData {
    float4 vertex: POSITION;
    float2 uv: TEXCOORD0;
    float3 normal : NORMAL;
    float4 tangent: TANGENT;
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

float3 CreateBinormal(float3 normal, float3 tangent, float binormalSign){
    return cross(normal, tangent.xyz) * (binormalSign * unity_WorldTransformParams.w);
}

Interpolators VertexProgram(VertexData v){
    Interpolators i;
    i.pos = UnityObjectToClipPos(v.vertex);
    i.normal = UnityObjectToWorldNormal(v.normal);
    i.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
    i.worldPos = mul(unity_ObjectToWorld, v.vertex);
    i.uv.zw = TRANSFORM_TEX(v.uv, _DetailTex);
    #if defined(BINORMAL_PER_FRAGMENT)
        i.tangent = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
    #else
        i.tangent = UnityObjectToWorldDir(v.tangent.xyz);
        i.binormal = CreateBinormal(i.normal, i.tangent, v.tangent.w);
    #endif

    // #if defined(SHADOWS_SCREEN)
    //     // Convert clip space to screen space
    //     // i.shadowCoordinates.xy = (float2(i.position.x, -i.position.y) + i.position.w) * 0.5;
    //     // i.shadowCoordinates.zw = i.position.zw;
    //     i.shadowCoordinates = ComputeScreenPos(i.position);
    // #endif

    TRANSFER_SHADOW(i);
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


    UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos);

    light.color = _LightColor0.rgb * attenuation;
    light.ndotl = DotClamped(i.normal, light.dir);
    return light;
}

void initializeFragmentNormal(inout Interpolators i){
    // i.normal.xy = tex2D(_Normal, i.uv).wy * 2 - 1;
    // i.normal.xy *= _BumpScale;

    
    // i.normal.z = sqrt(1 - saturate(dot(i.normal.xy, i.normal.xy)));
    float3 normal = UnpackScaleNormal(tex2D(_Normal, i.uv.xy), _BumpScale);
    float3 detailNormal = UnpackScaleNormal(tex2D(_NormalDetail, i.uv.zw), _NormalDetailScale);
    //i.normal = float3(normal.xy + detailNormal.xy, normal.z * detailNormal.z);
    i.normal = BlendNormals(normal, detailNormal);
    i.normal = i.normal.xzy;

    float3 tangentSpaceNormal = BlendNormals(normal, detailNormal);

    #if defined(BINORMAL_PER_FRAGMENT)
        float3 binormal = cross(i.normal, i.tangent.xyz) * (i.tangent.w * unity_WorldTransformParams.w);
    #else
        float3 binormal = i.binormal;
    #endif

    i.normal = normalize(
        tangentSpaceNormal.x * i.tangent + 
        tangentSpaceNormal.y * binormal + 
        tangentSpaceNormal.z * i.normal
    );
    //i.normal = normalize(i.normal);
}

float4 FragmentProgram(Interpolators i) : SV_TARGET {
    // #if defined(SHADOWS_SCREEN)
    //     i.shadowCoordinates.xy /= i.shadowCoordinates.w;
    // #endif
    initializeFragmentNormal(i);
    float3 albedo = tex2D(_MainTex, i.uv.xy).rgb;
    albedo *= tex2D(_DetailTex, i.uv.zw) * unity_ColorSpaceDouble;
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