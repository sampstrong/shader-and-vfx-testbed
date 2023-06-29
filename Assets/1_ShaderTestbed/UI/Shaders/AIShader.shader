Shader "UI/AIShader"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)

        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

        _ColorMask ("Color Mask", Float) = 15

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
        
        [Space(20)]
        [Header(Custom Properties)]
        _BackgroundColor ("Background Color", Color) = (0,0,0,0)
        _Frequency ("Frequency", Float) = 1.0
        _Speed ("Speed", Float) = 1.0
        _LineThickness ("Line Thickness", Float) = 0.01
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend One OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass
        {
            Name "Default"
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float2 texcoord  : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                half4  mask : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;
            float _UIMaskSoftnessX;
            float _UIMaskSoftnessY;

            // custom properties
            float3 _BackgroundColor;
            float _Frequency;
            float _Speed;
            float _LineThickness;

            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                float4 vPosition = UnityObjectToClipPos(v.vertex);
                OUT.worldPosition = v.vertex;
                OUT.vertex = vPosition;

                float2 pixelSize = vPosition.w;
                pixelSize /= float2(1, 1) * abs(mul((float2x2)UNITY_MATRIX_P, _ScreenParams.xy));

                float4 clampedRect = clamp(_ClipRect, -2e10, 2e10);
                float2 maskUV = (v.vertex.xy - clampedRect.xy) / (clampedRect.zw - clampedRect.xy);
                OUT.texcoord = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
                OUT.mask = half4(v.vertex.xy * 2 - clampedRect.xy - clampedRect.zw, 0.25 / (0.25 * half2(_UIMaskSoftnessX, _UIMaskSoftnessY) + abs(pixelSize.xy)));

                OUT.color = v.color * _Color;
                return OUT;
            }

            float3 wave(float3 color, float2 uv, float xOffset, float freqOffset, float ampOffset, float thicknessOffset)
            {
                // wave parameters
                float waveThreshold = sin((uv.x + xOffset) * (_Frequency + freqOffset) + _Time.y * _Speed) / (10 + ampOffset) + 0.5;
                float waveTop = 1.0 - step(waveThreshold, uv.y);
                float waveBottom = step(waveThreshold - (_LineThickness + thicknessOffset), uv.y);

                // top line
                float3 waveColor = 1.0;
                waveColor *= waveTop;
                waveColor *= waveBottom;
                waveColor *= color;

                // bottom gradient
                float3 bottomFill = lerp(color, 0, 1.0 - uv.y / 3.0);
                waveColor = max(waveColor, bottomFill * (1.0 - waveBottom));

                return waveColor;
            }

            fixed4 frag(v2f IN) : SV_Target
            {
                half4 outputColor = IN.color * (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd);

                // create our output color
                float3 effectColor = outputColor.rgb;

                // create custom color gradients
                float3 color1 = float3(IN.texcoord.x / 2.0, 0.0, IN.texcoord.y);
                float3 color2 = float3(IN.texcoord.x, IN.texcoord.y, 0.0);
                float3 color3 = float3(IN.texcoord.x, 0.0, IN.texcoord.y);
                
                // waves
                float3 wave1 = wave(color1, IN.texcoord, 0, 0, 0, 0);
                float3 wave2 = wave(color2, IN.texcoord, 0.1, 1, -2, 0);
                // float3 wave3 = wave(color3, IN.texcoord, 0.2, 0, 2, 0);

                effectColor = max(wave1, wave2);
                

                effectColor = max(effectColor, _BackgroundColor);

                // multiply with output
                outputColor.rgb *= effectColor;


                // masking
                #ifdef UNITY_UI_CLIP_RECT
                half2 m = saturate((_ClipRect.zw - _ClipRect.xy - abs(IN.mask.xy)) * IN.mask.zw);
                color.a *= m.x * m.y;
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                clip (color.a - 0.001);
                #endif

                outputColor.rgb *= outputColor.a;
                return outputColor;
            }
        ENDCG
        }
    }
}
