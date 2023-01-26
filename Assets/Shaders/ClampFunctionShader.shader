Shader "USB/USB_function_Clamp"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Xvalue ("X", Range (0, 1)) = 0
        _Avalue ("A", Range (0, 1)) = 0
        _Bvalue ("B", Range (0, 1)) = 0
        
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
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Xvalue;
            float _Avalue;
            float _Bvalue;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float ourClamp(float a, float x, float b)
            {
                return max(a, min(x, b));
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // float darkness = ourClamp(_Avalue, _Xvalue, _Bvalue);

                float darkness = clamp(_Avalue, _Xvalue, _Bvalue);
                
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv) * darkness;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
