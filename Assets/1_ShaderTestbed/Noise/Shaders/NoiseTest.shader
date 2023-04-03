Shader "Unlit/NoiseTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseScale ("Noise Scale", Float) = 1
        [HDR] _EdgeColor ("Edge Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Cull Off
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Assets/1_ShaderTestbed/cginc/noise.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _NoiseScale;
            float4 _EdgeColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                col = snoise(i.normal * _NoiseScale);
                fixed4 finalColor = frac(col + _Time.y * 0.25);
                
                if (finalColor.r > 0.6)
                {
                    discard;
                }
                if (finalColor.r > 0.5 || finalColor.r < 0.1)
                {
                    // finalColor = fixed4(0.2, 0.8, 0.9, 1);
                    finalColor = _EdgeColor;
                }
                else
                {
                    // finalColor *= fixed4(0.8, 0.4, 0.9, 1);
                    finalColor = (1 - finalColor) * (fixed4(i.normal.x, i.normal.y, i.normal.z, 1) * 0.5 + 0.5);
                }
                
                return finalColor;
            }
            ENDCG
        }
    }
}
