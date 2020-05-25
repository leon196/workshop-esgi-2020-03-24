Shader "Unlit/Grass"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Radius ("Radius", Float) = 0.1
        _Color ("Color", Color) = (1,1,1,1)
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
            float4 _Color;
            float _Radius;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = v.vertex;
                o.vertex.xyz *= 20.;

                float anim = fmod(_Time.y + v.quantity.x, 1.0);
                float height = 10.;

                o.vertex.y = 0.0;
                // o.vertex.y -= anim * height;
                float y = 1.-(v.uv.y * 0.5 + 0.5);
                o.vertex.x += sin(v.uv.y * 4. - _Time.y * 4. + v.quantity.x * 10.) * 0.2 * y;

                o.vertex = mul(UNITY_MATRIX_M, o.vertex);

                float3 forward = normalize(_WorldSpaceCameraPos - o.vertex.xyz);
                float3 right = normalize(cross(forward, float3(0,1,0)));
                float3 up = float3(0,-1,0);//normalize(cross(forward, right));

                float pointe = clamp(v.uv.y, 0., 1.);

                o.vertex.xyz += (right * v.uv.x * pointe + up * v.uv.y * 10.) * _Radius;

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
                float y = i.uv.y * 0.5 + 0.5;
                col *= _Color * (1.-y);

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
