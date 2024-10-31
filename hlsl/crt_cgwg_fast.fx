/*
    cgwg's CRT shader

    Copyright (C) 2010-2011 cgwg, Themaister

    This program is free software; you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by the Free
    Software Foundation; either version 2 of the License, or (at your option)
    any later version.

    (cgwg gave their consent to have their code distributed under the GPL in
    this message:

        http://board.byuu.org/viewtopic.php?p=26075#p26075

        "Feel free to distribute my shaders under the GPL. After all, the
        barrel distortion code was taken from the Curvature shader, which is
        under the GPL."
    )
*/

#include "defaults.inc"

#define CRTCGWG_GAMMA 2.7

#define TEX2D(c) tex2D(tex0, (c)).rgb
#define PI 3.141592653589

// uniforms
sampler2D tex0;
float2    texture_size;
float2    video_size;
float2    output_size;

float4 main_fragment(default_v2f input) : COLOR
{
    float2 delta = 1.0 / texture_size;
    float dx = delta.x;
    float dy = delta.y;

    float2 c01 = input.texcoord + float2(-dx, 0.0);
    float2 c11 = input.texcoord + float2(0.0, 0.0);
    float2 c21 = input.texcoord + float2(dx, 0.0);
    float2 c31 = input.texcoord + float2(2.0 * dx, 0.0);
    float2 c02 = input.texcoord + float2(-dx, dy);
    float2 c12 = input.texcoord + float2(0.0, dy);
    float2 c22 = input.texcoord + float2(dx, dy);
    float2 c32 = input.texcoord + float2(2.0 * dx, dy);
    float mod_factor = c11.x * output_size.x * texture_size.x / video_size.x;
    float2 ratio_scale = c11 * texture_size;

    float2 uv_ratio = frac(ratio_scale);
    float3 col, col2;

    float4x3 texes0 = float4x3(TEX2D(c01).xyz, TEX2D(c11).xyz, TEX2D(c21).xyz, TEX2D(c31).xyz);
    float4x3 texes1 = float4x3(TEX2D(c02).xyz, TEX2D(c12).xyz, TEX2D(c22).xyz, TEX2D(c32).xyz);

    float4 coeffs = float4(1.0 + uv_ratio.x, uv_ratio.x, 1.0 - uv_ratio.x, 2.0 - uv_ratio.x) +  0.005;
    coeffs = sin(PI * coeffs) * sin(0.5 * PI * coeffs) / (coeffs * coeffs);
    coeffs = coeffs / dot(coeffs, float(1.0));

    float3 weights = float3(3.33 * uv_ratio.y, 3.33 * uv_ratio.y, 3.33 * uv_ratio.y);
    float3 weights2 = float3(uv_ratio.y * -3.33 + 3.33, uv_ratio.y * -3.33 + 3.33, uv_ratio.y *  -3.33 + 3.33);

    col = saturate(mul(coeffs, texes0));
    col2 = saturate(mul(coeffs, texes1));

    float3 wid = 2.0 * pow(col, float3(4.0, 4.0, 4.0)) + 2.0;
    float3 wid2 = 2.0 * pow(col2, float3(4.0, 4.0, 4.0)) + 2.0;

    col = pow(col, float3(CRTCGWG_GAMMA, CRTCGWG_GAMMA, CRTCGWG_GAMMA));
    col2 = pow(col2, float3(CRTCGWG_GAMMA, CRTCGWG_GAMMA, CRTCGWG_GAMMA));

    float3 sqrt1 = rsqrt(0.5 * wid);
    float3 sqrt2 = rsqrt(0.5 * wid2);

    float3 pow_mul1 = weights * sqrt1;
    float3 pow_mul2 = weights2 * sqrt2;

    float3 div1 = 0.1320 * wid + 0.392;
    float3 div2 = 0.1320 * wid2 + 0.392;

    float3 pow1 = -pow(pow_mul1, wid);
    float3 pow2 = -pow(pow_mul2, wid2);

    weights = exp(pow1) / div1;
    weights2 = exp(pow2) / div2;

    float3 multi = col * weights + col2 * weights2;
    float3 mcol = lerp(float3(1.0, 0.7, 1.0), float3(0.7, 1.0, 0.7), floor(fmod(mod_factor, 2.0)));

    return float4(pow(mcol * multi, float3(0.454545, 0.454545, 0.454545)), 1.0);
}

technique t
{
    pass p0
    {
        VertexShader = compile vs_3_0 default_vertex();
        PixelShader = compile ps_3_0 main_fragment();
    }
}
