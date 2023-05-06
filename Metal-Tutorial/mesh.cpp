//
//  mesh.cpp
//  Metal-Tutorial
//

#include "mesh.hpp"

#include <iostream>

Mesh::Mesh(std::vector<Vertex>& vertices, std::vector<uint32_t>& vertexIndices,
           MTL::Device* metalDevice) {
    device = metalDevice;
    this->vertices = vertices;
    this->vertexIndices = vertexIndices;
    createBuffers();
}

Mesh::~Mesh() {
    vertexBuffer->release();
    indexBuffer->release();
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
}
