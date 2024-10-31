/*
    CRT Shader by EasyMode
    License: GPL
*/

#include "defaults.inc"

// TODO: Definirlo como parametros configurables desde la app
#define SHARPNESS_IMAGE 1.0
#define SHARPNESS_EDGES 3.0
#define GLOW_WIDTH 0.5
#define GLOW_HEIGHT 0.5
#define GLOW_HALATION 0.1
#define GLOW_DIFFUSION 0.05
#define MASK_COLORS 2.0
#define MASK_STRENGTH 0.3
#define MASK_SIZE 1.0
#define SCANLINE_SIZE_MIN 0.5
#define SCANLINE_SIZE_MAX 1.5
#define GAMMA_INPUT 2.4
#define GAMMA_OUTPUT 2.4
#define BRIGHTNESS 1.5

// ...
#define TEX2D(c) pow(tex2D(tex, c).rgb, GAMMA_INPUT)
#define PI 3.141592653589
#define FIX(c) max(abs(c), 1e-5)
#define mod(x,y) (x - y * trunc(x/y))

// uniforms
sampler2D tex0;
float2    texture_size;
float2    video_size;
float2    output_size;

float3 blur(float3x3 m, float dist, float rad)
{
    float3 x = float3(dist - 1.0, dist, dist + 1.0) / rad;
    float3 w = exp2(x * x * -1.0);

    return (m[0] * w.x + m[1] * w.y + m[2] * w.z) / (w.x + w.y + w.z);
}

float3x3 get_color_matrix(sampler2D tex, float2 co, float2 dx)
{
    return float3x3(TEX2D(co - dx), TEX2D(co), TEX2D(co + dx));
}

float3 get_scanline_weight(float x, float3 col)
{
    float3 beam = lerp(float3(SCANLINE_SIZE_MIN,SCANLINE_SIZE_MIN,SCANLINE_SIZE_MIN), float3(SCANLINE_SIZE_MAX,SCANLINE_SIZE_MAX,SCANLINE_SIZE_MAX), col);
    float3 x_mul = 2.0 / beam;
    float3 x_offset = x_mul * 0.5;

    return smoothstep(0.0, 1.0, 1.0 - abs(x * x_mul - x_offset)) * x_offset;
}

float3 get_mask_weight(float x, float2 texture_size, float2 video_size, float2 output_size)
{
    float i = mod(floor(x * output_size.x * texture_size.x / (video_size.x * MASK_SIZE)), MASK_COLORS);

    if (i == 0.0) return lerp(float3(1.0, 0.0, 1.0), float3(1.0, 0.0, 0.0), MASK_COLORS - 2.0);
    else if (i == 1.0) return float3(0.0, 1.0, 0.0);
    else return float3(0.0, 0.0, 1.0);
}

float3 filter_gaussian(sampler2D tex, float2 co, float2 tex_size)
{
    float2 dx = float2(1.0 / tex_size.x, 0.0);
    float2 dy = float2(0.0, 1.0 / tex_size.y);
    float2 pix_co = co * tex_size;
    float2 tex_co = (floor(pix_co) + 0.5) / tex_size;
    float2 dist = (frac(pix_co) - 0.5) * -1.0;

    float3x3 line0 = get_color_matrix(tex, tex_co - dy, dx);
    float3x3 line1 = get_color_matrix(tex, tex_co, dx);
    float3x3 line2 = get_color_matrix(tex, tex_co + dy, dx);
    float3x3 column = float3x3(blur(line0, dist.x, GLOW_WIDTH),
                               blur(line1, dist.x, GLOW_WIDTH),
                               blur(line2, dist.x, GLOW_WIDTH));

    return blur(column, dist.y, GLOW_HEIGHT);
}

float3 filter_lanczos(sampler2D tex, float2 co, float2 tex_size, float sharp)
{
    tex_size.x *= sharp;

    float2 dx = float2(1.0 / tex_size.x, 0.0);
    float2 pix_co = co * tex_size - float2(0.5, 0.0);
    float2 tex_co = (floor(pix_co) + float2(0.5, 0.0)) / tex_size;
    float2 dist = frac(pix_co);
    float4 coef = PI * float4(dist.x + 1.0, dist.x, dist.x - 1.0, dist.x - 2.0);

    coef = FIX(coef);
    coef = 2.0 * sin(coef) * sin(coef / 2.0) / (coef * coef);
    coef /= dot(coef, float4(1.0,1.0,1.0,1.0));

    float4 col1 = float4(TEX2D(tex_co), 1.0);
    float4 col2 = float4(TEX2D(tex_co + dx), 1.0);

    return mul(coef, float4x4(col1, col1, col2, col2)).rgb;
}

float4 main_fragment(default_v2f input) : COLOR
{
    float3 col_glow = filter_gaussian(tex0, input.texcoord, texture_size);
    float3 col_soft = filter_lanczos(tex0, input.texcoord, texture_size, SHARPNESS_IMAGE);
    float3 col_sharp = filter_lanczos(tex0, input.texcoord, texture_size, SHARPNESS_EDGES);
    float3 col = sqrt(col_sharp * col_soft);

    col *= get_scanline_weight(frac(input.texcoord.y * texture_size.y), col_soft);
    col_glow = saturate(col_glow - col);
    col += col_glow * col_glow * GLOW_HALATION;
    col = lerp(col, col * get_mask_weight(input.texcoord.x, texture_size, video_size, output_size) * MASK_COLORS, MASK_STRENGTH);
    col += col_glow * GLOW_DIFFUSION;
    col = pow(col * BRIGHTNESS, 1.0 / GAMMA_OUTPUT);

    return float4(col, 1.0);
}

technique t
{
    pass p0
    {
        VertexShader = compile vs_3_0 default_vertex();
        PixelShader = compile ps_3_0 main_fragment();
    }
}
