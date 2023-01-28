Shader "Raymarch/RaymarchShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            uniform float4x4 _CamFrustum, _CamToWorld;
            uniform float _maxDistance;
            uniform float4 _sphere1;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 ray : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                half index = v.vertex.z;
                v.vertex.z = 0;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                o.ray = _CamFrustum[(int)index].xyz;

                o.ray /= abs(o.ray.z);

                o.ray = mul(_CamToWorld, o.ray);
                
                return o;
            }

            float sdSphere(float3 p, float s) // p = position, s = scale/radius
            {
                return length(p) - s;
            }
            
            float distanceField(float3 p)
            {
                float Sphere1 = sdSphere(p - _sphere1.xyz, _sphere1.w);
                return Sphere1;
            }

            fixed4 raymarching(float3 ro, float3 rd) // ro = ray origin, rd = ray direction
            {
                fixed4 result = fixed4(1,1,1,1);
                const int max_iteration = 64;
                float t = 0; // distance travelled along the ray direction

                for (int i = 0; i < max_iteration; i++)
                {
                    // optimize shader to automatically render the environment beyond our max distance set in inspector
                    if (t > _maxDistance) 
                    {
                        // Render Environment
                        result = fixed4(rd, 1);
                        break;
                    }

                    float3 p = ro + rd * t; // p = position
                    // Check for hit in distance field
                    float d = distanceField(p);
                    if (d < 0.01) // if we have hit something
                    {
                        // shading
                        result = fixed4(1,1,1,1);
                        break;
                    }
                    t += d;
                }
                
                return result;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 rayDirection = normalize(i.ray.xyz);
                float3 rayOrigin = _WorldSpaceCameraPos;
                fixed4 result = raymarching(rayOrigin, rayDirection);
                return result;
            }
            ENDCG
        }
    }
}
