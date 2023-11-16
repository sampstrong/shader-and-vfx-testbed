Shader "IridescencePack/IridescentConfigurable"
{
    Properties
    {
        [Header(TEXTURES)]
        [Space(10)]
        _MainTex ("Main Texture", 2D) = "white" {}
        [Space(10)]
        [Toggle] NORMAL_MAP ("Normal Mapping", float) = 0
        [NoScaleOffset] _NormalMap ("Normal Map", 2D) = "white" {}
        [Space(20)]
        
        [Header(COLOR SELECTION)]
        [Space(10)]
        _Color1 ("Color1", Color) = (0.5,0,1,0)
        _Color1Threshold ("Color1/Color2 Threshold", Range(0,1)) = 0.05
        _Color2 ("Color2", Color) = (0.8,1,0,1)
        _Color2Threshold ("Color2/Color3 Threshold", Range(0,1)) = 0.2
        _Color3 ("Color3", Color) = (1,0.2,0.3,1)
        _Color3Threshold ("Color3/Color4 Threshold", Range(0,1)) = 0.4
        _Color4 ("Color4", Color) = (0.1,0.4,1,1)
        [Space(20)]
        
        [Header(EFFECT PROPERTIES)]
        [Space(10)]
        _FresnelIntensity("Fresnel Intensity", Range(0, 10)) = 0 
        _FresnelRamp("Fresnel Ramp", Range(0, 10)) = 0 
        [Space(20)]
        
        [Header(LIGHTING PROPERTIES)]
        [Space(10)]
        _GlossColor ("Specular Color", Color) = (1,1,1,0)
        _Gloss ("Roughness", Range(0.0001, 1)) = 0.1
        _Shading("Shading Override", Range(0, 1)) = 1
        _Transparency("Transparency", Range(0, 1)) = 1
        
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Back

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
            float4 _MainTex_ST, _NormalMap_ST;
            float4 _Color1, _Color2, _Color3, _Color4;
            float _Color1Threshold, _Color2Threshold, _Color3Threshold, _Color4Threshold;
            float _FresnelIntensity, _FresnelRamp;
            float _Gloss, _Shading;
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

            float3 gradient (float fresnelAmount)
            {
                float stepAmount = 0.2;
                float3 black = float3(0, 0, 0);

                float pct1 = smoothstep(_Color1Threshold, _Color1Threshold + stepAmount, fresnelAmount);
                float pct2 = smoothstep(_Color1Threshold, _Color1Threshold + stepAmount, fresnelAmount) -
                    smoothstep(_Color2Threshold, _Color2Threshold + stepAmount, fresnelAmount);
                float pct3 = smoothstep(_Color2Threshold, _Color2Threshold + stepAmount, fresnelAmount) -
                    smoothstep(_Color3Threshold, _Color3Threshold + stepAmount, fresnelAmount);
                float pct4 = smoothstep(_Color3Threshold, _Color3Threshold + stepAmount, fresnelAmount);

                float3 c1 = lerp(_Color1, black, pct1);
                float3 c2 = lerp(black, _Color2, pct2);
                float3 c3 = lerp(black, _Color3, pct3);
                float3 c4 = lerp(black, _Color4, pct4);

                float3 g = clamp(c1 + c2 + c3 + c4, 0, 1);

                return g;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 normal = i.normal;
                #if NORMAL_MAP_ON
                    float3 normalMap = UnpackNormal(tex2D(_NormalMap, i.uv));
                    normal = normalMap.r * i.tangent + normalMap.g * i.bitangent + normalMap.b * i.normal;
                #endif

                
                // lighting
                float3 diffuse = getDiffuseLight(normal);
                float3 ambient = getAmbientLight(normal);
                float3 specular = getSpecularLight(normal, i.worldPos);
                float3 directSpecular = specular * _GlossColor;
                float3 diffuseLight = ambient + diffuse;

                // fresnel
                float fresnelAmount = 1 - max(0.0, dot(normal, i.viewDir));
                fresnelAmount = pow(fresnelAmount, _FresnelRamp) * _FresnelIntensity;

                // gradient
                float3 grad = gradient(fresnelAmount);

                // texture
                float4 tex = tex2D(_MainTex, i.uv);


                float3 finalColor = grad;
                finalColor = finalColor + directSpecular;
                finalColor = (finalColor + directSpecular) * max(float3(_Shading, _Shading, _Shading), (diffuseLight + fresnelAmount / 4) * (ambient * 2) + (fresnelAmount * diffuseLight));

                finalColor *= tex;

                float alpha = lerp(1.0, fresnelAmount, _Transparency);
                
                return fixed4(finalColor, alpha);
            }
            ENDCG
        }
    }
}
