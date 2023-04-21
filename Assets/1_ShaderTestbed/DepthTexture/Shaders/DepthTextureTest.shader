Shader "Unlit/DepthTextureTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True" }
        Blend One OneMinusSrcAlpha
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
                float4 vertex : SV_POSITION;
                float4 depthPos : TEXCOORD1;
                float2 depth : TEXCOORD3;
            };

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            float4 _MainTex_ST;

            

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.depthPos = ComputeScreenPos(v.vertex);
                // UNITY_TRANSFER_DEPTH(o.depth);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                if (_ProjectionParams.x < 0)
                    i.depthPos.y = 1 - i.depthPos.y;

                // UNITY_OUTPUT_DEPTH(i.depth);
                
                float z = tex2D(_CameraDepthTexture, i.depthPos);
                // #if defined(UNITY_REVERSED_Z)
                //     z = 1.0 - z;
                // #endif
                
            

                // z = unity_CameraInvProjection * z;
               
                fixed4 col = tex2D(_MainTex, i.uv);
                return fixed4(z,z,z, 1.0);
            }
            ENDCG
        }
    }
}
