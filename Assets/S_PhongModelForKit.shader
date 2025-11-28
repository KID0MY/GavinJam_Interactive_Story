Shader "LucasShaders/PhongModel_Advanced_Ambient"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _MainTex ("Albedo", 2D) = "white" {}

        _NormalMap ("Normal Map", 2D) = "bump" {}
        _HeightMap ("Height Map", 2D) = "black" {}
        _RoughnessMap ("Roughness Map", 2D) = "white" {}

        _HeightStrength ("Height Strength", Range(0,0.1)) = 0.02
        _SpecColor ("Specular Color", Color) = (1,1,1,1)
        _Shininess ("Base Shininess", Range(1,100)) = 16
        _AmbientColor ("Ambient Color", Color) = (0.2,0.2,0.2,1)
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" }

        Pass
        {
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
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS : TEXCOORD1;
                float3 tangentWS : TEXCOORD2;
                float3 bitangentWS : TEXCOORD3;
                float2 uv : TEXCOORD0;
                float3 viewDirWS : TEXCOORD4;
                float3 worldPos : TEXCOORD5;
            };

            // Textures
            TEXTURE2D(_MainTex);      SAMPLER(sampler_MainTex);
            TEXTURE2D(_NormalMap);    SAMPLER(sampler_NormalMap);
            TEXTURE2D(_HeightMap);    SAMPLER(sampler_HeightMap);
            TEXTURE2D(_RoughnessMap); SAMPLER(sampler_RoughnessMap);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                float4 _SpecColor;
                float4 _MainTex_ST;
                float4 _NormalMap_ST;
                float4 _HeightMap_ST;
                float4 _RoughnessMap_ST;
                float4 _AmbientColor;

                float _Shininess;
                float _HeightStrength;
            CBUFFER_END

            // Vertex Shader
            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normalWS = normalize(TransformObjectToWorldNormal(IN.normalOS));

                float3 t = normalize(TransformObjectToWorldDir(IN.tangentOS.xyz));
                float3 b = cross(OUT.normalWS, t) * IN.tangentOS.w;

                OUT.tangentWS = t;
                OUT.bitangentWS = b;

                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                OUT.worldPos = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.viewDirWS = normalize(GetCameraPositionWS() - OUT.worldPos);

                return OUT;
            }

            // Parallax
            float2 ApplyParallax(float2 uv, float2 uvH, float3 viewDir)
            {
                float height = SAMPLE_TEXTURE2D(_HeightMap, sampler_HeightMap, uvH).r;
                float offset = (height - 0.5) * _HeightStrength;
                return uv + viewDir.xy * offset;
            }

            // Fragment Shader
            half4 frag(Varyings IN) : SV_Target
            {
                float2 uvH = TRANSFORM_TEX(IN.uv, _HeightMap);
                float2 uvN = TRANSFORM_TEX(IN.uv, _NormalMap);
                float2 uvR = TRANSFORM_TEX(IN.uv, _RoughnessMap);

                float2 uv = ApplyParallax(IN.uv, uvH, IN.viewDirWS);

                // Albedo
                half3 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv).rgb * _BaseColor.rgb;

                // Normal map
                half3 n = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, uvN));
                float3x3 TBN = float3x3(IN.tangentWS, IN.bitangentWS, IN.normalWS);
                half3 normalWS = normalize(mul(n, TBN));

                // Main Light
                Light mainLight = GetMainLight();
                half3 L = normalize(mainLight.direction);

                // Diffuse
                half NdotL = saturate(dot(normalWS, L));
                half3 diffuse = albedo * NdotL;

                // Roughness → shininess
                half rough = SAMPLE_TEXTURE2D(_RoughnessMap, sampler_RoughnessMap, uvR).r;
                half shininessFinal = lerp(100, 1, rough);

                // Specular
                half3 V = normalize(IN.viewDirWS);
                half3 R = reflect(-L, normalWS);
                half spec = pow(saturate(dot(R, V)), shininessFinal);
                half3 specular = _SpecColor.rgb * spec;

                // Ambient (custom)
                half3 ambient = _AmbientColor.rgb * albedo;

                return half4(diffuse + specular + ambient, 1);
            }

            ENDHLSL
        }
    }
}
