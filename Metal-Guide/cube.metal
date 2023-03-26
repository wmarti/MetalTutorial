//
//  cube.metal
//  MetalTutorial
//

#include <metal_stdlib>
using namespace metal;

struct VertexData
{
    float4 position;
    float4 normal;
};

struct OutData {
    // The [[position]] attribute of this member indicates that this value
    // is the clip space position of the vertex when this structure is
    // returned from the vertex function.
    float4 position [[position]];
    float4 normal;
    float4 fragmentPosition;
};

struct TransformationData {
    float4x4 modelMatrix;
    float4x4 perspectiveMatrix;
};

vertex OutData vertexShader(uint vertexID [[vertex_id]],
             constant VertexData* vertexData,
             constant TransformationData* transformationData)
{
    OutData out;
    out.position = transformationData->perspectiveMatrix * transformationData->modelMatrix * vertexData[vertexID].position;
    out.normal = vertexData[vertexID].normal;
    out.fragmentPosition = transformationData->modelMatrix * vertexData[vertexID].position;
    return out;
}

fragment float4 fragmentShader(OutData in [[stage_in]],
                               constant float4& cubeColor     [[buffer(0)]],
                               constant float4& lightColor    [[buffer(1)]],
                               constant float4& lightPosition [[buffer(2)]])
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
    float4 viewDir = normalize(float4(0.0,0.0,0.0,1.0) - in.fragmentPosition);
    float4 reflectDir = reflect(-lightDir, float4(norm, 1));
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 16);
    float4 specular = specularStrength * spec * lightColor;
    
    float4 finalColor = (ambient + diffuse + specular) * cubeColor;
    return finalColor;
}
