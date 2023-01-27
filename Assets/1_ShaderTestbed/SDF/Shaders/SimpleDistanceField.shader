Shader "SDF/SimpleDistanceField"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BorderWidth("Border Width", Float) = 0.5
        _Background("Background", Color) = (0,0,0.25,1)
        _Fill("Fill", Color) = (1,1,1,1)
        _Border("Border", Color) = (0,1,0,1)
        _Offset("Offset", Float) = 0.5
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            // texture info
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;

            // field controls
            float _BorderWidth;
            float _Offset;

            // colors
            float4 _Background;
            float4 _Border;
            float4 _Fill;

            v2f vert (appdata v)
            {
                v2f o;
                // stretch quad to maintain aspect ratio
                //v.vertex.y += _MainTex_TexelSize.x * _MainTex_TexelSize.w;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // flip uvs
                o.uv = 1 - o.uv;
                return o;
            }

            // distance field fragment shader
            fixed4 frag (v2f i) : SV_Target
            {
                // sample distance field;
                float4 sdf = tex2D(_MainTex, i.uv);

                // combine sdf with offset to get distance
                float d = sdf.r + _Offset;

                // if distance from border < _BorderWidth, return _Border
                // otherwise return _Fill in inside shape (-ve dist) or
                // _Background if outside shape (+ve dist)
                if (abs(d) < _BorderWidth)
                    return _Border;
                else if (d < 0)
                    return _Fill;
                else
                    return _Background;
            }
            ENDCG
        }
    }
}
