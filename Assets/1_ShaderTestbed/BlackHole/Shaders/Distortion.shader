Shader "Unlit/Distortion"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
//        Cull Front
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
                float4 screenPos : TEXCOORD1;
            };

            sampler2D _CameraOpaqueTexture;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.screenPos = ComputeScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // does the same thing
                // float2 screenUV = i.screenPos.xy / i.screenPos.w;
                // fixed4 opaque = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_CameraOpaqueTexture, UNITY_PROJ_COORD(screenUV));

                float4 distortedUv = i.screenPos;
                float dist = distance(0.5, i.uv);
                float strength = sin(dist * 50 + _Time.y) * 0.5 + 0.5;
                strength = lerp(strength, 0.0, saturate(dist * 2.0)) * 1.0;
                distortedUv += strength;
                
                fixed4 distortion = tex2Dproj(_CameraOpaqueTexture, distortedUv);

                
                
                fixed4 col = fixed4(1.0, 0.0, 0.0, 1.0);
                fixed4 s = strength;
                return distortion;
            }
            ENDCG
        }
    }
}
