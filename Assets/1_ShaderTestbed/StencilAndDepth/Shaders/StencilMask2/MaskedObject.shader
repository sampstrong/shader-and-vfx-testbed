Shader "Custom/Stencil/MaskedObject"
{
    Properties
    {
        _StencilRef ("Stencil Ref", Float) = 1
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilCompFunction ("Stencil Comp Function", Float) = 1
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilPassOperation ("Stencil Pass Operation", Float) = 1
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilZFailOperation ("Stencil ZFail Operation", Float) = 1
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        
        Stencil
        {
            Ref [_StencilRef]
            Comp [_StencilCompFunction]
            Pass [_StencilPassOperation]
            ZFail [_StencilZFailOperation]
        }

        Pass
        {
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
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(0.0, 0.5, 1.0, 1.0);
            }
            ENDCG
        }
    }
}
