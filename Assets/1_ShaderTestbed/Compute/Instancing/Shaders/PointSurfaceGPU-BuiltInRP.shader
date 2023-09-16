Shader "Graph/PointSurfaceGPU-BuiltInRP"
{
    Properties
    {
        _Smoothness ("Smoothness", Range(0,1)) = 0.5
    }
    SubShader
    {
        CGPROGRAM
        #pragma surface ConfigureSurface Standard fullforwardshadows addshadow
        #pragma instancing_options assumeuniformscaling procedural:ConfigureProcedural
        #pragma target 4.5

        // temporarily defined to edit inside preprocessor directive
        // #define UNITY_PROCEDURAL_INSTANCING_ENABLED
        
        struct Input
        {
            float3 worldPos;
        };
        
        float _Smoothness;
        
        #if defined(UNITY_PROCEDURAL_INSTANCING_ENABLED)
            StructuredBuffer<float3> _Positions;
        #endif

        float _Step;
        
        void ConfigureProcedural() 
        {
            #if defined(UNITY_PROCEDURAL_INSTANCING_ENABLED)
                float3 position = _Positions[unity_InstanceID];

                // reset to identity
                unity_ObjectToWorld = 0.0;

                // sets positions
                unity_ObjectToWorld._m03_m13_m23_m33 = float4(position, 1.0);

                // sets scale
                unity_ObjectToWorld._m00_m11_m22 = _Step;
            #endif
        }
        
        void ConfigureSurface(Input input, inout SurfaceOutputStandard surface)
        {
            surface.Albedo = saturate(input.worldPos * 0.5 + 0.5);
            surface.Smoothness = _Smoothness;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
