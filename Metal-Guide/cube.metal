//
//  cube.metal
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
};

struct TransformationData {
    float4x4 modelMatrix;
    float4x4 perspectiveMatrix;
};

vertex VertexData vertexShader(uint vertexID [[vertex_id]],
             constant VertexData* vertexData,
             constant TransformationData* transformationData)
{
    VertexData out = vertexData[vertexID];
    
    out.position = transformationData->perspectiveMatrix * transformationData->modelMatrix * vertexData[vertexID].position;
    return out;
}

fragment float4 fragmentShader(VertexData in [[stage_in]],
                               constant float4& cubeColor  [[buffer(0)]],
                               constant float4& lightColor [[buffer(1)]])
{

    float ambientStrength = 0.2f;
    float4 ambient = ambientStrength * lightColor;
    
    float4 finalColor = ambient * cubeColor;
    return finalColor;
}
