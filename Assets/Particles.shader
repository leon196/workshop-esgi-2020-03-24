Shader "Unlit/Particles"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Radius ("Radius", Float) = 0.1
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

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 quantity : TEXCOORD1;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Radius;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = v.vertex;
                o.vertex.xyz *= 20.;
                o.vertex = mul(UNITY_MATRIX_M, o.vertex);

                float anim = fmod(_Time.y + v.quantity.x, 1.0);
                float fade = smoothstep(0.0, 0.5, anim) * smoothstep(1.0, 0.8, anim);
                float height = 10.;

                o.vertex.y -= anim * height;

                float3 forward = normalize(_WorldSpaceCameraPos - o.vertex.xyz);
                float3 right = normalize(cross(forward, float3(0,1,0)));
                float3 up = float3(0,-1,0);//normalize(cross(forward, right));

                o.vertex.xyz += (right * v.uv.x + up * v.uv.y * 10.) * _Radius * fade;

                o.vertex = mul(UNITY_MATRIX_VP, o.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // float dist = length(i.uv);
                // if (dist > 1.0) discard;
                // sample the texture

                fixed4 col = tex2D(_MainTex, i.uv);
                // dist = length(i.uv+float2(0.2,0.4));
                // col *= (1.-dist) * 0.5 + 0.5;

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
