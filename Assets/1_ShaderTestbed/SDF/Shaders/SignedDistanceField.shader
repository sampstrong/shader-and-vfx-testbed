Shader "SDF/SignedDistanceField"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BorderWidth("Border Width", Float) = 0.5
        _Background("Background", Color) = (0,0,0.25,1)
        _Fill("Fill", Color) = (1,1,1,1)
        _Border("Border", Color) = (0,1,0,1)
        _Offset("Offset", Float) = 0.5
        _Grid("Grid", Float) = 0
        [IntRange]_Mode("Mode", Range(1, 6)) = 6
        _DistanceVisualizationScale("Distance Visualization Scale", Float) = 0
        
        
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
            float _Mode;
            float _Grid;
            float _DistanceVisualizationScale;

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

            //takes a pixel colour from the sdf texture and returns the output colour
            float4 sdffunc(float4 sdf)
            {
                float4 res = _Background;
            
                if (_Mode == 1) //Raw
                {
                    return sdf;
                }
                else if (_Mode == 2) //Distance
                {
                    //render colour for distance for valid pixels
                    float d = sdf.r*_DistanceVisualizationScale;
                    res.r = saturate(d);
                    res.g = saturate(-d);
                    res.b = 0;
                }
                else if (_Mode == 3) //Gradient (ignore me for now!)
                {
                    res.rg = abs(sdf.gb);
                    res.b = 0;
                }
                else if (_Mode == 4) //Solid
                {
                    float d = sdf.r + _Offset;
                    if (d < 0)
                        res = _Fill;
                }
                else if (_Mode == 5) //Border
                {
                    float d = sdf.r + _Offset;
                    if (abs(d) < _BorderWidth)
                    {
                        res = _Border;
                    }
                }
                else if (_Mode == 6) //SolidWithBorder
                {
                    float d = sdf.r + _Offset;
                    if (abs(d) < _BorderWidth)
                    {
                        res = _Border;
                    }
                    else if (d < 0)
                    {
                        res = _Fill;
                    }
                }
            
                return res;
            }

            // distance field fragment shader
            fixed4 frag (v2f i) : SV_Target
            {
                //sample distance field
                float4 sdf = tex2D(_MainTex, i.uv);
                fixed4 res = sdffunc(sdf);

                //blend in grid
                if (_Grid > 0)
                {
                    float2 gridness = cos(3.1415926 * i.uv * _MainTex_TexelSize.zw);
                    gridness = abs(gridness);
                    gridness = pow(gridness,100);
                    gridness *= _Grid;
                    res = lerp(res, fixed4(0, 0, 0, 1), max(gridness.x,gridness.y));
                }

                return res;
            }
            ENDCG
        }
    }
}
