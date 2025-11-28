Shader "LucasShaders/S_ProceduralSkyBox"
{
    Properties
    {
        _SkyColor("_Sky Color", Color) = (1,1,1,1)
        _HorizonColor("Horizon Color", Color) = (1,1,1,1)
        _BottomColor("Ground Color", Color) = (1,1,1,1)
        _blendSkyStrength("Blending Sky", float) = 0.1
        _blendGroundStrength("Blending Ground", float) = 0.1
        _powerStrength("Power Strength", float) = 1
    }

    SubShader
    {
        Tags
        {"RenderType"="Background" "Queue"="Background" "RenderPipeline"="UniversalPipeline" "PreviewType"="Skybox"}

        Pass
        {
            Name "SkyboxGradient"

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // Only required include
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
            };

            CBUFFER_START(UnityPerMaterial)
                half4 _SkyColor;
                half4 _HorizonColor;
                half4 _BottomColor;
                half _blendSkyStrength;
                half _blendGroundStrength;
                half _powerStrength;
            CBUFFER_END
            
            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                float3 posWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.positionWS = posWS;
                return OUT;
            }

            half4 WorldGradient(float3 dir)
            {
                half sky = Smootherstep(0, _blendSkyStrength, dir.y);
                half ground = Smootherstep(0, _blendGroundStrength, -dir.y);

                half horizon = 1 - (sky + ground);
                horizon = pow(saturate(horizon), _powerStrength);

                return  _SkyColor * sky + _HorizonColor * horizon + _BottomColor * ground;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float3 d = normalize(IN.positionWS);
                return saturate(WorldGradient(d));
            }

            ENDHLSL
        }
    }
}
