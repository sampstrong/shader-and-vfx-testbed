Shader "Unlit/ShaderNotes"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            
            // pragmas define what functions the shader must include
            #pragma vertex vert
            #pragma fragment frag

            // import libraries with .cginc files
            #include "UnityCG.cginc"

            struct appdata
            {
                // the local/object space position for each vertex
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 normal : TEXCOORD3;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                
                // unity_ObjectToWorld is the modelMatrix
                // multiply by local position to get world pos
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                
                // UnityObjectToWorldNormal calculates the correct normal
                o.normal = UnityObjectToWorldNormal(v.normal);
                
                // UnityObjectToClipPos multiplies vertex pos by MVP matrix
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                // TRANSFORM_TEX sets up the tiling and texture wrapping
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
