Shader "Custom/Stencil/StencilMaskConnectorTransparent"
{
    Properties
    {
        [Header(Pass 1)]
        [Space]
        _StencilRef ("Stencil Ref", Float) = 1
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilCompFunction ("Stencil Comp Function", Float) = 1
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilPassOperation ("Stencil Pass Operation", Float) = 1
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilZFailOperation ("Stencil ZFail Operation", Float) = 1
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry-1" }
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100

        Pass
        {
            Stencil
            {
                Ref [_StencilRef]              // 1
                Comp [_StencilCompFunction]    // Always
                Pass [_StencilPassOperation]   // Replace
                ZFail [_StencilZFailOperation] // Keep
            }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 localPos : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.localPos = v.vertex;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col1 = 1.0;
                fixed4 col2 = col1;
                col2.a = 0.0;
                // fixed4 col2 = fixed4(0.0, 0.5, 1.0, 1.0);
                return lerp(col1, col2, saturate(pow(i.localPos.y + 0.5, 0.5)));
            }
            ENDCG
        }
    }
}
