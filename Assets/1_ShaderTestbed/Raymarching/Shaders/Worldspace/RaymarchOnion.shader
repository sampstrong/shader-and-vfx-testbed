Shader "Raymarch/Onion"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
            	o.ro = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos,1));
            	o.hitPos = v.vertex;
                return o;
            }

            float ballGyroid(float3 p)
            {
            	float rescaleFactor = 25.0;
	            p *= rescaleFactor;

            	float thickness = 0.001;

            	thickness = thickness + sin(_Time.y) * 0.005 + 0.02; // pulse

				p.y += _Time.y; // animate
            	
            	float gyroid = abs(0.7 * dot(sin(p), cos(p.yzx)) / rescaleFactor) - thickness;
            	
            	return gyroid;
            }

            float sdBox( float3 p, float3 b )
			{
				p.z -= 0.5;
            	
			  	float3 q = abs(p) - b;
			  	return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
			}

            float opOnion(float sdf, float thickness)
			{
			    return abs(sdf)-thickness;
			}

            float smin(float a, float b, float k)
            {
	            float h = clamp(0.5 + 0.5 * (b-a)/k, 0.0, 1.0);
            	return lerp(b, a, h) - k * h * (1.0 - h);
            }
            
			float getDist(float3 p)
            {
				float ball = length(p) - .35;
            	ball = abs(ball) - 0.01;
				float g = ballGyroid(p);

            	float k = 0.01;

            	// ball = max(ball, g); // boolean intersection
            	// ball = smin(ball, g, -k); // negative k value turns smin into smax

            	ball = opOnion(ball - .025, 0.008);
            	ball = opOnion(ball -.025, 0.008);
            	ball = opOnion(ball -.025, 0.008);
            	

            	float box = sdBox(p, 0.5); // section for debugging
            	ball = max(ball, box);

            	// ball = smin(ball, g, -k);
 
            	
				return ball;
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

            float3 getViewVector(float3 pos, float3 camPos)
            {
	            float3 viewVec = normalize(camPos - pos);

            	return viewVec;
            }

            float3 getLighting(float3 normalVec)
            {
            	float3 lightDir = _WorldSpaceLightPos0.xyz;
            	float3 lightCol = _LightColor0.rgb;
            	float3 ambient = float3(.1, .1, .1);
	            float3 falloff = max(0.0, dot(normalVec, lightDir));
            	float3 lighting = (falloff * lightCol) + ambient;
            	
            	return lighting;
            }

            float2 getMatcap(float3 eye, float3 normal)
            {
	            float3 reflected = reflect(eye, normal);
  				float m = 2.8284271247461903 * sqrt(reflected.z + 1.0);
  				return reflected.xy / m + 0.5;
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
                	float3 l = getLighting(n);

                	float3 eyeVec = getViewVector(i.hitPos, _WorldSpaceCameraPos);
					float2 matcapUV = getMatcap(eyeVec, n);
                	float3 color = tex2D(_MainTex, matcapUV);
                	
                	col.rgb = l;
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
