//
//  cube.metal
//  MetalTutorial
//

#include <metal_stdlib>
using namespace metal;

#include "VertexData.hpp"

struct OutData {
    // The [[position]] attribute of this member indicates that this value
    // is the clip space position of the vertex when this structure is
    // returned from the vertex function.
    float4 position [[position]];
    float4 normal;
    float4 fragmentPosition;
};

vertex OutData vertexShader(uint vertexID [[vertex_id]],
             constant VertexData* vertexData,
             constant TransformationData* transformationData)
{
    OutData out;
    out.position = transformationData->perspectiveMatrix * transformationData->viewMatrix * transformationData->modelMatrix * vertexData[vertexID].position;
    out.normal = vertexData[vertexID].normal;
    out.fragmentPosition = transformationData->modelMatrix * vertexData[vertexID].position;
    return out;
}

fragment float4 fragmentShader(OutData in [[stage_in]],
                               constant float4& cubeColor      [[buffer(0)]],
                               constant float4& lightColor     [[buffer(1)]],
                               constant float4& lightPosition  [[buffer(2)]],
                               constant float4& cameraPosition [[buffer(3)]])
{
    // Ambient
    float ambientStrength = 0.2f;
    float4 ambient = ambientStrength * lightColor;
    
    // Diffuse
    float3 norm = normalize(in.normal.xyz);
    float4 lightDir = normalize(lightPosition - in.fragmentPosition);
    float diff = max(dot(norm, lightDir.xyz), 0.0);
    float4 diffuse = diff * lightColor;
    
    // Specular
    float specularStrength = 0.5f;
    float4 viewDir = normalize(cameraPosition - in.fragmentPosition);
    float4 reflectDir = reflect(-lightDir, float4(norm, 1));
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32);
    float4 specular = specularStrength * spec * lightColor;
    
    float4 finalColor = (ambient + diffuse + specular) * cubeColor;
    return finalColor;
}
