struct default_a2v
{
    float4 position : POSITION;
    float2 texcoord : TEXCOORD0;
};

struct default_v2f
{
    float4 position : POSITION;
    float2 texcoord : TEXCOORD0;
};

default_v2f default_vertex(default_a2v input)
{
    default_v2f OUT;

    OUT.position = input.position;
    OUT.texcoord = input.texcoord;

    return OUT;
}

float4 default_fragment(default_v2f input) : COLOR
{
    return float4(1.0, 0.0, 0.0, 1.0);
}
