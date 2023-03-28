Shader "Raymarch/SmoothMaterialsMatcap"
{
    Properties
    {
        _MainTex1 ("Texture 1", 2D) = "white" {}
    	_MainTex2 ("Texture 2", 2D) = "white" {}
    	_SmoothAmount ("Smooth Amount", Range(0, 0.5)) = 0.1
    	_Speed("Speed", Float) = 1.0
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

            sampler2D _MainTex1, _MainTex2;
            float4 _MainTex1_ST, _MainTex2_ST;
            float _SmoothAmount;
            float _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex1);
            	o.ro = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos,1));
            	o.hitPos = v.vertex;
                return o;
            }

            float sphere(float3 p, float3 o, float r)
            {
            	p -= o;
	            float d = length(p) - r;
            	return d;
            }

			float smin(float a, float b, float k) {
			  float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
			  return lerp(b, a, h) - k * h * (1.0 - h);
			}

            // credit inigo quilez
            float2 sminMat( float a, float b, float k )
			{
			    float h = max( k-abs(a-b), 0.0 )/k;
			    float m = h*h*0.5;
			    float s = m*k*(1.0/2.0);
			    return (a<b) ? float2(a-s,m) : float2(b-s,1.0-m);
			}

			float getDist(float3 p)
            {
            	float d = sphere(p, 0.0, 0.4);
				return d;
			}

            float2 getDistMat(float3 p)
            {
            	float2 d;
            	float s1 = sphere(p, float3(0.2, 0.0, 0.0),sin(_Time.y * _Speed) * 0.05 + 0.2);
            	float s2 = sphere(p, float3(-0.2, 0.0, 0.0),-sin(_Time.y * _Speed) * 0.05 + 0.2);

				d = sminMat(s1, s2, _SmoothAmount);
            	
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

            float2 rayMarchMat(float3 ro, float3 rd) {
				float dO = 0;
				float2 dS;
				for (int i = 0; i < MAX_STEPS; i++) {
					float3 p = ro + rd * dO;
					dS = getDistMat(p);
					dO += dS;
					if (dS.x<SURF_DIST || dO>MAX_DIST) break;
				}
				return float2(dO, dS.y);
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

            	// float d = rayMarch(ro, rd);
            	float2 d = rayMarchMat(ro, rd);
            	

                if (d.x < MAX_DIST){
                    float3 p = ro + rd * d.x;
                    float3 n = getNormal(p);

                	float3 eyeVec = getViewVector(i.hitPos, _WorldSpaceCameraPos);
					float2 matcapUV = getMatcap(eyeVec, n);
                	float3 color1 = tex2D(_MainTex1, matcapUV);
                	float3 color2 = tex2D(_MainTex2, matcapUV);
                	
                	col.rgb = lerp(color1, color2, d.y);
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
