//
//  cube.metal
//  MetalTutorial
//
#define METAL
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
    float3 T;
    float3 B;
    float3 N;
};

struct Mesh {
    constant Vertex* vertices;
};

vertex OutData vertexShader(
             uint vertexID [[vertex_id]],
             constant Vertex* vertexData,
             constant float4x4& modelMatrix,
             constant float4x4& perspectiveMatrix)
{
    OutData out;
    out.position = perspectiveMatrix * modelMatrix * float4(vertexData[vertexID].position, 1.0f);
    out.normal = modelMatrix * float4(vertexData[vertexID].normal, 0.0f);
    out.fragmentPosition = modelMatrix * float4(vertexData[vertexID].position, 1.0f);
    out.textureCoordinate = vertexData[vertexID].textureCoordinate;
    out.diffuseTextureIndex = vertexData[vertexID].diffuseTextureIndex;
    out.specularTextureIndex = vertexData[vertexID].specularTextureIndex;
    out.normalMapIndex = vertexData[vertexID].normalMapIndex;
    
    out.T = normalize(float3(modelMatrix * float4(vertexData[vertexID].tangent, 0.0)));
    out.B = normalize(float3(modelMatrix * float4(vertexData[vertexID].bitangent, 0.0)));
    out.N = normalize(float3(modelMatrix * float4(vertexData[vertexID].normal, 0.0)));
    
    return out;
}

fragment float4 fragmentShader(OutData in [[stage_in]],
                               constant float4& cubeColor     [[buffer(0)]],
                               constant float4& lightColor    [[buffer(1)]],
                               constant float4& lightPosition [[buffer(2)]],
                               texture2d_array<float> textureArray [[texture(3)]],
                               constant TextureInfo* textureInfoBuffer [[buffer(4)]],
                               constant float4x4& modelMatrix [[buffer(5)]])
{
    // Debugging: Check texture index and texture info values
    if (in.diffuseTextureIndex < 0 || in.diffuseTextureIndex >= textureArray.get_array_size()) {
        return float4(1.0, 0.0, 0.0, 1.0); // Return red color for invalid texture index
    }

    if (textureInfoBuffer[in.diffuseTextureIndex].width <= 0 || textureInfoBuffer[in.diffuseTextureIndex].height <= 0) {
        return float4(0.0, 1.0, 0.0, 1.0); // Return green color for invalid texture info
    }
    
    // Sample the texture to obtain a color
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear,
                                      mip_filter::linear);
    
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
    
    // Ambient
    float ambientStrength = 0.5f;
    float4 ambient = ambientStrength * diffuseSample;
    
    // Diffuse
//    float3 norm = normalize(in.normal.xyz);
    float3 norm = normalize(normalSample.xyz);
    float4 lightDir = normalize(lightPosition - in.fragmentPosition);
    float diff = max(dot(norm, lightDir.xyz), 0.0);
    float4 diffuse = diff * lightColor * diffuseSample;
    
    // Specular
    float specularStrength = 1.0f;
    float4 viewDir = normalize(float4(0.0,0.0,0.0,1.0) - in.fragmentPosition);
    float4 reflectDir = reflect(-lightDir, float4(norm, 1));
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 16);
    float4 specular = specularStrength * spec * specularSample;
    
    float4 finalColor = (ambient + diffuse + specular);
    
    return finalColor;
}
