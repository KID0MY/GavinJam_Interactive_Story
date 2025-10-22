Shader "LucasShaders/PhongWithGradient"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)   // Base color of the object
        _MainTex ("Base Texture", 2D) = "white" {}        // Texture map
        _SpecColor ("Specular Color", Color) = (1, 1, 1, 1)  // Specular color
        _Shininess ("Shininess", Range(0.1, 100)) = 16      // Shininess (specular exponent)
        
        //Gradient colors
        _mycolor1("Top Color", Color) = (1,1,1,1)
        _mycolor2("Bottom Color", Color) = (0,0,0,1)
        _GradientHeight ("Gradient Height", Range(0.1, 5)) = 1.0
        _GradientOffset ("Gradient Offset", Range(-1, 1)) = 0.0
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalRenderPipeline" "RenderType"="Opaque" }

        Pass
        {
            Name "PhongGradient"
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
                float3 positionOS  : TEXCOORD3; // keep local position for gradient
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _SpecColor;
                float  _Shininess;
                float4 _MainTex_ST;

                float4 _mycolor1;
                float4 _mycolor2;
                float  _GradientHeight;
                float  _GradientOffset;
            CBUFFER_END

            // Vertex
            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                float3 worldPos = TransformObjectToWorld(IN.positionOS.xyz);
                float3 normalWS = normalize(TransformObjectToWorldNormal(IN.normalOS));

                OUT.positionHCS = TransformWorldToHClip(worldPos);
                OUT.normalWS = normalWS;
                OUT.viewDirWS = normalize(GetCameraPositionWS() - worldPos);
                OUT.positionOS = IN.positionOS.xyz;
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                return OUT;
            }

            // Fragment
            half4 frag (Varyings IN) : SV_Target
            {
                // --- "Pass 1" Concept: Gradient Color ---
                float localY = IN.positionOS.y + _GradientOffset;
                float t = saturate(localY / _GradientHeight);
                half3 gradientColor = lerp(_mycolor2.rgb, _mycolor1.rgb, t);

                // --- "Pass 2" Concept: Phong Lighting using Gradient as Base ---
                half4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                half3 baseColor = texColor.rgb * gradientColor;

                // Lighting
                Light mainLight = GetMainLight();
                half3 lightDir = normalize(mainLight.direction);
                half3 normalWS = normalize(IN.normalWS);
                half3 viewDir = normalize(IN.viewDirWS);

                // Diffuse
                half NdotL = saturate(dot(normalWS, lightDir));
                half3 diffuse = baseColor * NdotL;

                // Ambient
                half3 ambient = SampleSH(normalWS) * baseColor;

                // Specular
                half3 reflectDir = reflect(-lightDir, normalWS);
                half specFactor = pow(saturate(dot(reflectDir, viewDir)), _Shininess);
                half3 specular = _SpecColor.rgb * specFactor;

                // Combine
                half3 finalColor = diffuse + ambient + specular;

                return half4(finalColor, 1.0);
            }

            ENDHLSL
        }
    }

    FallBack Off
}