Shader "Unlit/FakeDepth"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _GradientScale("Gradient Scale", Float) = 1.0
        _Offset("Offset", FLoat) = 0.0
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
                float3 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _GradientScale, _Offset;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                fixed4 white = fixed4(1.0, 1.0, 1.0, 1.0);
                fixed4 black = fixed4(0.0, 0.0, 0.0, 1.0);

                col = lerp(black, white, (i.worldPos.y + _Offset) / _GradientScale);
                
                return col;
            }
            ENDCG
        }
    }
}
