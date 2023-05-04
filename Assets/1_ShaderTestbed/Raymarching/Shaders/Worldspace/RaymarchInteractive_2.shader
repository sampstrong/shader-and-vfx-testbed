Shader "Raymarch/Interactive_2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    	_SmoothAmount ("Smooth Amount", Range(0, 0.4)) = 0.1
    	
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" } 
        LOD 100

        Pass
        {
            CGPROGRAM
// Upgrade NOTE: excluded shader from DX11, OpenGL ES 2.0 because it uses unsized arrays
#pragma exclude_renderers d3d11 gles
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
            	float4 screenPos : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _SmoothAmount;
            uniform int _NumberOfSpheres;
            uniform float4 _Positions[20];
            uniform float4 _Scales[20];
            sampler2D _CameraOpaqueTexture;
            

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
            	o.ro = _WorldSpaceCameraPos;
            	o.hitPos = mul(unity_ObjectToWorld, v.vertex);
            	o.screenPos = ComputeScreenPos(v.vertex) * 0.5 + 0.5;
                return o;
            }

            float sphere(float3 p, float r, float3 offset)
            {
            	p -= offset;
	            float d = length(p) - r;
            	return d;
            }

			float smin(float a, float b, float k) {
			  float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
			  return lerp(b, a, h) - k * h * (1.0 - h);
			}

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
                float3 ro = i.ro; 
                float3 rd = normalize(i.hitPos - ro); //normalize(float3(uv.x, uv.y, 1.0));

            	// fixed4 screenColor = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_CameraOpaqueTexture, UNITY_PROJ_COORD(i.screenPos));
            	// fixed3 screenColor = tex2D(_CameraOpaqueTexture, abs(rd)).rgb;
            	// screenColor *= float3(0.2, 0.9, 0.3);
            	
                fixed4 col = 0;

            	float d = rayMarch(ro, rd);

                if (d < MAX_DIST){
                    float3 p = ro + rd * d;
                    float3 n = getNormal(p);
                	float3 r = reflect(rd, n);
                	n = n * 0.5 + 0.5;

                	float3 newScreenPos = i.screenPos * n;

                	float3 reflTex = tex2D(_CameraOpaqueTexture, newScreenPos).rgb;
                	reflTex *= float3(0.2, 0.9, 0.3);
                	
                	col.rgb = reflTex;
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