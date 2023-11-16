Shader "SamStrong/FresnelGlow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DistortTex ("Distort Texture", 2D) = "white" {}
        _DistortIntensity("Distort Intensity", Range(0, 1)) = 1 
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
            };

            sampler2D _MainTex, _NormalMap, _DistortTex;
            float4 _MainTex_ST;
            float _DistortIntensity;
            float _FresnelIntensity, _FresnelRamp;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);

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
                float distort = tex2D(_DistortTex, i.uv + _Time.xx).r;
                
                float3 finalNormal = i.normal;
                #if NORMAL_MAP_ON
                    float3 normalMap = UnpackNormal(tex2D(_NormalMap, i.uv));
                    finalNormal = normalMap.r * i.tangent + normalMap.g * i.bitangent + normalMap.b * i.normal;
                #endif
                
                float fresnelAmount = 1 - max(0.0, dot(finalNormal, i.viewDir));
                fresnelAmount *= distort * _DistortIntensity;
                // fresnelAmount = fresnelAmount + distort * _DistortIntensity, 0.0, 1.0;
                // fresnelAmount = clamp(fresnelAmount + distort * _DistortIntensity, 0.0, 1.0);
                fresnelAmount = pow(fresnelAmount, _FresnelRamp) * _FresnelIntensity;
                return fresnelAmount;
            }
            ENDCG
        }
    }
}
