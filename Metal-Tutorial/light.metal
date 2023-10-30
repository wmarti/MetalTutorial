//
//  light.metal
//  Metal-Tutorial
//

#include <metal_stdlib>

using namespace metal;

#include "VertexData.hpp"

struct LightVertexData
{
    // The [[position]] attribute of this member indicates that this value
    // is the clip space position of the vertex when this structure is
    // returned from the vertex function.
    float4 position [[position]];
    float4 normal;
};

vertex LightVertexData lightVertexShader(uint vertexID [[vertex_id]],
             constant LightVertexData* vertexData,
             constant TransformationData* transformationData)
{
    LightVertexData out = vertexData[vertexID];
    
    out.position = transformationData->perspectiveMatrix * transformationData->viewMatrix * transformationData->modelMatrix * vertexData[vertexID].position;
    return out;
}

fragment float4 lightFragmentShader(LightVertexData in [[stage_in]],
                                    constant float4& lightColor [[ buffer(0) ]]) {
    return lightColor;
}
