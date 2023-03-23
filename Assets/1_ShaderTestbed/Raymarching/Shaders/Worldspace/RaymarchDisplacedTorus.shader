Shader "Raymarch/DisplacedTorus"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    	_FresnelColor1("Fresnel Color 1", Color) = (1,1,1,1)
    	_FresnelColor2("Fresnel Color 2", Color) = (1,1,1,1)
    	_FresnelIntensity ("Fresnel Intensity", Range(0, 10)) = 0.0
        _FresnelRamp ("Fresnel Ramp", Range(0, 10)) = 0.0
        _SmoothAmount ("Smooth Amount", Range(0, 0.5)) = 0.1
    	_DisplacementSize("Displacement Size", Range(0, 10)) = 20.0
    	_ScaleFactor("Scale Factor", Float) = 0.25
    	_Speed("Speed", Range(-5, 5)) = 3.0
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
			#define SURF_DIST 1e-6 

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
            float4 _FresnelColor1, _FresnelColor2;
            float _FresnelIntensity, _FresnelRamp;
            float _SmoothAmount;
            float _DisplacementSize, _ScaleFactor, _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
            	o.ro = _WorldSpaceCameraPos;
            	o.hitPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            float sphere(float3 p, float r)
            {
	            float d = length(p) - r;
            	return d;
            }

            float torus(float3 p)
            {
	            //float d = length(float2(length(p.xz) - .4, p.y)) - .1; // torus flat
            	float d = length(float2(length(p.xy) - 1.5, p.z)) - .6; // torus upright

            	return d;
            }

            
            float displacement(float3 p) // inigo quillez
            {
            	float d1 = torus(p);
	            float d2 = sin(_DisplacementSize*p.x)*sin(_DisplacementSize*p.y)*sin(_DisplacementSize*p.z  + _Time.y * _Speed);
            	return d1 + d2;
            }

			float smin(float a, float b, float k) {
			  float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
			  return lerp(b, a, h) - k * h * (1.0 - h);
			}

			float getDist(float3 p)
            {
            	float d1 = torus(p);
            	float d2 = displacement(p);
				return smin(d1, d2, _SmoothAmount) * _ScaleFactor;
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

            float getFresnel(float3 normal, float3 ro)
            {
				float3 viewDir = normalize(ro);
            	
	            float fresnelAmount = 1 - max(0.0, dot(normal, viewDir));
                fresnelAmount = pow(fresnelAmount, _FresnelRamp) * _FresnelIntensity;

            	return fresnelAmount;
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

            float3 getLighting(float3 normalVec)
            {
            	float3 lightDir = _WorldSpaceLightPos0.xyz;
            	float3 lightCol = _LightColor0.rgb;
            	float3 ambient = float3(.1, .1, .1);
	            float3 falloff = max(0.0, dot(normalVec, lightDir));
            	float3 lighting = (falloff * lightCol) + ambient;
            	
            	
            	return lighting;
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
                	float f = getFresnel(n, ro);
                	
                	col.rgb = float3(1.0, 1.0, 1.0) * f * lerp(_FresnelColor1, _FresnelColor2, n);
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
