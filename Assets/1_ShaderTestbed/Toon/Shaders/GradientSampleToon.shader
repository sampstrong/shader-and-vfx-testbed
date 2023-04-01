Shader "SamStrong/GradientSampleToon"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,0)
        _Gloss ("Gloss", Float) = 1
        _Gradient ("Gradient Texture", 2D) = "white" {}
        _Softness ("Edge Softness", Range(0, 0.1)) = 0.05
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct VertexInput
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv0 : TEXCOORD0;
            };

            struct VertexOutput
            {
                float4 clipSpacePos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            sampler2D _Gradient;
            float4 _Gradient_ST;

            float4 _Color;
            float _Gloss;

            float _Softness;

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.uv0 = v.uv0;
                o.normal = v.normal;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.clipSpacePos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float4 frag (VertexOutput o) : SV_Target
            {
                float2 uv = o.uv0;
                float3 normal = normalize(o.normal); // Interpolated

                // Lighting

                // Direct Light
                float3 lightDir = _WorldSpaceLightPos0.xyz;
                float3 lightColor = _LightColor0.rgb;
                float lightFalloff = max(0, dot(lightDir, normal));
                float3 directDiffuseLight = lightColor * lightFalloff;

                // Ambient Light
                float3 ambientLight = float3(0.1, 0.1, 0.1);

                //Direct Specular Light
                float3 camPos = _WorldSpaceCameraPos;
                float3 fragToCam = camPos - o.worldPos;
                float3 viewDir = normalize(fragToCam);

                float3 viewReflect = reflect(-viewDir, normal);
                

                float specularFalloff = max(0, dot(viewReflect, lightDir));

                specularFalloff = pow(specularFalloff, _Gloss);

                float3 directSpecular = specularFalloff * lightColor;


                // Composite
                float diffuseLight = ambientLight + directDiffuseLight;
                float3 finalSurfaceColor = diffuseLight * _Color.rgb + directSpecular;


                // custom toon
                float2 gradUV = float2(clamp(lightFalloff, 0.01, 0.99), 0.5);
                float3 grad = tex2D(_Gradient, gradUV);

                float3 light = float3(lightFalloff, lightFalloff, lightFalloff);


                float s0 = 0.01;
                float3 g0 = tex2D(_Gradient, float2(s0, 0.5));

                float s1a = 0.2;
                s1a = s1a - (_Softness/2);
                float s1b = s1a + (_Softness/2);
                float3 g1 = tex2D(_Gradient, float2(s1a, 0.5));
                float3 steppedGrad1 = smoothstep(float3(s1a, s1a, s1a), float3(s1b, s1b, s1b), lightFalloff) * g1;

                float s2a = 0.3;
                s2a = s2a - (_Softness/2);
                float s2b = s2a + (_Softness/2);
                float3 g2 = tex2D(_Gradient, float2(s2a, 0.5));
                float3 steppedGrad2 = smoothstep(float3(s2a, s2a, s2a), float3(s2b, s2b, s2b), lightFalloff) * g2;

                float s3a = 0.5;
                s3a = s3a - (_Softness/2);
                float s3b = s3a + (_Softness/2);
                float3 g3 = tex2D(_Gradient, float2(s3a, 0.5));
                float3 steppedGrad3 = smoothstep(float3(s3a, s3a, s3a), float3(s3b, s3b, s3b), lightFalloff) * g3;

                float s4a = 0.7;
                s4a = s4a - (_Softness/2);
                float s4b = s4a + (_Softness/2);
                float3 g4 = tex2D(_Gradient, float2(s4a, 0.5));
                float3 steppedGrad4 = smoothstep(float3(s4a, s4a, s4a), float3(s4b, s4b, s4b), lightFalloff) * g4;

                float s5a = 0.87;
                s5a = s5a - (_Softness/2);
                float s5b = s5a + (_Softness/2);
                float3 g5 = tex2D(_Gradient, float2(s5a, 0.5));
                float3 steppedGrad5 = smoothstep(float3(s5a, s5a, s5a), float3(s5b, s5b, s5b), lightFalloff) * g5;

                float s6a = 0.95;
                s6a = s6a - (_Softness/2);
                float s6b = s6a + (_Softness/2);
                float3 g6 = tex2D(_Gradient, float2(s6a, 0.5));
                float3 steppedGrad6 = smoothstep(float3(s6a, s6a, s6a), float3(s6b, s6b, s6b), lightFalloff) * g6;

                float3 final = g0 + max(steppedGrad6, max(steppedGrad5, max(steppedGrad4, max(steppedGrad3, max(steppedGrad1, steppedGrad2)))));

                // if (grad == float3(0,0,0))
                // {
                //     grad = tex2D(_Gradient, float2(0.9, 0.5));
                // }

                float3 test = tex2D(_Gradient, float2(s3a, 0.5));
                
                return float4 (final, 0);
            }
            ENDCG
        }
    }
}
