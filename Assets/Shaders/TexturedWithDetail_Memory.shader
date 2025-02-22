Shader "Custom/TexturedWithDetail_Revised" {

    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _DetailTex ("Texture", 2D) = "gray" {}
    }

    SubShader {

        Pass {
            CGPROGRAM
            #pragma vertex VertexProgram();
            #pragma fragment FragmentProgram();


            #include "UnityCG.cginc"

            sampler2D _MainTex, _DetailTex;
            float4 _MainTex_ST, _DetailTex_ST;

            struct Interpolators {
                float4 position: SV_POSITION;
                float2 uv: TEXCOORD0;
                float2 uvDetail: TEXCOORD1;
            };

            struct VertexData {
                float4 position: POSITION;
                float2 uv : TEXCOORD0;
            };

            Interpolators VertexProgram(VertexData v) {
                Interpolators i;
                i.position = UnityObjectToClipPos(v.position);
                i.uv = TRANSFORM_TEX(v.uv, _MainTex);
                i.uvDetail = TRANSFORM_TEX(v.uv, _DetailTex);
                return i;
            }

            float4 FragmentProgram(Interpolators i) : SV_TARGET{
                float4 col = tex2D(_MainTex, i.uv);
                col *= tex2D(_DetailTex, i.uvDetail) * 2;
                return col;
            }
            ENDCG
        }
    }
}