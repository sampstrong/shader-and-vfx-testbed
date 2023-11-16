Shader "Unlit/PrecomputedWireframe"
{
    Properties
    {
        _WireframeThickness ("Wireframe Thickness", Float) = 1
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

            float getWireframe(float3 coordColor)
            {
                float3 dX = abs(ddx(coordColor));
                float3 dY = abs(ddy(coordColor));
                float3 change = dX + dY;
                float3 value = step(_WireframeThickness * change, coordColor);
                return 1.0 - min(min(value.r, value.g), value.b);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // fixed4 col = i.color;
                fixed4 col = getWireframe(i.color.rgb);
                return col;
            }
            ENDCG
        }
    }
}
