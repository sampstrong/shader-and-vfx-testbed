Shader "SamStrong/BasicDiffuse"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,0)
        _Gloss ("Gloss", Float) = 1
        //_MainTex ("Texture", 2D) = "white" {}
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

            //sampler2D _MainTex;
            //float4 _MainTex_ST;

            float4 _Color;
            float _Gloss;

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
                float3 ambientLight = float3(0.1, 0.1, 0.1);

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
                float3 normal = normalize(o.normal); // Interpolated

                float3 diffuse = getDiffuseLight(normal);
                float3 ambient = getAmbientLight(normal);
                float3 specular = getSpecularLight(normal, o.worldPos);
                float3 directSpecular = specular * _LightColor0.rgb;
                float3 diffuseLight = ambient + diffuse;
                float3 finalSurfaceColor = diffuseLight * _Color.rgb;
                
                return float4 (finalSurfaceColor, 0);
            }
            ENDCG
        }
    }
}
