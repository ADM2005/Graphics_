Shader "Custom/First Lighting Shader"{
    Properties {
        _MainTex ("Albedo", 2D) = "white" {}
        _SpecularTint("Specular", Color) = (0.5,0.5,0.5)
        _Smoothness ("Smoothness", Range(0,1)) = 0.5
    }
    SubShader{
        Pass {
            Tags {
                "LightMode" = "ForwardBase"
            }
            CGPROGRAM
                #pragma vertex VertexProgram();
                #pragma fragment FragmentProgram();

                #include "UnityCG.cginc"
                #include "UnityStandardBRDF.cginc"
                #include "UnityStandardUtils.cginc"

                sampler2D _MainTex;

                float4 _MainTex_ST;
                float _Smoothness;

                float3 _SpecularTint;

                struct Interpolators {
                    float4 position : SV_POSITION;
                    float3 normal : TEXCOORD1;
                    float2 uv : TEXCOORD2;
                    float3 worldPos : TEXCOORD3;
                };
                
                struct VertexData {
                    float4 position : POSITION;
                    float3 normal : NORMAL;
                    float2 uv : TEXCOORD0;
                };

                Interpolators VertexProgram(VertexData v) { 
                    Interpolators i;
                    i.worldPos = UnityObjectToWorldDir(v.position);
                    i.position = UnityObjectToClipPos(v.position);
                    //i.normal = mul(transpose((float3x3)unity_WorldToObject), v.normal);
                    i.normal = UnityObjectToWorldNormal(v.normal);
                    i.normal = normalize(i.normal);
                    i.uv = TRANSFORM_TEX(v.uv, _MainTex);

                    return i;
                }

                float4 FragmentProgram(Interpolators i) : SV_TARGET {

                    
                    i.normal = normalize(i.normal);
                    float3 lightDir = _WorldSpaceLightPos0.xyz;
                    float3 lightCol = _LightColor0.rgb;
                    float3 albedo = tex2D(_MainTex, i.uv).rgb;
                    albedo *= 1 - max(_SpecularTint.r, max(_SpecularTint.g, _SpecularTint.b));

                    float oneMinusReflectivity;
                    albedo = EnergyConservationBetweenDiffuseAndSpecular(
                        albedo,
                        _SpecularTint.rgb,
                        oneMinusReflectivity
                    );
                    
                    float3 diffuse = albedo * lightCol * max(0, dot(lightDir, i.normal));
                    float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                    //float3 reflectDir = reflect(-lightDir, i.normal);

                    float3 halfVector = normalize(lightDir + viewDir);
                    float3 specularReflection = _Smoothness > 0 ? _SpecularTint * max(0,pow(DotClamped(halfVector, i.normal),_Smoothness * 100)) : 0;
                    return float4(specularReflection+diffuse, 1);
                }


            ENDCG
        }
    }
}