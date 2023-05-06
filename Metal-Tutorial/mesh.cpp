//
//  mesh.cpp
//  Metal-Tutorial
//

#include "mesh.hpp"

#include <iostream>
#include <unordered_map>
#include <string>

Mesh::Mesh(std::string filePath, MTL::Device* metalDevice) {
    device = metalDevice;
    loadObj(filePath);
    createBuffers();
}

Mesh::Mesh(std::vector<Vertex>& vertices, std::vector<uint32_t>& vertexIndices,
           MTL::Device* metalDevice) {
    device = metalDevice;
    this->vertices = vertices;
    this->vertexIndices = vertexIndices;
    unsigned long vertexCount = vertices.size();
    std::cout << "Mesh Vertex Count: " << vertexCount << std::endl;
    unsigned long vertexBufferSize = sizeof(Vertex) * vertices.size();
    std::cout << "Mesh Vertex Buffer Size: " << vertexBufferSize << std::endl;
    vertexBuffer = device->newBuffer(vertices.data(), vertexBufferSize, MTL::ResourceStorageModeShared);
    vertexBuffer->setLabel(NS::String::string("Mesh Vertex Buffer", NS::ASCIIStringEncoding));
    // Create Index Buffer
    indexCount = vertexIndices.size();
    std::cout << "Index Count: " << indexCount << std::endl;
    unsigned long indexBufferSize = sizeof(uint32_t) * vertexIndices.size();
    std::cout << "Index Buffer Size: " << indexBufferSize << std::endl;
    indexBuffer = device->newBuffer(vertexIndices.data(), indexBufferSize, MTL::ResourceStorageModeShared);
    vertexBuffer->setLabel(NS::String::string("Index Buffer", NS::ASCIIStringEncoding));
//    createBuffers();
}

Mesh::~Mesh() {
//    std::cout << "Mesh->release()" << std::endl;
//    textureArray->release();
    vertexBuffer->release();
    indexBuffer->release();
}

