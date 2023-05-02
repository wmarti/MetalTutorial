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

//struct Vertex {
//    float3 position;
//    float3 normal;
//    float2 textureCoordinate;
//    int diffuseTextureIndex;
//    int normalTextureIndex;
//};

struct Mesh {
    Mesh(std::string filePath, MTL::Device* metalDevice);
    
    std::vector<Vertex> vertices;
    std::vector<uint32_t> vertexIndices;
    TextureArray* textures;
};
