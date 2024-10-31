// Retro (CRT) shader, created to use in PPSSPP.

//Name=CRT Scanlines
//Author=KillaMaaki
//Fragment=crt.fsh
//Vertex=fxaa.vsh
//60fps=True
//SettingName1=Animation speed (0 -> disable)
//SettingDefaultValue1=1.0
//SettingMaxValue1=2.0
//SettingMinValue1=0.0
//SettingStep1=0.05

#include "defaults.inc"

uniform sampler2D sampler0;
float2 video_time;
float2 video_size;
float2 texture_size;
float4 user_settings;

float4 main_fragment(default_v2f input) : COLOR
{
    // scanlines
    int vPos = int( ( input.texcoord.y + ((video_time.y / 2) * user_settings.x) * 0.5 ) * texture_size.y); //272.0 );
    float line_intensity = fmod( float(vPos), 2.0 );

    // color shift
    float off = line_intensity * 0.0005;
    float2 shift = float2( off, 0 );

    // shift R and G channels to simulate NTSC color bleed
    float2 colorShift = float2( 0.0003, 0 );
	// float2 colorShift = float2( 0.001, 0 ); (original coeff)
    float r = tex2D( sampler0, input.texcoord + colorShift + shift ).x;
    float g = tex2D( sampler0, input.texcoord - colorShift + shift ).y;
    float b = tex2D( sampler0, input.texcoord ).z;

    float4 c = float4( r, g * 0.99, b, 1.0 ) * clamp( line_intensity, 0.85, 1.0 );

    if (user_settings.x > 0.0) {
        float rollbar = sin( ( input.texcoord.y + video_time.y * user_settings.x ) * 4.0);
        c += rollbar * 0.02;
    }

	return c;
}

technique t
{
    pass p0
    {
        VertexShader = compile vs_3_0 default_vertex();
        PixelShader = compile ps_3_0 main_fragment();
    }
}
