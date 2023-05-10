Shader "Raymarch/MatcapBoxFrame"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    	_SmoothAmount ("Smooth Amount", Range(0, 0.2)) = 0.1
    	_BoxB ("Box B", Float) = 0.5
    	_BoxE ("Box E", Float) = 0.01
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
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

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
            float _BoxB, _BoxE;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
            	o.ro = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos,1));
            	o.hitPos = v.vertex;
                return o;
            }

            float sphere(float3 p, float r)
            {
	            float d = length(p) - r;
            	return d;
            }

            float sdBoxFrame( float3 p, float3 b, float e ) // inigo quilez
			{
			       p = abs(p  )-b;
			  float3 q = abs(p+e)-e;
			  return min(min(
			      length(max(float3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
			      length(max(float3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
			      length(max(float3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
			}

			float smin(float a, float b, float k) {
			  float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
			  return lerp(b, a, h) - k * h * (1.0 - h);
			}

			float getDist(float3 p)
            {
            	float d = sdBoxFrame(p, _BoxB, _BoxE);
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

            float2 getMatcap(float3 eye, float3 normal)
            {
	            float3 reflected = reflect(eye, normal);
  				float m = 2.8284271247461903 * sqrt(reflected.z + 1.0);
  				return reflected.xy / m + 0.5;
            }

            float3 getViewVector(float3 pos, float3 camPos)
            {
	            float3 viewVec = normalize(camPos - pos);

            	return viewVec;
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

                	float3 eyeVec = getViewVector(i.hitPos, _WorldSpaceCameraPos);
					float2 matcapUV = getMatcap(eyeVec, n);
                	float3 color = tex2D(_MainTex, matcapUV);
                	
                	col.rgb = color;
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
