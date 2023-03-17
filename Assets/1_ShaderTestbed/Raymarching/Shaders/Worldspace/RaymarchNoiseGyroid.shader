Shader "Raymarch/NoiseGyroid"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    	_SphereRadius ("Sphere Radius", Range(0.1, 0.5)) = 0.25
    	_NoiseStrength("Noise Strength", Range(0.0, 0.5)) = 0.2
    	_NoiseScale("Noise Scale", Range(0.0, 10.0)) = 8.0
    	_NoiseSpeed("Noise Speed", Range(0.0, 5.0)) = 1.0
    	_NoiseOffset("Noise Offset", Range(0.0, 5.0)) = 3.0
    	_SmoothAmount("Smooth Amount", Range(0.0, 1.0)) = 0.1
    	_GyroidThickness("Gyroid Thickness", Range(0.0, 0.5)) = 0.1
    	_BlobThickness("Blob Thickness", Range(0.0, 0.5)) = 0.1
    	_MapOffest("Map Offset", Range(-1.0, 1.0)) = 0.01
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
            float _SphereRadius;
            float _NoiseStrength, _NoiseScale, _NoiseSpeed, _NoiseOffset;
            float _SmoothAmount;
            float _GyroidThickness, _BlobThickness;
            float _MapOffset;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
            	o.ro = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos,1));
            	o.hitPos = v.vertex;
                return o;
            }

            // 3D noise function (IQ)
			float noise(float3 p)
			{
				p.y += _Time.y * _NoiseSpeed;
            	
				float3 ip=floor(p);
			    p-=ip; 
			    float3 s=float3(7,157,113);
			    float4 h=float4(0.,s.yz,s.y+s.z)+dot(ip,s);
			    p=p*p*(3.-2.*p); 
			    h=lerp(frac(sin(h)*43758.5),frac(sin(h+s.x)*43758.5),p.x);
			    h.xy=lerp(h.xz,h.yw,p.y);
			    return lerp(h.x,h.y,p.z); 
			}

            float sphere(float3 p, float r)
            {
	            float d = length(p) - r;
            	return d;
            }

            float gyroid(float3 p)
            {
            	float rescaleFactor = 25.0;
	            p *= rescaleFactor;

            	float thickness = _GyroidThickness;

            	thickness = thickness + sin(_Time.y) * 0.005 + 0.02; // pulse

				p.y += _Time.y; // animate
            	
            	float gyroid = abs(0.7 * dot(sin(p), cos(p.yzx)) / rescaleFactor) - thickness;
            	
            	return gyroid;
            }

            float mapNoise(float3 p)
			{
            	return sphere(p, _SphereRadius -_NoiseStrength * noise(_NoiseScale*p+_NoiseOffset));
			}

			float smin(float a, float b, float k) {
			  float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
			  return lerp(b, a, h) - k * h * (1.0 - h);
			}

			float getDist(float3 p)
            {
            	float k = _SmoothAmount;
            	// float s = sphere(p, 0.3);
            	// s = abs(s) - 0.01;
            	float m = mapNoise(p);
            	m = abs(m) - _BlobThickness;
            	m += _MapOffset;
            	float g = gyroid(p);
            	float d = smin(m, g, -k);
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
