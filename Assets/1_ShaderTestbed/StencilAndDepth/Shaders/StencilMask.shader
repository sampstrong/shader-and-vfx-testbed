
// Working mask override setups

// 1
// Mask : Zwrite Off, ZTest LEqual, Comp Always, Pass Replace, 
// Object: Zwrite On, Comp NotEqual, Pass Replace

// 2 - renders in front of everything, regardless of render order
// Mask : Zwrite On, ZTest LEqual, Comp Always, Pass Replace, 
// Object: Zwrite On, ZTest Always, Comp NotEqual, Pass Replace



Shader "Unlit/StencilMask"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Geometry" }
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100
//        ColorMask 0
        ZTest LEqual
        ZWrite Off // zwrite on will make it so unmasked object dissappears
        
        Stencil
        {
            Ref 1
            Comp Always
            Pass Replace
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
                col.a = 0.02;
                return col;
            }
            ENDCG
        }
    }
}
