Shader "Custom/MetallicWorkflow" {
    Properties {
        _MainTex ("Albedo", 2D) = "white" {}

        [Gamma] _Metallic ("Metallic", Range(0,1)) = 0.5
        _Smoothness ("Smoothness", Range(0,1)) = 0.1

        _DetailTex ("Detail", 2D) = "gray" {}
    }
    SubShader{
    Pass {
        Tags {
            "LightMode" = "ForwardBase"
        }
        CGPROGRAM
            #pragma target 3.0

            #pragma vertex VertexProgram()
            #pragma fragment FragmentProgram()


            #include "UnityCG.cginc"
            #include "UnityPBSLighting.cginc"

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
            };

            struct VertexData {
                float4 position: POSITION;
                float2 uv: TEXCOORD0;
                float3 normal : NORMAL;
            };

            Interpolators VertexProgram(VertexData v){
                Interpolators i;
                i.position = UnityObjectToClipPos(v.position);
                i.normal = UnityObjectToWorldNormal(v.normal);
                i.uv = TRANSFORM_TEX(v.uv, _MainTex);
                i.worldPos = UnityObjectToWorldDir(v.position);
                i.uvDetail = TRANSFORM_TEX(v.uv, _DetailTex);
                return i;
            }

            float4 FragmentProgram(Interpolators i) : SV_TARGET {
                i.normal = normalize(i.normal);
                float3 albedo = tex2D(_MainTex, i.uv).rgb;
                albedo *= tex2D(_DetailTex, i.uvDetail).rgb *2;
                float3 lightDir = _WorldSpaceLightPos0; // This is the direction for directional lights
                float3 lightColor = _LightColor0;
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

                //float3 specularTint = albedo * _Metallic;
                //float oneMinusReflectivity = 1 - _Metallic;

                //albedo *= oneMinusReflectivity;
                float3 specularTint;
                float oneMinusReflectivity;

                albedo = DiffuseAndSpecularFromMetallic(
                    albedo, _Metallic, specularTint, oneMinusReflectivity
                );

                UnityLight light;
                light.color = lightColor;
                light.dir = lightDir;
                light.ndotl = DotClamped(lightDir, i.normal);

                UnityIndirect indirect;
                indirect.diffuse = 0.3;
                indirect.specular = 0.0;

                return UNITY_BRDF_PBS(
                    albedo,
                    specularTint,
                    oneMinusReflectivity,
                    _Smoothness,
                    i.normal,
                    viewDir,
                    light,
                    indirect
                );

            }
        ENDCG
    }
}
}