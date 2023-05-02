//
//  mesh_assimp.cpp
//  Metal-Tutorial
//
#include <iostream>
#include "mesh_assimp.hpp"

//Mesh::Mesh(std::string filePath) {
//    Assimp::Importer importer;
//    const aiScene* scene = importer.ReadFile(filePath, aiProcess_Triangulate | aiProcess_FlipUVs | aiProcess_OptimizeMeshes | aiProcess_MakeLeftHanded);
//    
//    if (!scene || scene->mFlags & AI_SCENE_FLAGS_INCOMPLETE || !scene->mRootNode) {
//        std::cout << "ERROR::ASSIMP::" << importer.GetErrorString() << std::endl;
//    }
//
//    std::cout << "Num Textures: " << scene->mNumMaterials << std::endl;
//    std::cout << "Num Meshes: " << scene->mNumMeshes << std::endl;
//}
