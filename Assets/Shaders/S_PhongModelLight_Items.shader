Shader "LucasShaders/PhongModelWithTexture"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)   // Base color of the object
        _MainTex ("Base Texture", 2D) = "white" {}        // Texture map
        _SpecColor ("Specular Color", Color) = (1, 1, 1, 1)  // Specular color
        _Shininess ("Shininess", Range(0.1, 100)) = 16      // Shininess (specular exponent)
        [Toggle] _enable("Outline enable", Float) = 1
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _RimColor ("Rim Color", Color) = (0, 0.5, 0.5, 1)
        _RimPower ("Rim Power", Range(0.5, 8.0)) = 3.0
    }

    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" }
        Pass
        {
            // Tags {"LightMode"="ForwardBase"}
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;  // Object space position
                float3 normalOS : NORMAL;      // Object space normal
                float2 uv : TEXCOORD0;         // Texture UV
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION; // Homogeneous clip-space position
                float3 normalWS : TEXCOORD1;      // World space normal
                float3 viewDirWS : TEXCOORD2;     // World space view direction
                float2 uv : TEXCOORD0;            // UV for texturing
            };

            // Declare the base texture and sampler
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;   // Declare the base color (modifiable in inspector)
                float4 _SpecColor;   // Specular color (modifiable in inspector)
                float _Shininess;    // Shininess (specular exponent)
                float4 _MainTex_ST;   // <-- Add this
            CBUFFER_END

            // Vertex Shader
            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                // Transform the object space position to homogeneous clip space
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                // Transform the object space normal to world space
                OUT.normalWS = normalize(TransformObjectToWorldNormal(IN.normalOS));
                // Compute view direction in world space
                float3 worldPosWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.viewDirWS = normalize(GetCameraPositionWS() - worldPosWS);
                // Pass the UV to the fragment shader
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                return OUT;
            }

            // Fragment Shader
            half4 frag(Varyings IN) : SV_Target
            {
                // Sample the base texture
                half4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                
                // Fetch the main light in URP
                Light mainLight = GetMainLight();
                half3 lightDir = normalize(mainLight.direction);

                // Normalize the world space normal
                half3 normalWS = normalize(IN.normalWS);

                // Calculate Lambertian diffuse lighting (NdotL)
                half NdotL = saturate(dot(normalWS, lightDir));

                // Calculate ambient lighting using spherical harmonics (SH)
                half3 ambientSH = SampleSH(normalWS);

                // Combine the base color and texture with the diffuse light
                half3 diffuse = texColor.rgb * _BaseColor.rgb * NdotL;

                // Calculate the reflection direction for specular
                half3 reflectDir = reflect(-lightDir, normalWS);

                // Calculate specular contribution using Blinn-Phong model
                half3 viewDir = normalize(IN.viewDirWS);
                half specFactor = pow(saturate(dot(reflectDir, viewDir)), _Shininess);
                half3 specular = _SpecColor.rgb * specFactor;

                // Combine diffuse lighting, ambient lighting, and specular highlights
                half3 finalColor = diffuse + ambientSH * texColor.rgb * _BaseColor.rgb + specular;

                // Return the final color
                return half4(finalColor, 1.0);
            }

            ENDHLSL
        }
        Pass
        {
            Name "Outline"
            Cull Front
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 viewDirWS : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                float4 _RimColor;
                float _RimPower, _enable;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normalWS = normalize(TransformObjectToWorldNormal(IN.normalOS));
                float3 worldPosWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.viewDirWS = normalize(GetCameraPositionWS() - worldPosWS);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                half3 normalWS = normalize(IN.normalWS);
                half3 viewDirWS = normalize(IN.viewDirWS);
                half rimFactor = 1.0 - saturate(dot(viewDirWS, normalWS));
                half rimLighting = pow(rimFactor, _RimPower);
                half3 finalColor = _BaseColor.rgb + _RimColor.rgb * rimLighting;
                if (_enable == 1)
                {
                    return half4(finalColor, _BaseColor.a);
                }
                else
                {
                    discard;
                    return 0;
                }
            }

            ENDHLSL
        }
    }
}