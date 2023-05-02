//
//  mesh.hpp
//  Metal-Tutorial
//

#pragma once

#include <simd/simd.h>
using namespace simd;

#include <vector>
#include <string>

#include <tiny_obj_loader.h>
//#include "Texture.hpp"
#include "TextureArray.hpp"
#include "VertexData.hpp"
#include <map>

struct Vertex {
    float3 position;
    float3 normal;
    float2 textureCoordinate;
    int diffuseTextureIndex;
    int normalTextureIndex;
    
    bool operator==(const Vertex& other) const {
        return position.x == other.position.x &&
               position.y == other.position.y &&
               position.z == other.position.z &&
               normal.x == other.normal.x &&
               normal.y == other.normal.y &&
               normal.z == other.normal.z &&
               textureCoordinate.x == other.textureCoordinate.x &&
               textureCoordinate.y == other.textureCoordinate.y &&
               diffuseTextureIndex == other.diffuseTextureIndex &&
               normalTextureIndex == other.normalTextureIndex;
    }
    
};

namespace std {
    template<> struct hash<simd::float3> {
        size_t operator()(simd::float3 const& vector) const {
            size_t h1 = hash<float>{}(vector.x);
            size_t h2 = hash<float>{}(vector.y);
            size_t h3 = hash<float>{}(vector.z);
            return h1 ^ (h2 << 1) ^ (h3 << 2);
        }
    };

    template<> struct hash<simd::float2> {
        size_t operator()(simd::float2 const& vector) const {
            size_t h1 = hash<float>{}(vector.x);
            size_t h2 = hash<float>{}(vector.y);
            return h1 ^ (h2 << 1);
        }
    };

template<> struct hash<Vertex> {
    size_t operator()(Vertex const& vertex) const {
        size_t h1 = hash<float3>{}(vertex.position);
        size_t h2 = hash<float3>{}(vertex.normal);
        size_t h3 = hash<float2>{}(vertex.textureCoordinate);
        size_t h4 = hash<int>{}(vertex.diffuseTextureIndex);
        size_t h5 = hash<int>{}(vertex.normalTextureIndex);
        
        return h1 ^ (h2 << 1) ^ (h3 << 2) ^ (h4 << 3) ^ (h5 << 4);
    }
};

//    template<> struct hash<Vertex> {
//        size_t operator()(Vertex const& vertex) const {
//            return ((hash<simd::float3>()(vertex.position) ^
//                    (hash<simd::float3>()(vertex.normal) << 1)) >> 1) ^
//                    (hash<simd::float2>()(vertex.textureCoordinate) << 1);
//        }
//    };
}

struct Mesh {
    Mesh(std::string filePath, MTL::Device* metalDevice);
    
    std::vector<Vertex> vertices;
    std::vector<uint32_t> vertexIndices;
    TextureArray* textures;
    std::unordered_map<Vertex, uint32_t> vertexMap;

};
