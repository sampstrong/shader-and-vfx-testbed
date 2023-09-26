Shader "Custom/StencilMask" {
    SubShader 
    {
        Tags { "Queue" = "Geometry" } // Render queue to ensure it's rendered before dynamic objects
        Blend SrcAlpha OneMinusSrcAlpha
//        ColorMask 0
        
        Pass 
        {
            Stencil 
            {
                Ref 1         // Set a reference value
                Comp always   // Always write to the stencil buffer
                Pass replace  // Replace the stencil value with the reference value
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
                fixed4 col = fixed4(1,1,1,0.2);
                return col;
            }
            ENDCG
        }
    }
}


