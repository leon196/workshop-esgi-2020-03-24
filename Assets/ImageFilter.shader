Shader "Workshop/ImageFilter"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)

        [Header(Wave)]
        _WaveSpeed ("Wave Speed", Float) = 1.0
        _WaveFrequency ("Wave Frequency", Float) = 1.0
        _WaveStrength ("Wave Strength", Float) = 1.0
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            uniform sampler2D _MainTex;
            uniform float4 _Color;
            uniform float _WaveSpeed, _WaveFrequency, _WaveStrength;
            uniform float _Should;

            struct attribute
            {
                float4 position : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct varying
            {
                float2 uv : TEXCOORD0;
                float4 position : SV_POSITION;
            };

            varying vert (attribute v)
            {
                varying o;
                o.position = UnityObjectToClipPos(v.position);
                o.uv = v.uv;
                return o;
            }


            fixed4 frag (varying i) : SV_Target
            {
                float2 uv = i.uv;
                uv.y += _Should * sin(_Time.y * _WaveSpeed + uv.x * _WaveFrequency) * _WaveStrength;

                fixed4 col = tex2D(_MainTex, uv);
                // just invert the colors
                col.rgb = lerp(col.rgb, 1 - col.rgb, _Should);
                return col;
            }
            ENDCG
        }
    }
}
