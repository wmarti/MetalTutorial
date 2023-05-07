//
//  model.hpp
//  Metal-Tutorial
//

#pragma once

#include <Metal/Metal.hpp>
#include <assimp/Importer.hpp>
#include <assimp/scene.h>
#include <assimp/postprocess.h>

#include <string>

#include "mesh.hpp"

class Model {
public:
    Model(std::string filePath, MTL::Device* metalDevice);
    ~Model();
    std::vector<Mesh*> meshes;
    TextureArray* textures;
    simd::float4x4 translationMatrix;

private:
    void loadModel(std::string& filePath);
    void loadTextures(const aiScene* scene);
    void mapTextureIndices(aiTextureType textureType, aiMaterial* material, int& textureIndex);
    void processNode(aiNode* node, const aiScene* scene);
    Mesh* processMesh(aiMesh* mesh, const aiScene* scene);
    
    std::string baseDirectory;
    MTL::Device* device;
    std::unordered_map<std::string, int> textureIndexMap;
    std::vector<std::string> textureFilePaths;
};
