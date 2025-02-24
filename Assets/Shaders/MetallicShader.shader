Shader "Custom/MetallicWorkflow" {
    Properties {
        _MainTex ("Albedo", 2D) = "white" {}
        _DetailTex ("Detail", 2D) = "gray" {}

        [NoScaleOffset] [Normal] _Normal ("Normal", 2D) = "bump" {}
        _BumpScale ("Bump Scale", Float) = 1

        [NoScaleOffset] [Normal] _NormalDetail ("Normal Detail", 2D) = "bump" {}
        _NormalDetailScale ("Normal Bump Scale", Float) = 1

        [Gamma] _Metallic ("Metallic", Range(0,1)) = 0.5
        _Smoothness ("Smoothness", Range(0,1)) = 0.1
    }

    SubShader{
    Pass {
        Tags {
            "LightMode" = "ForwardBase"
        }
        CGPROGRAM
            #pragma target 3.0

            #pragma multi_compile _ VERTEXLIGHT_ON

            #pragma vertex VertexProgram()
            #pragma fragment FragmentProgram()

            #define FORWARD_BASE_PASS

            #include "MyLighting.cginc"
        ENDCG
    }

    Pass {
        Tags {
            "LightMode" = "ForwardAdd"
        }

        Blend One One
        ZWrite Off

        CGPROGRAM
            #pragma target 3.0

            //#pragma multi_compile DIRECTIONAL POINT SPOT DIRECTIONAL_COOKIE POINT_COOKIE
            #pragma multi_compile_fwdadd

            #pragma vertex VertexProgram()
            #pragma fragment FragmentProgram()

            
            #include "MyLighting.cginc"
        ENDCG
    }
}
}