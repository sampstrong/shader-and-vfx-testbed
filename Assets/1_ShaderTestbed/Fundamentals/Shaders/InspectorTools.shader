Shader "Unlit/InspectorTools"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        // https://docs.unity3d.com/ScriptReference/Rendering.CompareFunction.html
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilCompFunction ("Stencil Comp Function", Float) = 1
        
        // https://docs.unity3d.com/ScriptReference/Rendering.StencilOp.html
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilPassOperation ("Stencil Pass Operation", Float) = 1
        
        // pulls a specific unity enum - see links below
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("ZTest", Float) = 4
        
        // keyword enums can be used to create your own enums - up to 9 slots
        [KeywordEnum(False, True)] _ZWrite ("ZWrite", Float) = 1
        
        // keyword enums also set the value of defines
        [KeywordEnum(OVERLAY, MULTIPLY, ADD)] _Blending ("Blending", Float) = 1
        
        // toggles can be used to se the values of defines - later use #ifdef and #endif
        [Toggle(ENABLE_FEATURE)] _Feature ("Feature", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        
        ZTest [_ZTest]
        ZWrite [_ZWrite]
        
        Stencil
        {
            Pass [_StencilPassOperation]
            Comp [_StencilCompFunction]
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
