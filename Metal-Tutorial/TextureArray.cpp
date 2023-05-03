//
//  TextureArray.cpp
//  Metal-Tutorial
//
#include <iostream>

#include "TextureArray.hpp"

TextureArray::TextureArray(std::vector<std::string>& diffuseFilePaths,
                           std::vector<std::string>& normalFilePaths,
                           MTL::Device* metalDevice) {
    device = metalDevice;
    
    if (!diffuseFilePaths.empty())
        loadTextures(diffuseFilePaths, TextureType::DIFFUSE);
    if (!normalFilePaths.empty())
        loadTextures(normalFilePaths, TextureType::NORMAL);
}

void TextureArray::loadTextures(std::vector<std::string> &filePaths, TextureType type) {
    int maxImageWidth = 0, maxImageHeight = 0;
    std::vector<unsigned char*> images;
    unsigned char* image;
    int width, height, channels;
    std::vector<int> widths;
    std::vector<int> heights;
    // Load Images and determine max width and height
    for (std::string filePath : filePaths) {
        stbi_set_flip_vertically_on_load(true);
        image = stbi_load(filePath.c_str(), &width, &height, &channels, STBI_rgb_alpha);
        assert(image != NULL);
    
        maxImageWidth = std::max(maxImageWidth, width);
        maxImageHeight = std::max(maxImageHeight, height);
        
        widths.push_back(width);
        heights.push_back(height);
        
        images.push_back(image);
    }
    
    // Create Texture Array
    MTL::TextureDescriptor* textureDescriptor = MTL::TextureDescriptor::alloc()->init();
    textureDescriptor->texture2DDescriptor(MTL::PixelFormatRGBA8Unorm,
                                           maxImageWidth,
                                           maxImageHeight,
                                           false);
    textureDescriptor->setArrayLength(images.size());
    textureDescriptor->setUsage(MTL::TextureUsageShaderRead);
    textureDescriptor->setTextureType(MTL::TextureType2DArray);
    textureDescriptor->setWidth(maxImageWidth);
    textureDescriptor->setHeight(maxImageHeight);
    textureDescriptor->setMipmapLevelCount(1);
    textureDescriptor->setPixelFormat(MTL::PixelFormatRGBA8Unorm);

    MTL::Texture* textureArray = device->newTexture(textureDescriptor);
    assert(textureArray != nullptr);
    textureDescriptor->release();
    std::string textureType = type == DIFFUSE ? "Diffuse " : "Normal ";
    std::cout << textureType << "Texture Array Width: " << textureArray->width() << std::endl;
    std::cout << textureType << "Texture Array Height: " << textureArray->height() << std::endl;

    for (int i = 0; i < images.size(); i++) {
        if (type == DIFFUSE)
            diffuseTextureInfos.push_back({widths[i], heights[i]});
        if (type == NORMAL)
            normalTextureInfos.push_back({widths[i], heights[i]});
        MTL::Region region = MTL::Region(0, 0, 0, widths[i], heights[i], 1);
        NS::UInteger bytesPerRow = 4 * widths[i];
        
        textureArray->replaceRegion(region, 0, i, images[i], bytesPerRow, 0);
        stbi_image_free(images[i]);
    }
    
    if (type == DIFFUSE)
        diffuseTextureArray = textureArray;
    else if (type == NORMAL)
        normalTextureArray = textureArray;
}

TextureArray::~TextureArray() {
    std::cout << "TextureArray->release()" << std::endl;
    normalTextureArray->release();
    diffuseTextureArray->release();
}
