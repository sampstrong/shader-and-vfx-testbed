Shader "Unlit/Parallax-Single"
{
    Properties
    {
        _Color ("Color", Color) = (0.5,0.5,0.5,1)
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        _ParallaxDepth ("Parallax Depth" , Float) = 3.0
        _Density ("Pattern Density", Float) = 10.0
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
            };
 
            sampler2D _MainTex;
            float _ParallaxDepth, _Density;
 
            v2f vert (appdata_full v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.worldPos = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0)).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                o.worldBitangent = cross(o.worldNormal, o.worldTangent) * v.tangent.w * unity_WorldTransformParams.w;
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
                
                float2 layerUV = ParallaxOffsetUV(i.uv, tangentSpaceViewDir, _ParallaxDepth);
                float2 nUv = frac(layerUV * _Density);
                float dist = distance(0.5, nUv);
                float strength = step(0.4, dist);
                float3 dot = strength;
                float4 col = float4(dot, 1.0);
                
                return col * _Color;
            }
            ENDCG
        }
    }
}
