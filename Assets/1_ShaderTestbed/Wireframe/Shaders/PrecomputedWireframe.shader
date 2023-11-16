Shader "Unlit/PrecomputedWireframe"
{
    Properties
    {
        _WireframeThickness ("Wireframe Thickness", Float) = 1
        _Offset ("Offset", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        
        Blend One One
        LOD 100

        Pass
        {
            Cull Front
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 color : TEXCOORD1;
            };

            float _WireframeThickness, _Offset;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.color = v.color;
                return o;
            }

            float getWireframe(float3 coordColor, float thickness)
            {
                float3 delta = fwidth(coordColor);
                float3 value = step(thickness * delta, coordColor);
                return 1.0 - min(min(value.r, value.g), value.b);

                // float3 delta = fwidth(coordColor);
                // float3 value = step(thickness, coordColor) - step((thickness - _Offset), coordColor);
                // return 1.0 - min(min(value.r, value.g), value.b);

                // does the same thing
                // coordColor.z = 1 - coordColor.x - coordColor.y;
	            // float3 deltas = fwidth(coordColor);
	            // coordColor = smoothstep(deltas, 2 * deltas, coordColor);
	            // float minBary = min(coordColor.x, min(coordColor.y, coordColor.z));
                // return 1.0 - minBary;
            }

            fixed4 frag (v2f i, bool front : SV_isFrontFace) : SV_Target
            {
                // fixed4 col = i.color;
                // fixed4 col = getWireframe(i.color.rgb, front ? _WireframeThickness : _WireframeThickness * 0.75);
                // if (col.a == 0) discard;


                float w1 = getWireframe(i.color.rgb, _WireframeThickness * 0.5 + _Offset);
                float w2 = getWireframe(i.color.rgb, _WireframeThickness * 0.5);
                fixed4 col = w1 - w2;

                
                return front ? col : col * 0.3;
            }
            ENDCG
        }
        Pass
        {
            Cull Back
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 color : TEXCOORD1;
            };

            float _WireframeThickness, _Offset;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.color = v.color;
                return o;
            }

            float getWireframe(float3 coordColor, float thickness)
            {
                float3 delta = fwidth(coordColor);
                float3 value = step(thickness * delta, coordColor);
                return 1.0 - min(min(value.r, value.g), value.b);

                // does the same thing
                // coordColor.z = 1 - coordColor.x - coordColor.y;
	            // float3 deltas = fwidth(coordColor);
	            // coordColor = smoothstep(deltas, 2 * deltas, coordColor);
	            // float minBary = min(coordColor.x, min(coordColor.y, coordColor.z));
                // return 1.0 - minBary;
            }

            fixed4 frag (v2f i, bool front : SV_isFrontFace) : SV_Target
            {
                // fixed4 col = i.color;
                // fixed4 col = getWireframe(i.color.rgb, front ? _WireframeThickness : _WireframeThickness * 0.75);

                float w1 = getWireframe(i.color.rgb, _WireframeThickness + _Offset);
                float w2 = getWireframe(i.color.rgb, _WireframeThickness);
                fixed4 col = w1 - w2;
                
                // if (col.a == 0) discard;
                return front ? col : col * 0.4;
            }
            ENDCG
        }
    }
}
