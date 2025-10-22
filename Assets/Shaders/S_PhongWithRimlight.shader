Shader "LucasShaders/PhongWithRim"
{
    Properties
    {
        _BaseColor   ("Base Color", Color) = (1,1,1,1)
        _MainTex     ("Base Texture", 2D) = "white" {}
        _SpecColor   ("Specular Color", Color) = (1,1,1,1)
        _Shininess   ("Shininess", Range(0.1, 100)) = 16

        // Rim/Fresnel options
        _RimColor    ("Rim Color", Color) = (1,1,1,1)
        _RimPower    ("Rim Power", Range(0.5,8)) = 3
        _RimStrength ("Rim Strength", Range(0,1)) = 0.5
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalRenderPipeline" "RenderType"="Opaque" }

        Pass
        {
            Name "PhongWithRim"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float2 uv         : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv          : TEXCOORD0;
                float3 normalWS    : TEXCOORD1;
                float3 viewDirWS   : TEXCOORD2;
                float3 worldPosWS  : TEXCOORD3;
            };

            // Textures
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                float4 _SpecColor;
                float  _Shininess;
                float4 _MainTex_ST;
                float4 _RimColor;
                float  _RimPower;
                float  _RimStrength;
            CBUFFER_END

            // ---------- Vertex ----------
            Varyings vert (Attributes IN)
            {
                Varyings OUT;

                float3 worldPos = TransformObjectToWorld(IN.positionOS.xyz);
                float3 normalWS = normalize(TransformObjectToWorldNormal(IN.normalOS));

                OUT.positionHCS = TransformWorldToHClip(worldPos);
                OUT.normalWS    = normalWS;
                OUT.viewDirWS   = normalize(GetCameraPositionWS() - worldPos);
                OUT.worldPosWS  = worldPos;
                OUT.uv          = TRANSFORM_TEX(IN.uv, _MainTex);
                return OUT;
            }

            // ---------- Fragment ----------
            half4 frag (Varyings IN) : SV_Target
            {
                // Sample base texture
                half4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                half3 baseColor = texColor.rgb * _BaseColor.rgb;

                // Lighting
                Light mainLight = GetMainLight();
                half3 lightDir = normalize(mainLight.direction);
                half3 normalWS = normalize(IN.normalWS);
                half3 viewDir  = normalize(IN.viewDirWS);

                // Diffuse (Lambert)
                half NdotL = saturate(dot(normalWS, lightDir));
                half3 diffuse = baseColor * NdotL;

                // Ambient (SH)
                half3 ambient = SampleSH(normalWS) * baseColor;

                // Specular (Blinn-Phong)
                half3 reflectDir = reflect(-lightDir, normalWS);
                half specFactor = pow(saturate(dot(reflectDir, viewDir)), _Shininess);
                half3 specular = _SpecColor.rgb * specFactor;

                // Rim / Fresnel
                half ndotv = saturate(dot(normalWS, viewDir));
                half fresnel = pow(1.0 - ndotv, _RimPower);
                half3 rim = (_RimColor.rgb * fresnel) * _RimStrength;

                // Final color
                half3 finalColor = diffuse + ambient + specular + rim;
                return half4(finalColor, 1.0);
            }

            ENDHLSL
        }
    }

    FallBack Off
}
