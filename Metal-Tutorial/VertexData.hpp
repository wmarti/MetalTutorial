//
//  VertexData.h
//  Metal-Tutorial
//

#pragma once
#include <simd/simd.h>

using namespace simd;

struct Vertex {
    float3 position;
    float3 normal;
    float3 tangent;
    float3 bitangent;
    float2 textureCoordinate;
    int diffuseTextureIndex;
    int specularTextureIndex;
    int normalMapIndex;
    int emissiveMapIndex;
};

struct TextureInfo {
    int width;
    int height;
};

struct VertexData {
    float4 position;
    float4 normal;
};

struct TransformationData {
    float4x4 translationMatrix;
    float4x4 perspectiveMatrix;
};
