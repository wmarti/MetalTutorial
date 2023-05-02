//
//  TextureArray.hpp
//  Metal-Tutorial
//

#pragma once
#include <Metal/Metal.hpp>
#include <stb/stb_image.h>
#include <vector>

#include "VertexData.hpp"

enum TextureType {
    DIFFUSE,
    NORMAL,
    SPECULAR,
};

//struct TextureInfo {
//    int width;
//    int height;
//};

class TextureArray {
public:
    TextureArray(std::vector<std::string>& diffuseFilePaths,
                 std::vector<std::string>& normalFilePaths,
                 MTL::Device* metalDevice);
    ~TextureArray();
    
    void loadTextures(std::vector<std::string>& filePaths,
                      TextureType type);
    
    MTL::Texture* diffuseTextureArray;
    MTL::Texture* normalTextureArray;
    // Vectors to store texture info for each texture type
    std::vector<TextureInfo> diffuseTextureInfos;
    std::vector<TextureInfo> normalTextureInfos;

private:
    MTL::Device* device;
};