void Mesh::loadObj(std::string filePath) {
    tinyobj::attrib_t vertexArrays;
    std::vector<tinyobj::shape_t>shapes;
    std::vector<tinyobj::material_t> materials;
    
    std::string baseDirectory = filePath.substr(0, filePath.find_last_of("/\\") + 1); // Base directory for the .mtl file
    std::string warning;
    std::string error;
    
    tinyobj::LoadObj(&vertexArrays, &shapes, &materials, &error, filePath.c_str(), baseDirectory.c_str());
    if (!error.empty())
        std::cout << "TINYOBJ::ERROR: " << error << std::endl;
    
    
    std::unordered_map<std::string, int> textureIndexMap;
    int count = 0;
    // Load Textures
    std::vector<std::string> filePaths;
    std::string diffuseTextureName, specularTextureName, normalMapName;
    std::cout << "Loading Textures..." << std::endl;
    for(int i = 0; i < materials.size(); i++) {
        diffuseTextureName = materials[i].diffuse_texname;
        specularTextureName = materials[i].specular_texname;
        normalMapName = materials[i].bump_texname;
        if (!diffuseTextureName.empty() and !textureIndexMap.count(diffuseTextureName)) {
            std::cout << count+1 << ".) " << baseDirectory + diffuseTextureName << std::endl;
            filePaths.push_back(baseDirectory + diffuseTextureName);
            textureIndexMap[diffuseTextureName] = count++;
        }
        if (!specularTextureName.empty() and !textureIndexMap.count(specularTextureName)) {
            std::cout << count+1 << ".) " << baseDirectory + specularTextureName << std::endl;
            filePaths.push_back(baseDirectory + specularTextureName);
            textureIndexMap[specularTextureName] = count++;
        }
        if (!normalMapName.empty() and !textureIndexMap.count(normalMapName)) {
            std::cout << count+1 << ".) " << baseDirectory + normalMapName << std::endl;
            filePaths.push_back(baseDirectory + normalMapName);
            textureIndexMap[normalMapName] = count++;
        }
    }
    textures = new TextureArray(filePaths,
                                device);
    
    std::vector<float3> tempTangents(vertices.size(), float3(0.0f));
    std::vector<float3> tempBiTangents(vertices.size(), float3(0.0f));
    
    // Loop over Shapes
    for (int s = 0; s < shapes.size(); s++) {
        // Loop over Faces (polygon)
        int index_offset = 0;
        for (int face = 0; face < shapes[s].mesh.num_face_vertices.size(); face++) {
            // Get the diffuse texture name for a particular face
            int material_id = shapes[s].mesh.material_ids[face];
            diffuseTextureName = materials[material_id].diffuse_texname;
            specularTextureName = materials[material_id].specular_texname;
            normalMapName = materials[material_id].bump_texname;
            // Hardcode loading triangles
            int fv = 3;
            // Loop over vertices in the face
            for (int v = 0; v < fv; v++) {
                // Access to Vertex
                tinyobj::index_t idx = shapes[s].mesh.indices[index_offset + v];
                
                Vertex vertex{};
                // Vertex position
                vertex.position = {
                    vertexArrays.vertices[3 * idx.vertex_index + 0],
                    vertexArrays.vertices[3 * idx.vertex_index + 1],
                    vertexArrays.vertices[3 * idx.vertex_index + 2],
                };
                // Vertex Normal
                vertex.normal = {
                    vertexArrays.normals[3 * idx.normal_index + 0],
                    vertexArrays.normals[3 * idx.normal_index + 1],
                    vertexArrays.normals[3 * idx.normal_index + 2]
                };
                // Vertex Texture Coordinates
                vertex.textureCoordinate = {
                    vertexArrays.texcoords[2 * idx.texcoord_index + 0],
                    vertexArrays.texcoords[2 * idx.texcoord_index + 1]
                };
                // Texture Indices
                vertex.diffuseTextureIndex = {
                    textureIndexMap[diffuseTextureName]
                };
                vertex.specularTextureIndex = {
                    textureIndexMap[specularTextureName]
                };
                vertex.normalMapIndex = {
                    textureIndexMap[normalMapName]
                };
                // Vertex Indices
                if (vertexMap.count(vertex) == 0) {
                    vertexMap[vertex] = (uint32_t)vertices.size();
                    vertices.push_back(vertex);
                    
                    tempTangents.resize(vertices.size(), float3(0.0f));
                    tempBiTangents.resize(vertices.size(), float3(0.0f));
                }
                
                vertexIndices.push_back(vertexMap[vertex]);
                
            }
            float3 edge1 = vertices[vertexIndices[index_offset + 1]].position - vertices[vertexIndices[index_offset]].position;
            float3 edge2 = vertices[vertexIndices[index_offset + 2]].position - vertices[vertexIndices[index_offset]].position;
            float2 deltaUV1 = vertices[vertexIndices[index_offset + 1]].textureCoordinate - vertices[vertexIndices[index_offset]].textureCoordinate;
            float2 deltaUV2 = vertices[vertexIndices[index_offset + 2]].textureCoordinate - vertices[vertexIndices[index_offset]].textureCoordinate;
            
            if ((deltaUV1.x * deltaUV2.y - deltaUV2.x * deltaUV1.y) == 0) {
                std::cout << "Divide by Zero" << std::endl;
            }
            float f = 1.0f / (deltaUV1.x * deltaUV2.y - deltaUV2.x * deltaUV1.y);
            float3 tangent, bitangent;
            tangent.x = f * (deltaUV2.y * edge1.x - deltaUV1.y * edge2.x);
            tangent.y = f * (deltaUV2.y * edge1.y - deltaUV1.y * edge2.y);
            tangent.z = f * (deltaUV2.y * edge1.z - deltaUV1.y * edge2.z);
            bitangent.x = f * (-deltaUV2.x * edge1.x + deltaUV1.x * edge2.x);
            bitangent.y = f * (-deltaUV2.x * edge1.y + deltaUV1.x * edge2.y);
            bitangent.z = f * (-deltaUV2.x * edge1.z + deltaUV1.x * edge2.z);
            
            
//            tempTangents.resize(vertices.size());
//            tempBiTangents.resize(vertices.size());
            tempTangents[vertexIndices[index_offset]] += tangent;
            tempTangents[vertexIndices[index_offset + 1]] += tangent;
            tempTangents[vertexIndices[index_offset + 2]] += tangent;
            tempBiTangents[vertexIndices[index_offset]] += bitangent;
            tempBiTangents[vertexIndices[index_offset + 1]] += bitangent;
            tempBiTangents[vertexIndices[index_offset + 2]] += bitangent;
            
            
            index_offset += fv;

        }
    }
    
    // After the Loop over Shapes, normalize and store the tangent and bitangent vectors
    for (size_t i = 0; i < vertices.size(); ++i) {
        vertices[i].tangent = normalize(tempTangents[i]);
        vertices[i].bitangent = normalize(tempBiTangents[i]);
        // 6323
    }
}

void Mesh::createBuffers() {
    // Create Vertex Buffers
    unsigned long vertexCount = vertices.size();
    std::cout << "Mesh Vertex Count: " << vertexCount << std::endl;
    unsigned long vertexBufferSize = sizeof(Vertex) * vertices.size();
    std::cout << "Mesh Vertex Buffer Size: " << vertexBufferSize << std::endl;
    vertexBuffer = device->newBuffer(vertices.data(), vertexBufferSize, MTL::ResourceStorageModeShared);
    vertexBuffer->setLabel(NS::String::string("Mesh Vertex Buffer", NS::ASCIIStringEncoding));
    // Create Index Buffer
    indexCount = vertexIndices.size();
    std::cout << "Index Count: " << indexCount << std::endl;
    unsigned long indexBufferSize = sizeof(uint32_t) * vertexIndices.size();
    std::cout << "Index Buffer Size: " << indexBufferSize << std::endl;
    indexBuffer = device->newBuffer(vertexIndices.data(), indexBufferSize, MTL::ResourceStorageModeShared);
    vertexBuffer->setLabel(NS::String::string("Index Buffer", NS::ASCIIStringEncoding));

    // Pass previously created Texture Array Pointer
//    textureArray = textures->textureArray;
//    textureArray->setLabel(NS::String::string("Texture Array", NS::ASCIIStringEncoding));
    // Create Texture Info Buffer
//    size_t bufferSize = textures->textureInfos.size() * sizeof(TextureInfo);
//    std::cout << "Texture Count: " << textures->textureInfos.size() << std::endl;
//    std::cout << "TextureInfo size: " << sizeof(TextureInfo) << std::endl;
//    textureInfos = device->newBuffer(textures->textureInfos.data(), bufferSize, MTL::ResourceStorageModeShared);
//    textureInfos->setLabel(NS::String::string("Texture Info Array", NS::ASCIIStringEncoding));
}
