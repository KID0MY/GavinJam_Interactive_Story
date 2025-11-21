Shader "Custom Shaders/MultiPassOutline"
{
    Properties
    {
        _MainColor ("Main Color", Color) = (1,1,1,1)
        _OutlineColor ("Outline Color", Color) = (0,0,0,1)
        _OutlineWidth ("Outline Width", Range(0.0, 0.1)) = 0.05
    }
    SubShader
    {
        Tags {"RenderType"="Opaque"}
        LOD 100

        // PASS 1: Renders the solid color of the object
        Pass
        {
            Tags {"LightMode"="UniversalForward"}
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            float4 _MainColor;

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                return _MainColor;
            }
            ENDHLSL
        }

        // PASS 2: Renders the outline
        Pass
        {
            Name "OutlinePass"
            Cull Front // Don't render front faces

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            float4 _OutlineColor;
            float _OutlineWidth;

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL; // Need normal for outline scaling
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                
                // Scale the vertex outward along its normal to create the outline
                float4 newPositionOS = float4(IN.positionOS.xyz + IN.normalOS * _OutlineWidth, 1.0);
                OUT.positionHCS = TransformObjectToHClip(newPositionOS.xyz);
                
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                return _OutlineColor;
            }
            ENDHLSL
        }
    }
}