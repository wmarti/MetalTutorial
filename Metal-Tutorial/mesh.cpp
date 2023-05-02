//
//  mesh.cpp
//  Metal-Tutorial
//

#include "mesh.hpp"

#include <iostream>

Mesh::Mesh(std::string filePath, MTL::Device* metalDevice) {
    tinyobj::attrib_t vertexArrays;
    std::vector<tinyobj::shape_t>shapes;
    std::vector<tinyobj::material_t> materials;
    
    std::string baseDirectory = filePath.substr(0, filePath.find_last_of("/\\") + 1); // Base directory for the .mtl file
    std::string warning;
    std::string error;
    
    tinyobj::LoadObj(&vertexArrays, &shapes, &materials, &error, filePath.c_str(), baseDirectory.c_str());
    if (!error.empty())
        std::cout << "TINYOBJ::ERROR: " << error << std::endl;
    
//    std::cout << shapes.size() << std::endl;
//
//    std::cout << materials.size() << std::endl;
//    std::cout << materials[0].diffuse_texname << std::endl;
//    std::cout << sizeof(Mesh::vertices) << std::endl;
//    std::cout << baseDirectory << std::endl;
    
    // Load Textures
    std::vector<std::string> diffuseFilePaths, normalFilePaths;
    for(int i = 0; i < materials.size(); i++) {
        if (!materials[i].diffuse_texname.empty()) {
            std::cout << baseDirectory + materials[i].diffuse_texname << std::endl;
            diffuseFilePaths.push_back(baseDirectory + materials[i].diffuse_texname);
        }
        if (!materials[i].bump_texname.empty()) {
            std::cout << baseDirectory + materials[i].bump_texname << std::endl;
            normalFilePaths.push_back(baseDirectory + materials[i].bump_texname);
        }
    }
    textures = new TextureArray(diffuseFilePaths,
                                normalFilePaths,
                                metalDevice);
    
    // Loop over Shapes
    for (int s = 0; s < shapes.size(); s++) {
        // Loop over Faces (polygon)
        int index_offset = 0;
        for (int f = 0; f < shapes[s].mesh.num_face_vertices.size(); f++) {
            // Get the diffuse texture name for a particular face
            int material_id = shapes[s].mesh.material_ids[f];
            std::string diffuse_texture_name2 = materials[material_id].diffuse_texname;
//            std::cout << "Diffuse texture name for face " << f << " is " << diffuse_texture_name2 << std::endl;
//            std::cout << "Normal texture name for face " << f << " is " << materials[material_id].bump_texname << std::endl;
            // Hardcode loading triangles
            int fv = 3;
            // Loop over vertices in the face
            for (int v = 0; v < fv; v++) {
                // Access to Vertex
                tinyobj::index_t idx = shapes[s].mesh.indices[index_offset + v];
                // Vertex position
                tinyobj::real_t vx = vertexArrays.vertices[3 * idx.vertex_index + 0];
                tinyobj::real_t vy = vertexArrays.vertices[3 * idx.vertex_index + 1];
                tinyobj::real_t vz = vertexArrays.vertices[3 * idx.vertex_index + 2];
                // Vertex Normal
                tinyobj::real_t nx = vertexArrays.normals[3 * idx.normal_index + 0];
                tinyobj::real_t ny = vertexArrays.normals[3 * idx.normal_index + 1];
                tinyobj::real_t nz = vertexArrays.normals[3 * idx.normal_index + 2];
                // Vertex Texture Coordinates
                tinyobj::real_t tu = vertexArrays.texcoords[2 * idx.texcoord_index + 0];
                tinyobj::real_t tv = vertexArrays.texcoords[2 * idx.texcoord_index + 1];
                // Texture Index
                int diffuseTextureIndex = shapes[s].mesh.material_ids[0];
//                int normalTextureIndex = shapes[s].mesh.material_ids[
//                if (textureIndex != 0) {
//                    std::cout << textureIndex << std::endl;
//                }
                vertices.push_back(
                   {
                    float3{vx, vy, vz},
                    float3{nx, ny, nz},
                    float2{tu, tv},
                    diffuseTextureIndex,
                    0,
                   }
                );
            }
            index_offset += fv;
        }
    }
    return;
}
