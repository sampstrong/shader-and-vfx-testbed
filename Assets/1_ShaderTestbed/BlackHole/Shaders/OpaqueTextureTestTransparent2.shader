Shader "Unlit/OpaqueTextureTestTransparent2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseAmount ("Noise Amount", Range(0, 1)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "IgnoreProjector"="True" "Queue"="Transparent" }
        Blend One OneMinusSrcAlpha
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
                float4 screenPos : TEXCOORD1;
                float3 normal : TEXCOORD2;
            };

            sampler2D _MainTex;
            sampler2D _CameraOpaqueTexture;
            float4 _MainTex_ST;
            float _NoiseAmount;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.screenPos = ComputeScreenPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                
                fixed4 col = tex2D(_MainTex, i.uv);
                // float2 screenPosition = (i.screenPos.xy / i.screenPos.w);
                // float2 screenPosition = float2(i.screenPos.x, 1 - i.screenPos.y) / 2.0;
                // float2 screenPosition = float2(i.screenPos.x / _ScreenParams.x, i.screenPos.y / _ScreenParams.y);
                float2 screenPosition = i.screenPos.xy / (_ScreenParams.x / _ScreenParams.y);
                
                fixed4 screenColor = tex2D(_CameraOpaqueTexture, screenPosition);
                
                // float3 animatedNormal = float3(i.normal.x, i.normal.y + _Time.y, i.normal.z);
                // float3 noise = snoise(animatedNormal);
                //
                // float2 screenNoise = screenPosition * noise.xy;
                // float2 final = lerp(screenPosition, screenNoise, _NoiseAmount);
                //
                // final += screenPosition;
                //
                // fixed4 screenColor = tex2D(_CameraOpaqueTexture, final);
                
                return fixed4(screenColor.xyz, 1.0);
            }
            ENDCG
        }
    }
}
