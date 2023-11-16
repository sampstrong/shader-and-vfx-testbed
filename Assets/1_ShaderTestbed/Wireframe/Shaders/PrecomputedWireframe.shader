Shader "Unlit/PrecomputedWireframe"
{
    Properties
    {
        _WireframeThickness ("Wireframe Thickness", Float) = 1
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

            float _WireframeThickness;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.color = v.color;
                return o;
            }

            float getWireframe(float3 coordColor, float thickness)
            {
                float3 dX = abs(ddx(coordColor));
                float3 dY = abs(ddy(coordColor));
                float3 change = dX + dY;
                float smooth = 0.01;
                float normalizedThickenss = thickness * change;
                // float3 value = step(thickness * change, coordColor);
                float3 value = smoothstep(normalizedThickenss, normalizedThickenss + smooth, coordColor);
                return 1.0 - min(min(value.r, value.g), value.b);
            }

            fixed4 frag (v2f i, bool front : SV_isFrontFace) : SV_Target
            {
                // fixed4 col = i.color;
                fixed4 col = getWireframe(i.color.rgb, front ? _WireframeThickness : _WireframeThickness * 0.75);
                // if (col.a == 0) discard;
                return front ? col : col * 0.4;
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

            float _WireframeThickness;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.color = v.color;
                return o;
            }

            float getWireframe(float3 coordColor, float thickness)
            {
                float3 dX = abs(ddx(coordColor));
                float3 dY = abs(ddy(coordColor));
                float3 change = dX + dY;
                float smooth = 0.01;
                float normalizedThickenss = thickness * change;
                // float3 value = step(thickness * change, coordColor);
                float3 value = smoothstep(normalizedThickenss, normalizedThickenss + smooth, coordColor);
                return 1.0 - min(min(value.r, value.g), value.b);
            }

            fixed4 frag (v2f i, bool front : SV_isFrontFace) : SV_Target
            {
                // fixed4 col = i.color;
                fixed4 col = getWireframe(i.color.rgb, front ? _WireframeThickness : _WireframeThickness * 0.75);
                // if (col.a == 0) discard;
                return front ? col : col * 0.4;
            }
            ENDCG
        }
    }
}