Shader "SamStrong/CustomToon3Tone"
{
    Properties
    {
        _Shadow ("Shadow", Color) = (1,1,1,0)
        _Midtone ("Midtone", Color) = (1,1,1,0)
        _Highlight ("Highlight", Color) = (1,1,1,0)
        _ShadowThreshold("Shadow Threshold", Range(0, 1)) = 0.3
        _HighlightThreshold("Highlight Threshold", Range(0, 1)) = 0.9
        _Softness("Softness", Range(0, 0.1)) = 0.05
        _Gloss ("Gloss", Float) = 1
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

            float4 _Shadow, _Midtone, _Highlight;
            float _Gloss, _ShadowThreshold, _HighlightThreshold, _Softness;

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.uv0 = v.uv0;
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.clipSpacePos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float3 getDiffuseLight(float3 normal)
            {
                float3 lightDir = _WorldSpaceLightPos0.xyz;
                float3 lightColor = _LightColor0.rgb;
                float lightFalloff = max(0, dot(lightDir, normal));
                float3 directDiffuseLight = lightColor * lightFalloff;

                return directDiffuseLight;
            }

            float3 getAmbientLight(float3 normal)
            {
                float3 a = ShadeSH9(float4(normal, 1.0));
                return a;
            }

            float3 getSpecularLight(float3 normal, float3 worldPos)
            {
                float3 camPos = _WorldSpaceCameraPos;
                float3 fragToCam = camPos - worldPos;
                float3 viewDir = normalize(fragToCam);
                float3 viewReflect = reflect(-viewDir, normal);
                
                float specularFalloff = max(0, dot(viewReflect, _WorldSpaceLightPos0.xyz));
                specularFalloff = pow(specularFalloff, _Gloss);

                return specularFalloff;
            }

            float4 frag (VertexOutput o) : SV_Target
            {
                float2 uv = o.uv0;
                float3 normal = normalize(o.normal);

                float3 diffuse = getDiffuseLight(normal);
                float3 ambient = getAmbientLight(normal);
                float3 specular = getSpecularLight(normal, o.worldPos);
                float3 directSpecular = specular * _LightColor0.rgb;
                float3 diffuseLight = ambient + diffuse;
                float3 finalSurfaceColor = diffuseLight * _Midtone.rgb + directSpecular;

                diffuseLight += directSpecular;

                float3 shadow = _Shadow;
                float3 StoM = smoothstep(_ShadowThreshold, _ShadowThreshold + _Softness, diffuseLight.g) * _Midtone;
                float3 MtoH = smoothstep(_HighlightThreshold, _HighlightThreshold + _Softness, directSpecular.g) * _Highlight;

                float3 toon = clamp(max(MtoH, max(shadow, StoM)), 0, 1);
                
                return float4 (toon, 0);
            }
            ENDCG
        }
    }
}
