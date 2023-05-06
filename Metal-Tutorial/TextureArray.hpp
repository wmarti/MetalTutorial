//
//  TextureArray.hpp
//  Metal-Tutorial
//

#pragma once
#include <Metal/Metal.hpp>
#include <stb/stb_image.h>
#include <vector>

#include "VertexData.hpp"

class TextureArray {
public:
    TextureArray(std::vector<std::string>& filePaths,
                 MTL::Device* metalDevice);
    ~TextureArray();
    
    void loadTextures(std::vector<std::string>& filePaths);
    void createTextureInfosBuffer();
    
    MTL::Texture* textureArray;
    // Vectors to store texture info for each texture type
    std::vector<TextureInfo> textureInfos;
    MTL::Buffer* textureInfosBuffer;

private:
    MTL::Device* device;
};
