Shader "USB/USB_function_SinCos"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Speed ("Speed", Range(0, 3)) = 1
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
            float _Speed;

            float3 rotation(float3 vertex)
            {
                // add the rotation variables
                float c = cos(_Time.y * _Speed);
                float s = sin(_Time.y * _Speed);
                
                
                // create a three dimensional matrix
                float3x3 m = float3x3
                (
                    c, 0, s,
                    0, 1, 0,
                   -s, 0, c
                );

                // multiply the matrix by the vertex input
                return mul(m, vertex);
            }

            v2f vert (appdata v)
            {
                v2f o;
                float3 rotVertex = rotation(v.vertex);
                o.vertex = UnityObjectToClipPos(rotVertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
