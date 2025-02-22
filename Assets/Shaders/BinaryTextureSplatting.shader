Shader "Custom/Binary Texture Splatting" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}

        [NoScaleOffset] _Texture1 ("Texture", 2D) = "white" {}
        [NoScaleOffset] _Texture2 ("Texture", 2D) = "black" {}
    }

    SubShader {
        Pass {
            CGPROGRAM
            #pragma vertex VertexProgram()
            #pragma fragment FragmentProgram()

            #include "UnityCG.cginc"

            sampler2D _MainTex;

            float4 _MainTex_ST;

            sampler2D _Texture1, _Texture2;

            struct Interpolators {
                float4 position: SV_POSITION;
                float2 uv: TEXCOORD0;
                float2 uvSplat: TEXCOORD1;

            };

            struct VertexData {
                float4 position : POSITION;
                float2 uv: TEXCOORD0;
            };

            Interpolators VertexProgram(VertexData v){
                Interpolators i;
                i.position =  UnityObjectToClipPos(v.position);
                i.uv = TRANSFORM_TEX(v.uv, _MainTex);
                i.uvSplat = v.uv;
                return i;
            }

            float4 FragmentProgram(Interpolators i) : SV_TARGET {
                float4 splat = tex2D(_MainTex, i.uvSplat);
                return 
                    tex2D(_Texture1, i.uv) * splat.r +
                    tex2D(_Texture2, i.uv) * (1-splat.r);
            }
            ENDCG
        }
    }
}