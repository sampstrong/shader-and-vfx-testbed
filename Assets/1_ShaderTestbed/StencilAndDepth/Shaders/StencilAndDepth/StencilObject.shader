Shader "Unlit/StencilObject"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Stencil ("Stencil", Float) = 1
        [Enum(UnityEngine.Rendering.CompareFunction)] _Comp ("Comp", Float) = 1
        [Enum(UnityEngine.Rendering.StencilOp)] _Pass ("Pass", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
//        Zwrite On
//        ZTest Always
        
        // Comparison Operations
        // 1 - Never
        // 2 - Less
        // 3 - Equal
        // 4 - LEqual
        // 5 - Greater
        // 6 - NotEqual
        // 7 - GEqual
        // 8 - Always
        
        // Pass Operations
        // 0 - Keep
        // 1 - Zero
        // 2 - Replace
        // 3 - IncrSat
        // 4 - DecrSat
        // 5 - Invert
        // 6 - IncrWrap
        // 7 - DecrWrap
        
        Stencil
        {
            Ref [_Stencil]
            Comp [_Comp]
            Pass [_Pass]
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
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
