Shader "Raymarch/GlowingOrbInteractive"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    	_BaseColor ("Base Color", Color) = (0.25, 0.44, 0.6, 1.0)
    	[HDR] _GlowColor ("Glow Color", Color) = (1.5,0.0,0.0,1)
    	_NoiseScale ("Noise Scale", Float) = 1
    	_SmoothAmount ("Smooth Amount", Range(0, 0.2)) = 0.1
    	_GyroidScale ("Gyroid Scale", Float) = 25.0
    	_GyroidThickness ("Gyroid Thickness", Range(0.0, 0.1)) = 0.05
    	_Gloss ("Gloss", Range(1, 100)) = 50
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
            #include "Assets/1_ShaderTestbed/cginc/noise.cginc"

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

            

			// ------ global variables ------
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _BaseColor, _GlowColor;
            
            float _SmoothAmount;
            float _NoiseScale, _GyroidScale, _GyroidThickness;
            float _Gloss;

            uniform int _NumberOfSpheres;
            uniform int _SphereID[20];
            uniform float4 _Positions[20];
            uniform float4 _Scales[20];


            
            // ------ vertex shader ------

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
            	o.ro = _WorldSpaceCameraPos;
            	o.hitPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }


            // ------ lighting ------
            
            float3 getDiffuseLight(float3 normal)
            {
                float3 lightDir = _WorldSpaceLightPos0.xyz;
                float3 lightColor = _LightColor0.rgb;
                float lightFalloff = max(0, dot(lightDir, normal));
                float3 directDiffuseLight = lightColor * lightFalloff;

                return directDiffuseLight;
            }

            float3 getAmbientLight(float3 normal)
            {
                float3 a = ShadeSH9(float4(normal, 1.0));

                return a;
            }

            float3 getSpecularLight(float3 normal, float3 worldPos)
            {
                float3 camPos = _WorldSpaceCameraPos;
                float3 fragToCam = camPos - worldPos;
                float3 viewDir = normalize(fragToCam);
                float3 viewReflect = reflect(-viewDir, normal);
                
                float specularFalloff = max(0, dot(viewReflect, _WorldSpaceLightPos0.xyz));
                specularFalloff = pow(specularFalloff, _Gloss);

                return specularFalloff;
            }

            float3 applyLighting(float3 normal, float3 worldPos)
            {
	            float3 diffuse = getDiffuseLight(normal);
                float3 ambient = getAmbientLight(normal);
                float3 specular = getSpecularLight(normal, worldPos);
                float3 directSpecular = specular * _LightColor0.rgb;
                float3 diffuseLight = ambient + diffuse;
                float3 finalSurfaceColor = diffuseLight * _BaseColor.rgb + directSpecular;

            	return finalSurfaceColor;
            }



            // ------ transformations ------
            
            float2x2 rotate2d(float _angle)
			{
			    return float2x2(cos(_angle),-sin(_angle),
			                    sin(_angle),cos(_angle));
			}

            float3 makeRotation(float3 p, float speed)
            {
                float2x2 rotation = rotate2d(_Time.y * speed);
                p.xz = mul(rotation, p.xz);

            	return p;
            }


            
            // ------ distance functions ------

            float smin(float a, float b, float k) {
			  float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
			  return lerp(b, a, h) - k * h * (1.0 - h);
			}
            
            float sphere(float3 p, float r, float3 offset)
            {
				p -= offset;
            	
	            float d = length(p) - r;
            	return d;
            }

            float gyroid(float3 p, float3 offset)
            {
				p -= offset;
            	
            	float rescaleFactor = _GyroidScale;
	            p *= rescaleFactor;
            	p.y += _Time.y; // animation
            	
            	float thickness = 0.03; 
            	float gyroid = abs(0.7 * dot(sin(p), cos(p.yzx)) / rescaleFactor) - thickness;
            	
            	return gyroid;
            }

            float ballGyroid(float3 p, float r, float3 offset)
            {
            	float b = length(p) - r;
            	b = abs(b) - _GyroidThickness;
				float g = gyroid(p, offset);
            	float k = 0.1;
            	b = smin(b, g, -k);

            	return b;
            }

            

            float orb(float3 p, float r, float3 offset)
            {
            	// update position
				// p -= offset;
            	
            	// main sphere
            	float d = sphere(p, r, offset);

				// sphere-gyroid ridges
				float b = ballGyroid(p, r, offset);

            	// combined
            	float k = 0.1;
            	d = smin(b, d, k);

            	return d;
            }



            // ------ raymarching ------



			float getDist(float3 p)
            {
            	float d = 0.0;
            	float lastDist = 0.0;

            	if (_NumberOfSpheres <= 0) return 1.0;
            	
            	for (int i = 0; i < _NumberOfSpheres; i++)
            	{
            		float s = sphere(p, _Scales[i], _Positions[i].xyz);
					if (i == 0)
					{
						lastDist = s;
						continue;
					}

            		d = smin(lastDist, s, _SmoothAmount);
            		lastDist = d;
            	}
            	
				return d;
			}

            int getMat(float3 p)
            {
            	float d = 0.0;
            	float lastDist = 0.0;

            	if (_NumberOfSpheres <= 0) return 1.0;

            	int mat;
            	
            	for (int i = 0; i < _NumberOfSpheres; i++)
            	{
            		float s = sphere(p, _Scales[i], _Positions[i].xyz);
					if (i == 0)
					{
						lastDist = s;
						continue;
					}

            		d = smin(lastDist, s, _SmoothAmount);
            		lastDist = d;

            		mat = i;
            	}

            	// return the index of the object at this position
				return mat;
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



            // ------ fragment shader ------

            fixed4 frag (v2f i) : SV_Target
            {
                float3 ro = i.ro; 
                float3 rd = normalize(i.hitPos - ro);

                fixed4 col = 0;

            	float d = rayMarch(ro, rd);

                if (d < MAX_DIST)
                {
                    float3 p = ro + rd * d;

					int mat = getMat(p);
                	for (int i = 0; i < _NumberOfSpheres; i++)
                	{
                		if (mat == i)
                		{
                			float adjustedP = p - _Positions[i];

                			float3 n = getNormal(p);
							float3 l = applyLighting(n, p);
                			
                			// inner glow
                			float2 uv = dot(adjustedP, rd); // uv based on ray direction
                			float cds = dot(uv, uv); // center distance squared
		
                			// sub-surface scattering
                			float sss = smoothstep(0.2, 0.0, cds); 
                			sss = 1.0 - sss;
                			sss = min(sss, 2.0);
		
                			// // gyroid structure blocking light
                			// for (int i = 0; i < _NumberOfSpheres; i++)
                			// {
                			// 	float b = ballGyroid(p, 0.4, _Positions[i].xyz);
                			// 	sss *= smoothstep(-0.03, 0.0, b);
                			// }
		
		
                			// colors
                			col.rgb = l * _BaseColor;
                			col.rgb += sss * _GlowColor;
		
                			// surface dots/noise
                			float noise = 1.0 - clamp(snoise(p * _NoiseScale), 0.6, 0.8);
                			noise = lerp(noise, 0.5, clamp(1.0 - _GlowColor.r * sss, 0.0, 1.0));
                			col.rgb *= noise;
                		}
                	}
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
