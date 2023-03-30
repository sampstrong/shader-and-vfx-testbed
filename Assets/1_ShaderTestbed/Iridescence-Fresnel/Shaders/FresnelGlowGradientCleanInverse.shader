Shader "SamStrong/FresnelGlowGradientCleanInverse"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        _Transparency("Transparency", Range(0, 1)) = 1
        
        _Gloss ("Roughness", Range(0.0001, 1)) = 0.1
        _GlossColor ("Specular Color", Color) = (1,1,1,0)
        
        _GradientTex ("Gradient Texture", 2D) = "white" {}
        
        _FresnelIntensity("Fresnel Intensity", Range(0, 10)) = 0 
        _FresnelRamp("Fresnel Ramp", Range(0, 10)) = 0 
        
        [Toggle] NORMAL_MAP ("Normal Mapping", float) = 0
        _NormalMap ("Normal Map", 2D) = "white" {}
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile __ NORMAL_MAP_ON
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float3 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                float3 tangent : TEXCOORD3;
                float3 bitangent : TEXCOORD4;
                float3 worldPos : TEXCOORD5;
            };

            sampler2D _MainTex, _NormalMap, _GradientTex;
            float4 _MainTex_ST;
            float _FresnelIntensity, _FresnelRamp;
            float _Gloss;
            float4 _GlossColor;
            float _Transparency;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                #if NORMAL_MAP_ON
                    o.tangent = UnityObjectToWorldDir(v.tangent);
                    o.bitangent = cross(o.tangent, o.normal);
                #endif
                
                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 finalNormal = i.normal;
                #if NORMAL_MAP_ON
                    float3 normalMap = UnpackNormal(tex2D(_NormalMap, i.uv));
                    finalNormal = normalMap.r * i.tangent + normalMap.g * i.bitangent + normalMap.b * i.normal;
                #endif

                
                // Direct Light
                float3 lightDir = _WorldSpaceLightPos0.xyz;
                
                
                // Direct Specular Light
                float3 camPos = _WorldSpaceCameraPos;
                float3 fragToCam = camPos - i.worldPos;
                float3 viewDir = normalize(fragToCam);

                float3 viewReflect = reflect(-viewDir, finalNormal);
                float specularFalloff = max(0, dot(viewReflect, lightDir));
                specularFalloff = pow(specularFalloff, _Gloss);
                float3 directSpecular = specularFalloff * _GlossColor;

                
                float fresnelAmount = max(0.0, dot(finalNormal, i.viewDir));
                fresnelAmount = pow(fresnelAmount, _FresnelRamp) * _FresnelIntensity;
                
                
                float2 gradUV = float2(fresnelAmount, 0.5);
                float3 gradient = tex2D(_GradientTex, gradUV);


                float3 finalColor = fresnelAmount * gradient;
                finalColor = finalColor + directSpecular;

                float alpha = lerp(1.0, fresnelAmount, _Transparency);
                
                return fixed4(finalColor, alpha);
            }
            ENDCG
        }
    }
}
