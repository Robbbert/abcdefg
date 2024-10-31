/*
    Phosphor shader - Copyright (C) 2011 caligari.

    Ported by Hyllian.

   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License
   as published by the Free Software Foundation; either version 2
   of the License, or (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/

#include "defaults.inc"

#define SPOT_WIDTH  0.9
#define SPOT_HEIGHT 0.65
#define COLOR_BOOST 1.45
#define InputGamma 2.4
#define OutputGamma 2.2

#define GAMMA_IN(color)     pow(color, float4(InputGamma, InputGamma, InputGamma, InputGamma))
#define GAMMA_OUT(color) pow(color, float4(1.0 / OutputGamma, 1.0 / OutputGamma, 1.0 / OutputGamma, 1.0 / OutputGamma))
#define TEX2D(coords) GAMMA_IN( tex2D(tex0, coords).rgba )

// Macro for weights computing
#define WEIGHT(w) if(w>1.0) w=1.0; w = 1.0 - w * w; w = w * w;

// uniforms
sampler2D tex0;
float2    texture_size;

struct out_vertex
{
    float4 position : POSITION;
    float2 texCoord : TEXCOORD0;
    float2 one      : TEXCOORD1;
};

out_vertex main_vertex(default_a2v input)
{
    out_vertex OUT;

    OUT.position = input.position;
    OUT.texCoord = input.texcoord;
    OUT.one.x = float2(1.0 / texture_size.x, 0.0);
    OUT.one.y = float2(0.0, 1.0 / texture_size.y);

    return OUT;
}

float4 main_fragment(out_vertex input) : COLOR
{
    float2 coords = ( input.texCoord * texture_size );
    float2 pixel_center = floor( coords ) + float2(0.5, 0.5);
    float2 texture_coords = pixel_center / texture_size;

    float4 color = TEX2D( texture_coords );

    float dx = coords.x - pixel_center.x;

    float h_weight_00 = dx / SPOT_WIDTH;
    WEIGHT(h_weight_00);

    color *= float4( h_weight_00, h_weight_00, h_weight_00, h_weight_00  );

    // get closest horizontal neighbour to blend
    float2 coords01;
    if (dx>0.0) {
        coords01 = input.one.x;
        dx = 1.0 - dx;
    } else {
        coords01 = -input.one.y;
        dx = 1.0 + dx;
    }
    float4 colorNB = TEX2D( texture_coords + coords01 );

    float h_weight_01 = dx / SPOT_WIDTH;
    WEIGHT( h_weight_01 );

    color = color + colorNB * float4( h_weight_01, h_weight_01, h_weight_01, h_weight_01 );

    //////////////////////////////////////////////////////
    // Vertical Blending
    float dy = coords.y - pixel_center.y;
    float v_weight_00 = dy / SPOT_HEIGHT;
    WEIGHT(v_weight_00);
    color *= float4( v_weight_00, v_weight_00, v_weight_00, v_weight_00 );

    // get closest vertical neighbour to blend
    float2 coords10;
    if (dy>0.0) {
        coords10 = input.one.y;
        dy = 1.0 - dy;
    } else {
        coords10 = -input.one.y;
        dy = 1.0 + dy;
    }
    colorNB = TEX2D( texture_coords + coords10 );

    float v_weight_10 = dy / SPOT_HEIGHT;
    WEIGHT( v_weight_10 );

    color = color + colorNB * float4( v_weight_10 * h_weight_00, v_weight_10 * h_weight_00, v_weight_10 * h_weight_00, v_weight_10 * h_weight_00 );

    colorNB = TEX2D(  texture_coords + coords01 + coords10 );

    color = color + colorNB * float4( v_weight_10 * h_weight_01, v_weight_10 * h_weight_01, v_weight_10 * h_weight_01, v_weight_10 * h_weight_01 );

    color *= float4( COLOR_BOOST, COLOR_BOOST, COLOR_BOOST, COLOR_BOOST );

    return clamp( GAMMA_OUT(color), 0.0, 1.0 );
}

technique t
{
    pass p0
    {
        VertexShader = compile vs_3_0 main_vertex();
        PixelShader = compile ps_3_0 main_fragment();
    }
}
