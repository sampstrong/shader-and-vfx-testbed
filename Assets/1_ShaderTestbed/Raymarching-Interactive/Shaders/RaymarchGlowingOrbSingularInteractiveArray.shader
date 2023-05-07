Shader "Raymarch/GlowingOrbSingularInteractiveArray"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    	_BaseColor ("Base Color", Color) = (0.0, 0.4, 0.2, 1.0)
    	[HDR] _GlowColor ("Glow Color", Color) = (1,0.3,0.3,1)
    	_NoiseScale ("Noise Scale", Float) = 1
    	_SmoothAmount ("Smooth Amount", Range(0, 0.2)) = 0.1
    	_FresnelIntensity ("Fresnel Intensity", Range(0, 10)) = 0.0
        _FresnelRamp ("Fresnel Ramp", Range(0, 10)) = 0.0
    	_GyroidScale ("Gyroid Scale", Float) = 25.0
    	_GyroidThickness ("Gyroid Thickness", Range(0.0, 0.1)) = 0.05
    	_Gloss ("Gloss", Range(1, 100)) = 50
    	_ScatteringRadius ("Scattering Radius", Float) = 0.4
    	
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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _SmoothAmount;
            float _FresnelRamp, _FresnelIntensity;
            fixed4 _BaseColor, _GlowColor;
            float _NoiseScale, _GyroidScale, _GyroidThickness;
            float _Gloss;
            float _ScatteringRadius;
            float _TestScale = 0.4;

            uniform float4 _Position[1];
            uniform float _Radius[1];
            uniform float4x4 _Rotation[1];

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
            	o.ro = _WorldSpaceCameraPos; // world space
            	o.hitPos = mul(unity_ObjectToWorld, v.vertex); // world space
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
            
            float sphere(float3 p, float r, float3 worldPos, float4x4 rotMatrix)
            {
				p -= worldPos;
            	p = mul(p, rotMatrix);
            	
	            float d = length(p) - r;
            	return d;
            }

            float gyroid(float3 p, float3 worldPos, float4x4 rotMatrix)
            {
				p -= worldPos;
            	p = mul(p, rotMatrix);
            	
            	float rescaleFactor = _GyroidScale;
	            p *= rescaleFactor;
            	float thickness = 0.03;

				p.y += _Time.y; // animate
            	
            	float gyroid = abs(0.7 * dot(sin(p), cos(p.yzx)) / rescaleFactor) - thickness;
            	
            	return gyroid;
            }

            float ballGyroidHollow(float3 p, float r, float3 worldPos, float4x4 rotMatrix)
            {
	            // sphere shell gyroid
            	float s = sphere(p, r, worldPos, rotMatrix);
            	s = abs(s) - _GyroidThickness;
				float g = gyroid(p, worldPos, rotMatrix);
            	float k = 0.1;
            	s = smin(s, g, -k);

            	return s;
            }

            float ballGyroidSolid(float3 p, float r, float3 worldPos, float4x4 rotMatrix)
            {
	            // sphere shell gyroid
            	float s = sphere(p, r, worldPos, rotMatrix);
				float g = gyroid(p, worldPos, rotMatrix);
            	float k = 0.1;
            	s = smin(s, g, -k);

            	return s;
            }
            

			float orb(float3 p, float r, float3 worldPos, float4x4 rotMatrix)
            {
	            // main sphere
            	float d = sphere(p, r, worldPos, rotMatrix);

            	// gyroid ridges
            	float s = ballGyroidHollow(p, r, worldPos, rotMatrix);

            	// combined
            	float k = 0.1;
				d = smin(s, d, k);

            	return d;
            }

            
                        
			// ------ raymarching ------

			float getDist(float3 p)
            {
            	// p -= _Position;
				// p = mul(p, _Rotation);
            	
				float d = orb(p, _Radius[0], _Position[0], _Rotation[0]);
            	
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


            float subSurfaceScattering(float3 p, float3 rd)
            {
            	float2 uv = dot(p, rd); // uv based on ray direction
                float cds = dot(uv, uv); // center distance squared
                
                float sss = smoothstep(0.2, 0.0, cds); // sub-surface scattering
                sss = 1.0 - sss;
                sss = min(sss, 2.0);
                float b = ballGyroidSolid(p, _Radius[0] * 1.5, 0, _Rotation[0]);
                sss *= smoothstep(-0.03, 0.0, b);

            	return sss;
            }



            fixed4 frag (v2f i) : SV_Target
            {
                float3 ro = i.ro; 
                float3 rd = normalize(i.hitPos - ro);

            	
                fixed4 col = 0;

            	float d = rayMarch(ro, rd);

                if (d < MAX_DIST)
                {
                    float3 p = ro + rd * d;
                	
                    float3 n = getNormal(p);
					float3 l = applyLighting(n, p);

                	// update transforms
                	p -= _Position[0];
                	float3 pRot = mul(p, _Rotation[0]);
                	
                	
					// sub surface scattering
					float sss = subSurfaceScattering(p, rd);
                	
                    col.rgb = l * _BaseColor;
                	col.rgb += sss * _GlowColor;

                	// surface dots
                	float noise = 1.0 - clamp(snoise(pRot * _NoiseScale), 0.6, 0.8);
                	noise = lerp(noise, 0.5, clamp(1.0 - _GlowColor.r * sss, 0.0, 1.0));
                	col.rgb *= noise;
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
