Shader "Unlit/TerrainMap"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ColorA ("Color A", Color) = (1,1,1,1)
        _ColorB ("Color B", Color) = (1,1,1,1)
        _TresholdMin ("Treshold Min", Range(0,1)) = 0
        _TresholdMax ("Treshold Max", Range(0,1)) = 1
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
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Common.cginc"

            // attributes (variables from vertices)
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            // varyings (variables from vertex shader to pixel shader)
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            // uniforms
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _ColorA, _ColorB;
            float _TresholdMin, _TresholdMax;

            // vertex shader function
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = v.vertex;
                
                float2 uv = v.uv;
                // Translate texture coordinates
                uv.x += _Time.y * 0.1;
                // Sample texture displacement
                float displacement = tex2Dlod(_MainTex, float4(uv,0,0)).r;

                // Another translatated
                uv = v.uv;
                uv.y += _Time.y * 0.2;
                displacement *= tex2Dlod(_MainTex, float4(uv,0,0)).r;

                // displace along normal
                o.vertex.xyz += v.normal * displacement;

                // apply transform component (position, rotation, scale)
                o.vertex = mul(UNITY_MATRIX_M, o.vertex);

                // apply view and projection matrix
                o.vertex = mul(UNITY_MATRIX_VP, o.vertex);

                // control contrast for the color gradient
                displacement = smoothstep(_TresholdMin, _TresholdMax, displacement);
                // calculate color gradient from displacement
                o.color = lerp(_ColorA, _ColorB, displacement);

                // send texture coordinate to pixel shader
                o.uv = TRANSFORM_TEX(uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = i.color;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
