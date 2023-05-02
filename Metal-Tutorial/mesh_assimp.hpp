//
//  mesh_assimp.hpp
//  Metal-Tutorial
//
#pragma once
#include <string>
#include <simd/simd.h>
using namespace simd;

#include <assimp/Importer.hpp>      // C++ importer interface
#include <assimp/scene.h>           // Output data structure
#include <assimp/postprocess.h>     // Post processing flags

//struct Vertex {
//    float3 position;
//    float3 normal;
//    float2 textureCoordinates;
//};
//
//struct Mesh {
//    Mesh(std::string filePath);
//    std::vector<float3> vertices;
//    std::vector<float3> normals;
//    std::vector<float2> textureCoordinates;
//};
