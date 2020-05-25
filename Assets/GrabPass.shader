Shader "Workshop/GrabPass"
{
    Properties
    {
        _Map ("Map", 2D) = "black" {}
    }
    SubShader
    {
        // Draw ourselves after all opaque geometry
        Tags { "Queue" = "Transparent" }

        // Grab the screen behind the object into _BackgroundTexture
        GrabPass
        {
            "_BackgroundTexture"
        }

        // Render the object with the texture generated above, and invert the colors
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _Map;

            struct v2f
            {
                float4 grabPos : TEXCOORD0;
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD1;
            };

            v2f vert(appdata_base v) {
                v2f o;
                // use UnityObjectToClipPos from UnityCG.cginc to calculate 
                // the clip-space of the vertex
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                // use ComputeGrabScreenPos function from UnityCG.cginc
                // to get the correct texture coordinate
                o.grabPos = ComputeGrabScreenPos(o.pos);
                return o;
            }

            sampler2D _BackgroundTexture;

            half4 frag(v2f i) : SV_Target
            {
                float4 uv = i.grabPos;
                float map = tex2D(_Map, i.uv).r;
                float angle = map * 6.28; // TAU

                uv.xy += float2(cos(angle), sin(angle)) * 0.5;
                half4 bgcolor = tex2Dproj(_BackgroundTexture, uv);
                return bgcolor;
            }
            ENDCG
        }

    }
}