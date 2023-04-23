Shader "Unlit/NoodleRegular"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BaseColor ("BaseColor", Color) = (1,1,1,1)
        [HDR] _Light1 ("Light1", Color) = (1,1,1,1)
        [HDR] _Light2 ("Light2", Color) = (1,1,1,1)
        [HDR] _Light3 ("Light3", Color) = (1,1,1,1)
        _Speed ("Speed", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull Off

        Pass
        {
            CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members ogPos)
#pragma exclude_renderers d3d11
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float displacement1 : TEXCOORD2;
                float displacement2 : TEXCOORD3;
                float displacement3 : TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Speed;
            float3 _BaseColor, _Light1, _Light2, _Light3;

            float2x2 rotate2d(float _angle)
            {
                return float2x2(cos(_angle),-sin(_angle),
                            sin(_angle),cos(_angle));
            }

            float blob(float3 pos, float size, float amount, float speed)
            {
                float value1 = ((_Time.y * speed) % 30.0) - 20.0;
                float value2 = value1 + size / 2.0;
                float value3 = value1 + size / 2.0;
                float value4 = value1 + size;
                float displacement = (smoothstep(value1, value2, pos.z) - smoothstep(value3, value4, pos.z)) * amount;
                return displacement;
            }

            v2f vert (appdata v)
            {
                v2f o;
                // v.vertex.xyz += (sin(v.vertex.z) * 0.5 + 0.7) * v.normal;

                // displacement 1
                o.displacement1 = blob(v.vertex, 5.0, 1.0, _Speed);
                v.vertex.xyz += o.displacement1 * v.normal;

                // displacement 2
                o.displacement2 = sin(v.vertex.z * 0.75 + _Time.y * -_Speed / 5.0) * sin(v.vertex.z * 0.2) * 0.5 + 0.5;
                v.vertex.xyz += o.displacement2 * v.normal;

                // displacement 3
                o.displacement3 = blob(v.vertex, 3.0, 0.4, _Speed / 2.0);
                v.vertex.xyz += o.displacement3 * v.normal;

                // rotation
                float2x2 rotationMatrixVertical = rotate2d(sin(-v.uv.y * 3.0) * cos(_Time.y * 0.15));
                v.vertex.yz = mul(rotationMatrixVertical, v.vertex.yz);
                float2x2 rotationMatrixHorizontal = rotate2d(v.uv.y * sin(_Time.y * 0.1));
                v.vertex.xz = mul(rotationMatrixHorizontal, v.vertex.xz);
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                

                
                
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // fixed4 col = tex2D(_MainTex, i.uv);
                float dist1 = i.displacement1;
                float dist2 = i.displacement2;
                float dist3 = i.displacement3;
                float3 color1 = lerp(_BaseColor, _Light1, dist1);
                float3 color2 = lerp(_BaseColor, _Light2, dist2);
                float3 color3 = lerp(_BaseColor, _Light3, dist3);
                float3 combinedColor = max(color3, max(color1, color2));
                return fixed4(combinedColor, 1.0);
            }
            ENDCG
        }
    }
}
