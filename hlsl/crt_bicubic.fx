/*
    zfast_crt_standard - A simple, fast CRT shader.

    Ported to Fightcade fx shader by shine (shine.3p@gmail.com)
    
    Copyright (C) 2017 Greg Hogan (SoltanGris42)

    This program is free software; you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by the Free
    Software Foundation; either version 2 of the License, or (at your option)
    any later version.


Notes:  This shader does scaling with a weighted linear filter for adjustable
    sharpness on the x and y axes based on the algorithm by Inigo Quilez here:
    http://http://www.iquilezles.org/www/articles/texture/texture.htm
    but modified to be somewhat sharper.  Then a scanline effect that varies
    based on pixel brighness is applied along with a monochrome aperture mask.
    This shader runs at 60fps on the Raspberry Pi 3 hardware at 2mpix/s
    resolutions (1920x1080 or 1600x1200).
*/

#include "defaults.inc"

#define SPOT_WIDTH          0.9
#define SPOT_HEIGHT         1.65
#define COLOR_BOOST         1.0
#define InputGamma          1.5
#define OutputGamma         1.5

#define BLURSCALEX          0.75
#define LOWLUMSCAN          1.2
#define HILUMSCAN           3.0
#define BRIGHTBOOST         1.0
#define MASK_DARK           0.85
#define MASK_FADE           1.0

#define GAMMA_IN(color)     pow(color, float4(InputGamma, InputGamma, InputGamma, InputGamma))
#define GAMMA_OUT(color)    pow(color, float4(1.0 / OutputGamma, 1.0 / OutputGamma, 1.0 / OutputGamma, 1.0 / OutputGamma))
#define TEX2D(coords)       GAMMA_IN(tex2D(tex0, coords).rgba)

// uniforms
sampler2D tex0;
float2    texture_size;

struct out_vertex
{
    float4 position : POSITION;
    float2 texcoord : TEXCOORD0;
    float2 one      : TEXCOORD1;
};

out_vertex main_vertex(default_a2v input)
{
    out_vertex OUT;

    OUT.position = input.position;
    OUT.texcoord = input.texcoord;
    OUT.one.x = float2(1.0 / texture_size.x, 0.0);
    OUT.one.y = float2(0.0, 1.0 / texture_size.y);

    return OUT;
}

float4 main_fragment(out_vertex input) : COLOR
{
    float2 coords = (input.texcoord * texture_size);
    float2 pixel_center = floor(coords) + float2(0.5, 0.5);
    
    float2 dx = coords - pixel_center;

    float2 texture_coords = (pixel_center + 4.0 * dx * dx * dx) / texture_size;
    texture_coords.x = lerp(texture_coords.x, input.texcoord.x, BLURSCALEX);
    float Y = dx.y * dx.y;
    float YY = Y * Y;
    
    float whichmask = frac(input.texcoord.y * -0.5);
    float mask = 1.0 + float(whichmask < 0.5) * -MASK_DARK;
    float4 color = TEX2D(texture_coords);
    
    float scanLineWeight = (BRIGHTBOOST - LOWLUMSCAN * (Y - 2.05 * YY));
    float scanLineWeightB = 1.0 - HILUMSCAN * (YY - 2.8 * YY * Y); 

    float maskFade = 0.3333 * MASK_FADE;
    color *= lerp(scanLineWeight * mask, scanLineWeightB, dot(color.rgb, float3(maskFade, maskFade, maskFade)));
    color *= float4(COLOR_BOOST, COLOR_BOOST, COLOR_BOOST, COLOR_BOOST);

    return clamp(GAMMA_OUT(color), 0.0, 1.0);
}

technique t
{
    pass p0
    {
        VertexShader = compile vs_3_0 main_vertex();
        PixelShader = compile ps_3_0 main_fragment();
    }
}
