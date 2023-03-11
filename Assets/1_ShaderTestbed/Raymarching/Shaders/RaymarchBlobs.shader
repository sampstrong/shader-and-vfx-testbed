Shader "Unlit/RaymarchBlobs"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    	_SmoothAmount ("Smooth Amount", Range(0, 0.2)) = 0.1
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

			#define MAX_STEPS 100
			#define MAX_DIST 100
			#define SURF_DIST 1e-3 // 0.001

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            	float3 ro : TEXCOORD1;
            	float3 hitPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _SmoothAmount;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
            	o.ro = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos,1));
            	o.hitPos = v.vertex;
                return o;
            }

            float sphere1(float3 p)
            {
				float yOffset = sin(_Time.y) * 0.3;
            	float xOffset = cos(_Time.y * 0.4) * 0.15;
            	float zOffset = sin(_Time.y * 0.2) * 0.15;
            	float3 offset = float3(xOffset, yOffset, zOffset);

            	p += offset;
            	
            	float radius = (sin(_Time.y) * 0.3 + 0.7) * 0.2;
	            float d = length(p) - radius;

            	return d;
            }

            float sphere2(float3 p)
            {
				float yOffset = cos(_Time.y * 0.1) * 0.25;
            	float xOffset = sin(_Time.y * 0.2) * 0.25;
            	float zOffset = cos(_Time.y * 0.5) * 0.2;
            	float3 offset = float3(xOffset, yOffset, zOffset);

            	p += offset;
            	
            	float radius = (cos(_Time.y) * 0.2 + 0.7) * 0.25;
	            float d = length(p) - radius;

            	return d;
            }

            float sphere3(float3 p)
            {
				float yOffset = cos(_Time.y * 0.15) * 0.25;
            	float xOffset = sin(_Time.y * 0.7) * 0.05;
            	float zOffset = sin(_Time.y * 0.1) * 0.1;
            	float3 offset = float3(xOffset, yOffset, zOffset);

            	p += offset;
            	
            	float radius = (sin(_Time.y) * 0.3 + 0.7) * 0.25;
	            float d = length(p) - radius;

            	return d;
            }

            float sphere4(float3 p)
            {
				float yOffset = sin(_Time.y * 0.1) * 0.05;
            	float xOffset = sin(_Time.y * 0.2) * 0.25;
            	float zOffset = sin(_Time.y * 0.4) * 0.2;
            	float3 offset = float3(xOffset, yOffset, zOffset);

            	p += offset;
            	
            	float radius = (cos(_Time.y) * 0.2 + 0.7) * 0.15;
	            float d = length(p) - radius;

            	return d;
            }

            float sphere5(float3 p)
            {
				float yOffset = cos(_Time.y * 0.2) * 0.15;
            	float xOffset = cos(_Time.y * 0.6) * 0.25;
            	float zOffset = cos(_Time.y * 0.2) * 0.15;
            	float3 offset = float3(xOffset, yOffset, zOffset);

            	p += offset;
            	
            	float radius = (sin(_Time.y) * 0.2 + 0.7) * 0.1;
	            float d = length(p) - radius;

            	return d;
            }

			float smin(float a, float b, float k) {
			  float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
			  return lerp(b, a, h) - k * h * (1.0 - h);
			}

			float getDist(float3 p)
            {
				//float k = 0.1;
            	
				float s1 = sphere1(p);
            	float s2 = sphere2(p);
            	float s3 = sphere3(p);
            	float s4 = sphere4(p);
            	float s5 = sphere5(p);

				float smin1 = smin(s1, s2, _SmoothAmount);
            	float smin2 = smin(smin1, s3, _SmoothAmount);
            	float smin3 = smin(smin2, s4, _SmoothAmount);
            	float d = smin(smin3, s5, _SmoothAmount);
            	
				return d;
			}

			float rayMarch(float3 ro, float3 rd) {
				float dO = 0;
				float dS;
				for (int i = 0; i < MAX_STEPS; i++) {
					float3 p = ro + rd * dO;
					dS = getDist(p);
					dO += dS;
					if (dS<SURF_DIST || dO>MAX_DIST) break;
				}
				return dO;
			}

			float3 getNormal(float3 p) {
				float2 e = float2(1e-2, 0);

				float3 n = getDist(p) - float3(
					getDist(p-e.xyy),
					getDist(p-e.yxy),
					getDist(p-e.yyx)
				);

				return normalize(n);
			}

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv - .5;

                // ray origin / virtual camera
                float3 ro = i.ro; //float3(0,0,-3);

                // ray direction
                float3 rd = normalize(i.hitPos - ro); //normalize(float3(uv.x, uv.y, 1.0));
            	
                fixed4 col = 0;

            	float d = rayMarch(ro, rd);

                if (d < MAX_DIST){
                    float3 p = ro + rd * d;
                    float3 n = getNormal(p);
                	n = n * 0.5 + 0.5;
                	col.rgb = n;
                }
                else
                {
	                discard;
                }
                
                return col;
            }
            ENDCG
        }
    }
}
