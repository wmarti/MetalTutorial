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
    int textureIndex;
};
//
struct Vertex {
    float3 position;
    float3 normal;
    float2 textureCoordinate;
    int diffuseTextureIndex;
    int normalTextureIndex;
};
//
//struct TextureInfo {
//    int width;
//    int height;
//};

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
    out.textureIndex = vertexData[vertexID].diffuseTextureIndex;
    return out;
}

fragment float4 fragmentShader(OutData in [[stage_in]],
                               constant float4& cubeColor     [[buffer(0)]],
                               constant float4& lightColor    [[buffer(1)]],
                               constant float4& lightPosition [[buffer(2)]],
                               texture2d_array<float> diffuseTextures [[texture(3)]],
                               texture2d_array<float> normalTextures  [[texture(4)]],
                               constant TextureInfo* diffuseTextureInfos [[buffer(5)]],
                               constant TextureInfo* normalTextureInfos [[buffer(6)]])
{
    // Debugging: Check texture index and texture info values
    if (in.textureIndex < 0 || in.textureIndex >= diffuseTextures.get_array_size()) {
        return float4(1.0, 0.0, 0.0, 1.0); // Return red color for invalid texture index
    }

    if (diffuseTextureInfos[in.textureIndex].width <= 0 || diffuseTextureInfos[in.textureIndex].height <= 0) {
        return float4(0.0, 1.0, 0.0, 1.0); // Return green color for invalid texture info
    }
    
    // Sample the texture to obtain a color
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear);
    
    // Calculate the normalized texture coordinates for the current texture
    int idx = in.textureIndex;
    float2 transformedDiffuseUV = in.textureCoordinate * (float2(diffuseTextureInfos[idx].width, diffuseTextureInfos[idx].height) / float2(diffuseTextures.get_width(0), diffuseTextures.get_height(0)));
    
    const float4 diffuseSample = diffuseTextures.sample(textureSampler, transformedDiffuseUV, in.textureIndex);
    
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
    
    float4 finalColor = (ambient + diffuse + specular) * diffuseSample;
    
    return float4(finalColor.rgb, diffuseSample.a);
}
