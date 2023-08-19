Shader "Unlit/Decal_01"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 objectPos : POSITION;
            };

            struct v2f
            {
                float4 clipPos : SV_POSITION;
                float4 screenPos : TEXCOORD0;
                float3 ray : TEXCOORD1;
            };

            sampler2D _CameraDepthTexture;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;

                // transform from object to clip pos
                float3 worldPos = mul(unity_ObjectToWorld, float4(v.objectPos));
                o.clipPos = UnityWorldToClipPos(worldPos);

                // calculate the ray between the camera and the vertex
                o.ray = worldPos - _WorldSpaceCameraPos;

                // get screen pos
                o.screenPos = ComputeScreenPos(o.clipPos);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // create screen uvs
                float2 screenUv = i.screenPos.xy / i.screenPos.w;
                
                // sample depth texture and convert to linear values
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, screenUv);
                depth = Linear01Depth(depth) * _ProjectionParams.z;

                // adjust ray to account for parallel distance vs euclidian distance
                float3 worldRay = normalize(i.ray);
                worldRay /= dot(worldRay, -UNITY_MATRIX_V[2].xyz);

                // construct world space positions
                float3 worldPos = _WorldSpaceCameraPos + worldRay * depth;

                // convert to object space positions
                float3 objectPos = mul(unity_WorldToObject, float4(worldPos, 1.0)).xyz;

                // discard pixels with position values outside of the cube +-0.5
                clip(0.5 - abs(objectPos));

                // visualize object position
                // fixed4 col = fixed4(objectPos, 1.0);

                // use object position as uvs for texture
                float2 texUvs = objectPos.xz + 0.5;
                
                fixed4 col = tex2D(_MainTex, texUvs);
                
                return col;
            }
            ENDCG
        }
    }
}
