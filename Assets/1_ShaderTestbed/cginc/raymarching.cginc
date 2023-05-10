
#ifndef RAYMARCHING
#define RAYMARCHING

float4 sminColor(float4 a, float4 b, float k)
{
    float h = clamp(0.5 + 0.5 * (b.w - a.w) / k, 0.0, 1.0);
    float3 color = lerp(b.rgb, a.rgb, h);
    float dist = lerp(b.w, a.w, h) - k * h * (1.0 - h);

    return float4(color, dist);
}

float smin(float4 a, float4 b, float k)
{
    float h = clamp(0.5 + 0.5 * (b.w - a.w) / k, 0.0, 1.0);
    float dist = lerp(b.w, a.w, h) - k * h * (1.0 - h);

    return dist;
}


#endif
