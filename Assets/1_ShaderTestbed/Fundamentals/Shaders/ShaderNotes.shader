Shader "Unlit/ShaderNotes"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            
            // pragmas define what functions the shader must include
            #pragma vertex vert
            #pragma fragment frag

            // import libraries with .cginc files
            #include "UnityCG.cginc"

            struct appdata
            {
                // the local/object space position for each vertex
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 uv_normal : TEXCOORD1;
                float3 vertex_world : TEXCOORD2;
                
                // these 3 are used to create the TBN matrix
                // which is used for normal mapping
                float3 normal_world : TEXCOORD3;
                float4 tangent_world : TEXCOORD4;
                float4 binormal_world : TEXCOORD5;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NormalMap;
            float4 _NormalMap_ST;

            v2f vert (appdata v)
            {
                v2f o;
                
                // initialize output to zero
                // removes "output value 'vert' is not completely initialized" warning
                UNITY_INITIALIZE_OUTPUT (v2f, o);
                
                // UnityObjectToClipPos multiplies vertex pos by MVP matrix
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                // TRANSFORM_TEX sets up the tiling and offset for each texture
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv_normal(v.uv, _NormalMap);
                
                // unity_ObjectToWorld is the modelMatrix
                // multiply by local position to get world pos
                o.vertex_world = mul(unity_ObjectToWorld, v.vertex);
                
                // UnityObjectToWorldNormal transforms normals to world space
                o.normal_world = UnityObjectToWorldNormal(v.normal);
                
                // transform tangents to world space
                o.tangent_world = normalize(mul(v.tangent, unity_WorldToObject);
                
                // calculate the cross product between the normals and tangents
                o.binormal_world = normalize(cross(o.normal_world, o.tangent_world) *
                v.tangent.w);
                
                return o;
            }
            

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 normal_map = tex2D(_NormalMap, i.uv_normal);
                
                // UnpackNormal performs DXT Compression and optimizes the normal map
                fixed3 normalCompressed = UnpackNormal(normal_map);
                
                // TBN matrix transforms the normal
                float3x3 TBN_matrix = float3x3
                (
                    i.tangent_world.xyz,
                    i.binormal_world,
                    i.normal_world
                );
                fixed4 normal_color = normalize(mul(normal_compressed, TBN_matrix);
                
                // output the normal color
                // return fixed4(normal_color, 1.0);
                
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
