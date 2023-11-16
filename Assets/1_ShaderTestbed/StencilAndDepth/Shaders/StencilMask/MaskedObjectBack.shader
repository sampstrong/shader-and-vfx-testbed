Shader "Custom/MaskedObjectBack" 
{
    SubShader 
    {
        Tags { "Queue" = "Transparent" } // Render queue to ensure it's rendered after the stencil mask
        
        Pass 
        {
            Name "OverlappingMask"
            
            Stencil 
            {
                Ref 1         // Set the same reference value as in the StencilMaskShader
                Comp equal    // Only render where the stencil value is equal to the reference value
                Pass replace  // Replace the stencil value with the reference value
                ZFail keep    // Keep the depth buffer unchanged
            }
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = fixed4(1,1,1,1);
                return col;
            }
            ENDCG
        }
        Pass 
        {
            Name "OutsideMask"
            Stencil 
            {
                Ref 0         // Render normally where stencil value is 0 (no mask)
                Comp always   // Always write to the stencil buffer
                Pass replace  // Replace the stencil value with 0
                ZFail keep    // Keep the depth buffer unchanged
            }
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = fixed4(0,0.5,1,1);
                return col;
            }
            ENDCG
        }
    }
}
