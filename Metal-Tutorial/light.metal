//
//  light.metal
//  Metal-Tutorial
//

#include <metal_stdlib>
using namespace metal;

struct VertexData
{
    // The [[position]] attribute of this member indicates that this value
    // is the clip space position of the vertex when this structure is
    // returned from the vertex function.
    float4 position [[position]];
    float4 normal;
};

vertex VertexData lightVertexShader(uint vertexID [[vertex_id]],
             constant VertexData* vertexData,
             constant float4x4& modelMatrix,
             constant float4x4& perspectiveMatrix)
{
    VertexData out = vertexData[vertexID];
    
    out.position = perspectiveMatrix * modelMatrix * vertexData[vertexID].position;
    return out;
}

fragment float4 lightFragmentShader(VertexData in [[stage_in]],
                                    constant float4& lightColor [[ buffer(0) ]]) {
    return lightColor;
}
