//
//  triangle.metal
//  MetalTutorial
//

#include <metal_stdlib>
using namespace metal;

struct VertexData
{
    // The [[position]] attribute of this member indicates that this value
    // is the clip space position of the vertex when this structure is
    // returned from the vertex function.
    float4 position [[position]];

    // Since this member does not have a special attribute, the rasterizer
    // interpolates its value with the values of the other triangle vertices
    // and then passes the interpolated value to the fragment shader for each
    // fragment in the triangle.
    float2 textureCoordinate;
};

vertex VertexData vertexShader(uint vertexID [[vertex_id]],
             constant VertexData* vertexData)
{
    return vertexData[vertexID];
}

fragment float4 fragmentShader(VertexData in [[stage_in]],
                               texture2d<half> colorTexture [[ texture(0) ]]) {
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear);

    // Sample the texture to obtain a color
    const half4 colorSample = colorTexture.sample(textureSampler, in.textureCoordinate);
    
    return float4(colorSample);
}
