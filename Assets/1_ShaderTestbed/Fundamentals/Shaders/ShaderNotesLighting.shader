Shader "Unlit/ShaderNotesLighting"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Ambient ("Ambient Amount", Range(0, 1)) = 1
        _Gloss ("Gloss", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Ambient;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            
            float normalizeGloss(float gloss01)
            {
                // converts 0-1 gloss values to correct scale
                return exp2(gloss01 * 8.0) + 2;
            }

            float4 blinnPhong(float3 normal, float3 worldPos, float3 color, float gloss)
            {
                float3 N = normalize(normal); // must always normalize normal again in fragment stage
                float3 L = _WorldSpaceLightPos0.xyz;
                float3 V = normalize(_WorldSpaceCameraPos - worldPos);

                float3 lambert = saturate(dot(N, L));
                float3 diffuseLight = lambert * unity_LightColor0.xyz;
                float3 diffuseColor = diffuseLight * color;
                float3 ambientLight = UNITY_LIGHTMODEL_AMBIENT.xyz;
                float3 H = normalize(L + V);
                float3 specularLight = saturate(dot(N, H)) * (lambert > 0.0);
                specularLight = pow(specularLight, gloss) * unity_LightColor0.xyz;

                return float4(diffuseColor + ambientLight + specularLight, 1.0);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                
                // UNITY_LIGHTMODEL_AMBIENT gives the ambient color for the scene
                float3 ambient_color = UNITY_LIGHTMODEL_AMBIENT * _Ambient;
                col.rgb += ambient_color;
                return col;
            }
            ENDCG
        }
    }
}
