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