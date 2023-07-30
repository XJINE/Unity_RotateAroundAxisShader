Shader "Unlit/Rotate"
{
    Properties
    {
        _Color ("Color", Color)   = (1,1,1,1)
        _Origin("Origin", Vector) = (0,0,0,0)
    }
    SubShader
    {
        Tags
        {
             "RenderType" = "Opaque"
        }
        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            float4 _Color;
            float3 _Origin;

            float4x4 RotationMatrixAxis4x4(float radian, float3 axis)
            {
                float _sin, _cos;
                sincos(radian, _sin, _cos);

                float t = 1 - _cos;
                float x = axis.x;
                float y = axis.y;
                float z = axis.z;

                return float4x4(t * x * x + _cos,      t * x * y - _sin * z,  t * x * z + _sin * y, 0, 
                                t * x * y + _sin * z,  t * y * y + _cos,      t * y * z - _sin * x, 0,
                                t * x * z - _sin * y,  t * y * z + _sin * x,  t * z * z + _cos,     0,
                                0, 0, 0, 1);
            }

            v2f vert (appdata v)
            {
                v2f o;

                // NOTE:
                // _WorldSpaceCameraPos makes wrong result in SceneView.
                // Set origin position manually if you need to care it.

                float3   cameraPosition = _Origin; // _WorldSpaceCameraPos;
                float3   worldPosition  = unity_ObjectToWorld._m03_m13_m23;
                float4x4 rotationMatrix = RotationMatrixAxis4x4(_Time.y, float3(0, 1, 0));

                v.vertex     = mul(unity_ObjectToWorld, v.vertex);
                v.vertex.xyz = v.vertex - worldPosition;
                v.vertex.xyz = v.vertex + (worldPosition - cameraPosition);
                v.vertex.xyz = mul(rotationMatrix, v.vertex);
                v.vertex.xyz = v.vertex + worldPosition;
                v.vertex.xyz = v.vertex - (worldPosition - cameraPosition);
                v.vertex     = mul(unity_WorldToObject, v.vertex);

                o.vertex = UnityObjectToClipPos(v.vertex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = _Color;
                return col;
            }
            ENDCG
        }
    }
}