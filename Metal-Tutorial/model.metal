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
    float2 textureCoordinate;
    uint diffuseTextureIndex;
    uint specularTextureIndex;
    uint normalMapIndex;
    uint emissiveMapIndex;
    float3 T;
    float3 B;
    float3 N;
};

struct Mesh {
    constant Vertex* vertices;
};

vertex OutData vertexShader(
             uint vertexID [[vertex_id]],
             constant Vertex* vertexData [[buffer(0)]],
             constant float4x4& modelMatrix [[buffer(1)]],
             constant float4x4& viewMatrix [[buffer(2)]],
             constant float4x4& perspectiveMatrix [[buffer(3)]])
{
    OutData out;
    out.position = perspectiveMatrix * viewMatrix * modelMatrix * float4(vertexData[vertexID].position, 1.0f);
    out.normal = float4(vertexData[vertexID].normal, 0.0f);
    out.fragmentPosition = modelMatrix * float4(vertexData[vertexID].position, 1.0f);
    out.textureCoordinate = vertexData[vertexID].textureCoordinate;
    out.diffuseTextureIndex = vertexData[vertexID].diffuseTextureIndex;
    out.specularTextureIndex = vertexData[vertexID].specularTextureIndex;
    out.normalMapIndex = vertexData[vertexID].normalMapIndex;
    out.emissiveMapIndex = vertexData[vertexID].emissiveMapIndex;
    out.T = normalize(float3(modelMatrix * float4(vertexData[vertexID].tangent, 0.0)));
    out.B = normalize(float3(modelMatrix * float4(vertexData[vertexID].bitangent, 0.0)));
    out.N = normalize(float3(modelMatrix * float4(vertexData[vertexID].normal, 0.0)));
    
    return out;
}

fragment float4 fragmentShader(OutData in [[stage_in]],
                               constant float4& lightColor    [[buffer(0)]],
                               constant float4& lightPosition [[buffer(1)]],
                               constant float3& cameraPosition [[buffer(2)]],
                               texture2d_array<float> textureArray [[texture(3)]],
                               constant TextureInfo* textureInfoBuffer [[buffer(4)]],
                               constant float4x4& modelMatrix [[buffer(5)]],
                               sampler textureSampler [[sampler(6)]])
{
    // Debugging: Check texture index and texture info values
    if (in.diffuseTextureIndex < 0 || in.diffuseTextureIndex >= textureArray.get_array_size()) {
        return float4(1.0, 0.0, 0.0, 1.0); // Return red color for invalid texture index
    }

    if (textureInfoBuffer[in.diffuseTextureIndex].width <= 0 || textureInfoBuffer[in.diffuseTextureIndex].height <= 0) {
        return float4(0.0, 1.0, 0.0, 1.0); // Return green color for invalid texture info
    }
    
    // Calculate the normalized texture coordinates for the current texture
    int idx = in.diffuseTextureIndex;
    float2 transformedDiffuseUV = in.textureCoordinate * (float2(textureInfoBuffer[idx].width, textureInfoBuffer[idx].height) / float2(textureArray.get_width(0), textureArray.get_height(0)));
    const float4 diffuseSample = textureArray.sample(textureSampler, transformedDiffuseUV, in.diffuseTextureIndex);

    idx = in.specularTextureIndex;
    float2 transformedSpecularUV = in.textureCoordinate * (float2(textureInfoBuffer[idx].width, textureInfoBuffer[idx].height) / float2(textureArray.get_width(0), textureArray.get_height(0)));
    const float4 specularSample = textureArray.sample(textureSampler, transformedSpecularUV, in.specularTextureIndex);
    
    idx = in.normalMapIndex;
    float2 transformedNormalUV = in.textureCoordinate * (float2(textureInfoBuffer[idx].width, textureInfoBuffer[idx].height) / float2(textureArray.get_width(0), textureArray.get_height(0)));
    float4 normalSample = textureArray.sample(textureSampler, transformedNormalUV, in.normalMapIndex);
    normalSample = float4(normalSample.rgb * 2.0 - 1.0, 1.0);
    float3x3 TBN = float3x3(in.T, in.B, in.N);
    normalSample = normalize(float4(TBN * normalSample.xyz, 1.0));
    
    idx = in.emissiveMapIndex;
    float2 transformedEmissiveUV = in.textureCoordinate * (float2(textureInfoBuffer[idx].width, textureInfoBuffer[idx].height) / float2(textureArray.get_width(0), textureArray.get_height(0)));
    float4 emissiveSample = textureArray.sample(textureSampler, transformedEmissiveUV, in.emissiveMapIndex);
    // Ambient
    float ambientStrength = 0.5f;
    float4 ambient = ambientStrength * diffuseSample;
    
    // Diffuse
    float3 normal = normalize(normalSample.xyz);
    float4 lightDirection = normalize(lightPosition - in.fragmentPosition);
    float diff = max(dot(normal, lightDirection.xyz), 0.0);
    float4 diffuse = diff * lightColor * diffuseSample;
    
    // Specular
    float specularStrength = 1.0f;
    float4 viewDir = normalize(float4(cameraPosition, 1.0) - in.fragmentPosition);
//    float4 reflectDirection = reflect(-lightDirection, float4(normal, 1));
    float4 halfwayDirection = normalize(lightDirection + viewDir);
    float spec = pow(max(dot(float4(normal, 1.0), halfwayDirection), 0.0), 64);
    float4 specular = specularStrength * spec * specularSample;
    
    float4 finalColor = (ambient + diffuse + specular);
    
    return finalColor;
}
