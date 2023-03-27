//
//  triangle.metal
//  MetalTutorial
//

#include <metal_stdlib>
using namespace metal;

vertex float4
vertexShader(uint vertexID [[vertex_id]],
             constant simd::float3* vertexPositions)
{
    float4 vertexOutPositions = float4(vertexPositions[vertexID][0],
                                       vertexPositions[vertexID][1],
                                       vertexPositions[vertexID][2],
                                       1.0f);
    return vertexOutPositions;
}

fragment float4 fragmentShader(float4 vertexOutPositions [[stage_in]]) {
    return float4(182.0f/255.0f, 240.0f/255.0f, 228.0f/255.0f, 1.0f);
}
