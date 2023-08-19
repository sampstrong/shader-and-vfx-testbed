Shader "Unlit/Parallax-Screenspace"
{
    Properties
    {
        _Color ("Color", Color) = (0.5,0.5,0.5,1)
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        _NumLayers ("Number of Layers", Float) = 10
        _LayerOffset ("Layer Offset Scale", Float) = 0.025
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
 
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
                float3 worldTangent : TEXCOORD3;
                float3 worldBitangent : TEXCOORD4;
                float4 screenPos : TEXCOORD5;
                float2 screenUv : TEXCOORD6;
            };
 
            sampler2D _MainTex;
 
            v2f vert (appdata_full v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.worldPos = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0)).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                o.worldBitangent = cross(o.worldNormal, o.worldTangent) * v.tangent.w * unity_WorldTransformParams.w;
                o.screenPos = ComputeScreenPos(o.vertex);
                o.screenUv = o.screenPos.xy / o.screenPos.w;
                o.screenUv *= float2(_ScreenParams.x / _ScreenParams.y, 1.0);
                return o;
            }
 
            float2 ParallaxOffsetUV(float2 uv, float3 tangentSpaceViewDir, float offsetScale)
            {
                float2 uvOffset = tangentSpaceViewDir.xy / tangentSpaceViewDir.z;
                uvOffset *= offsetScale;
                return uv - uvOffset;
            }
 
            float4 _Color;
            float _NumLayers;
            float _LayerOffset;
 
            fixed4 frag (v2f i) : SV_Target
            {
                float3 worldSpaceViewDir = UnityWorldSpaceViewDir(i.worldPos);
                float3x3 tbn = float3x3(i.worldTangent, i.worldBitangent, i.worldNormal);
                float3 tangentSpaceViewDir = mul(tbn, worldSpaceViewDir);
 
                float4 col = 0;
                float2 nUv = frac(i.screenUv * 20.0);
                float dist = distance(0.5, nUv);
                float strength = step(0.4, dist);
                float3 dot = strength;
                col = float4(dot, 1.0);
//                 for (int iter=0; iter<_NumLayers; iter++)
//                 {
//                     float2 layerUV = ParallaxOffsetUV(i.screenUv, tangentSpaceViewDir, _LayerOffset * float(iter));
//                     float layerFade = 1.0 - (float(iter) / _NumLayers);
//                     col += tex2D(_MainTex, layerUV) * layerFade;
//                 }
                return col * _Color;
            }
            ENDCG
        }
    }
}
