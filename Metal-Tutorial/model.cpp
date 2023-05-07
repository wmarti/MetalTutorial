//
//  model.cpp
//  Metal-Tutorial
//

#include "model.hpp"

#include <iostream>

Model::Model(std::string filePath, MTL::Device* metalDevice) {
    device = metalDevice;
    baseDirectory = filePath.substr(0, filePath.find_last_of("/\\") + 1); // Base directory for the model
    loadModel(filePath);
}

Model::~Model() {
    std::cout << "Model->release()" << std::endl;
    delete textures;
    for (auto mesh : meshes)
        delete mesh;
}

void Model::loadModel(std::string& filePath) {
    Assimp::Importer assimpImporter;
    const aiScene* scene = assimpImporter.ReadFile(filePath.c_str(),
                                                   aiProcess_Triangulate      |
                                                   aiProcess_CalcTangentSpace
                                                   );
    if (!scene || scene->mFlags & AI_SCENE_FLAGS_INCOMPLETE || !scene->mRootNode) {
        std::cerr << "Error: " << assimpImporter.GetErrorString() << std::endl;
        
    }
    // Load Textures
    loadTextures(scene);
    processNode(scene->mRootNode, scene);
}

void Model::loadTextures(const aiScene* scene) {
    std::cout << "Loading Textures..." << std::endl;
    int textureIndex = 0;
    for (int i = 0;  i < scene->mNumMaterials; i++) {
        aiMaterial* material = scene->mMaterials[i];
        mapTextureIndices(aiTextureType_DIFFUSE, material, textureIndex);
        mapTextureIndices(aiTextureType_SPECULAR, material, textureIndex);
        mapTextureIndices(aiTextureType_HEIGHT, material, textureIndex);
        mapTextureIndices(aiTextureType_EMISSIVE, material, textureIndex);
    }
    if (textureFilePaths.size() == 0) {
        std::cerr << "Texture Files not found..." << std::endl;
        exit(1);
    }
    textures = new TextureArray(textureFilePaths,
                                device);
}

void Model::mapTextureIndices(aiTextureType textureType, aiMaterial* material, int& textureIndex) {
    for (int j = 0; j < material->GetTextureCount(textureType); j++) {
        aiString textureFileName;
        if (material->GetTexture(textureType, 0, &textureFileName) == AI_SUCCESS) {
            // If not mapped yet, map the texture index to the texture name.
            if (textureIndexMap[textureFileName.C_Str()] == 0) {
                std::string textureFilePath = baseDirectory + std::string(textureFileName.C_Str());
                std::cout << textureIndex+1 << ".) " << textureFilePath << std::endl;
                textureIndexMap[textureFileName.C_Str()] = textureIndex++;
                textureFilePaths.push_back(textureFilePath);
            }
        }
    }
}

void Model::processNode(aiNode* node, const aiScene* scene) {
    for (unsigned int i = 0; i < node->mNumMeshes; i++) {
        aiMesh* aiMesh = scene->mMeshes[node->mMeshes[i]];
        meshes.push_back(processMesh(aiMesh, scene));
    }
    
    for (unsigned int i = 0; i < node->mNumChildren; i++) {
        processNode(node->mChildren[i], scene);
    }
}

Mesh* Model::processMesh(aiMesh* aiMesh, const aiScene* scene) {
    std::vector<Vertex> vertices;
    std::vector<uint32_t> indices;
    std::unordered_map<Vertex, uint32_t> uniqueVertices;
    
    // Get texture file names
    aiString diffuseTextureName, specularTextureName, normalTextureName, emissiveTextureName;
    aiMaterial* material = scene->mMaterials[aiMesh->mMaterialIndex];
    material->GetTexture(aiTextureType_DIFFUSE, 0, &diffuseTextureName);
    material->GetTexture(aiTextureType_SPECULAR, 0, &specularTextureName);
    material->GetTexture(aiTextureType_HEIGHT, 0, &normalTextureName);
    material->GetTexture(aiTextureType_EMISSIVE, 0, &emissiveTextureName);

    // Extract Per-Vertex Data
    for (unsigned int i = 0; i < aiMesh->mNumFaces; i++) {
        aiFace face = aiMesh->mFaces[i];
        
        for (unsigned int j = 0; j < face.mNumIndices; j++) {
            unsigned int vertexIndex = face.mIndices[j];
            aiVector3D pos = aiMesh->mVertices[vertexIndex];
            aiVector3D normal = aiMesh->mNormals[vertexIndex];
            aiVector3D texCoord = aiMesh->mTextureCoords[0][vertexIndex];
            aiVector3D tangent = aiMesh->mTangents[vertexIndex];
            aiVector3D bitangent = aiMesh->mTangents[vertexIndex];
            
            Vertex vertex;
            vertex.position = {pos.x, pos.y, pos.z};
            vertex.normal = {normal.x, normal.y, normal.z};
            vertex.textureCoordinate = {texCoord.x, texCoord.y};
            vertex.tangent = {tangent.x, tangent.y, tangent.z};
            vertex.bitangent = {bitangent.x, bitangent.y, bitangent.z};
            vertex.diffuseTextureIndex = {textureIndexMap[diffuseTextureName.C_Str()]};
            vertex.specularTextureIndex = {textureIndexMap[specularTextureName.C_Str()]};
            vertex.normalMapIndex = {textureIndexMap[normalTextureName.C_Str()]};
            vertex.emissiveMapIndex = {textureIndexMap[emissiveTextureName.C_Str()]};
            // Check if the vertex is unique or not
            if (uniqueVertices.count(vertex) == 0) {
                uniqueVertices[vertex] = static_cast<uint32_t>(vertices.size());
                vertices.push_back(vertex);
            }
            // Add the index of the vertex to the indices vector
            indices.push_back(uniqueVertices[vertex]);
        }
    }
    Mesh* mesh = new Mesh(vertices, indices, device);
    
    return mesh;
}
