/*
		MSDF Font rendering shader
*/

struct Vertex
{
	float4 position : POSITION;
	float4 color : COLOR;
	float2 texcoord : TEXCOORD0;
};

// uniforms
sampler2D tex0;

Vertex main_vertex(Vertex input)
{
	Vertex OUT;

	OUT.position = input.position;
	OUT.color = input.color;
	OUT.texcoord = input.texcoord;

	return OUT;
}

float median(float r, float g, float b) {
	return max(min(r, g), min(max(r, g), b));
}

float linearStep(float a, float b, float x) {
	return clamp((x-a)/(b-a), 0.0, 1.0);
}

const float smoothing = 2.0/16.0;
const float outlineWidth = 6.0/16.0;
const float outerEdgeCenter = 0.5 - 6.0/16.0;

float4 main_fragment(Vertex input) : COLOR
{
	float3 msd = tex2D(tex0, input.texcoord).rgb;
	float sd = median(msd.r, msd.g, msd.b);

	float3 color = input.color.rgb;
	float3 black = 0.0;
	
	float alpha = smoothstep(outerEdgeCenter - smoothing, outerEdgeCenter + smoothing, sd);
	float border = smoothstep(0.5 - smoothing, 0.5 + smoothing, sd);
	float4 res = float4(lerp(black, color.rgb, border), alpha);

	return float4(res.rgb, res.a);
}

technique t
{
	pass p0
	{
		VertexShader = compile vs_3_0 main_vertex();
		PixelShader = compile ps_3_0 main_fragment();
	}
}
