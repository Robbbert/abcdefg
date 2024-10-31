//
// PUBLIC DOMAIN CRT STYLED SCAN-LINE SHADER
//
//   by Timothy Lottes
//
//   Ported to Fightcade fx shader by shine (shine.3p@gmail.com)
//
// This is more along the style of a really good CGA arcade monitor.
// With RGB inputs instead of NTSC.
// The shadow mask example has the mask rotated 90 degrees for less chromatic aberration.
//
// Left it unoptimized to show the theory behind the algorithm.
//
// It is an example what I personally would want as a display option for pixel art games.
// Please take and use, change, or whatever.
//

#include "defaults.inc"

#define HARD_SCAN       -8.0 // -8.0 = soft, -16.0 = medium
#define HARD_PIX        -3.0 // -2.0 = soft, -4.0 = hard
#define WARP            10.0 // -16.0 = soft, -4.0 = strong
#define VIGNETTE        80.0 // vignette spread
#define VIGNETTE_POW    0.40 // vignette power
#define MASK_VEC        float3(1.1,1.0,1.2)

// uniforms
sampler2D tex0;
float2 texture_size;
float2 video_size;
float2 output_size;

//------------------------------------------------------------------------

// sRGB to Linear.
// Assuing using sRGB typed textures this should not be needed.
float ToLinear1(float c) { return(c<=0.04045)?c/12.92:pow((c+0.055)/1.055,2.4); }
float3 ToLinear(float3 c) { return float3(ToLinear1(c.r),ToLinear1(c.g),ToLinear1(c.b)); }

// Linear to sRGB.
// Assuing using sRGB typed textures this should not be needed.
float ToSrgb1(float c) { return(c<0.0031308?c*12.92:1.055*pow(c,0.41666)-0.055); }
float3 ToSrgb(float3 c) { return float3(ToSrgb1(c.r),ToSrgb1(c.g),ToSrgb1(c.b)); }

// Nearest emulated sample given floating point position and texel offset.
// Also zero's off screen.
float3 Fetch(float2 pos,float2 off)
{
    pos=floor(pos*texture_size+off)/texture_size;
    if(max(abs(pos.x-0.5),abs(pos.y-0.5))>0.5) return float3(0.0,0.0,0.0);
    return ToLinear(tex2D(tex0, pos.xy).rgb);
}

// Distance in emulated pixels to nearest texel.
float2 Dist(float2 pos) { pos=pos*texture_size; return -((pos-floor(pos))-float2(0.5,0.5)); }
    
// 1D Gaussian.
float Gaus(float pos,float scale) { return exp2(scale*pos*pos); }

// 3-tap Gaussian filter along horz line.
float3 Horz3(float2 pos,float off)
{
    float3 b=Fetch(pos,float2(-1.0,off));
    float3 c=Fetch(pos,float2( 0.0,off));
    float3 d=Fetch(pos,float2( 1.0,off));
    float dst=Dist(pos).x;
    // Convert distance to weight.
    float scale=HARD_PIX;
    float wb=Gaus(dst-1.0,scale);
    float wc=Gaus(dst+0.0,scale);
    float wd=Gaus(dst+1.0,scale);
    // Return filtered sample.
    return (b*wb+c*wc+d*wd)/(wb+wc+wd);
}

// 5-tap Gaussian filter along horz line.
float3 Horz5(float2 pos,float off)
{
    float3 a=Fetch(pos,float2(-2.0,off));
    float3 b=Fetch(pos,float2(-1.0,off));
    float3 c=Fetch(pos,float2( 0.0,off));
    float3 d=Fetch(pos,float2( 1.0,off));
    float3 e=Fetch(pos,float2( 2.0,off));
    float dst=Dist(pos).x;
    // Convert distance to weight.
    float scale=HARD_PIX;
    float wa=Gaus(dst-2.0,scale);
    float wb=Gaus(dst-1.0,scale);
    float wc=Gaus(dst+0.0,scale);
    float wd=Gaus(dst+1.0,scale);
    float we=Gaus(dst+2.0,scale);
    // Return filtered sample.
    return (a*wa+b*wb+c*wc+d*wd+e*we)/(wa+wb+wc+wd+we);
}

// Return scanline weight.
float Scan(float2 pos,float off)
{
    float dst=Dist(pos).y;
    return Gaus(dst+off,HARD_SCAN);
}

// Allow nearest three lines to effect pixel.
float3 Tri(float2 pos){
    float3 a=Horz3(pos,-1.0);
    float3 b=Horz5(pos, 0.0);
    float3 c=Horz3(pos, 1.0);
    float wa=Scan(pos,-1.0);
    float wb=Scan(pos, 0.0);
    float wc=Scan(pos, 1.0);
    return a*wa+b*wb+c*wc;
}

// Distortion of scanlines, and end of screen alpha.
float2 Warp(float2 pos)
{
    float2 norm=texture_size / video_size;
    float2 warp=1.0/WARP;
    pos=pos*norm-0.5;
    pos*=float2(1.0+(pos.y*pos.y)*warp.x, 1.0+(pos.x*pos.x)*warp.y);
    return pos/norm+0.5/norm;
}

// Vignetting
float Vignette(float2 pos)
{
    float2 norm=texture_size / video_size;
    pos=pos*norm;
    pos*=1.0-pos.yx;
    float vig=saturate(pos.x*pos.y*VIGNETTE);
    return pow(vig,VIGNETTE_POW);
}

float4 main_fragment(default_v2f input) : COLOR
{
    float2 pos = Warp(input.texcoord);
    float3 col = Tri(pos) * Vignette(pos) * MASK_VEC;
    return float4(ToSrgb(col), 1.0);
}

technique t
{
    pass p0
    {
        VertexShader = compile vs_3_0 default_vertex();
        PixelShader = compile ps_3_0 main_fragment();
    }
}
