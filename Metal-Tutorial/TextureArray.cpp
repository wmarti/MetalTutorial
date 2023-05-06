//
//  TextureArray.cpp
//  Metal-Tutorial
//
#include <iostream>
#include <cmath>

#include "TextureArray.hpp"

/*
 TODO:
    - Detect maximum texture array size for given GPU
 */

TextureArray::TextureArray(std::vector<std::string>& filePaths,
                           MTL::Device* metalDevice) {
    device = metalDevice;
    loadTextures(filePaths);
    createTextureInfosBuffer();
}

void TextureArray::loadTextures(std::vector<std::string> &filePaths) {
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
    int mipLevels = std::floor(std::log2(std::max(maxImageWidth, maxImageHeight))) + 1;
    std::cout << "Mip Levels: " << mipLevels << std::endl;
    textureDescriptor->setArrayLength(images.size());
    textureDescriptor->setUsage(MTL::TextureUsageShaderRead);
    textureDescriptor->setTextureType(MTL::TextureType2DArray);
    textureDescriptor->setWidth(maxImageWidth);
    textureDescriptor->setHeight(maxImageHeight);
    textureDescriptor->setMipmapLevelCount(mipLevels);
    textureDescriptor->setPixelFormat(MTL::PixelFormatRGBA8Unorm);
    
    textureArray = device->newTexture(textureDescriptor);
    assert(textureArray != nullptr);
    textureDescriptor->release();

    std::cout << "Texture Array Width: " << textureArray->width() << std::endl;
    std::cout << "Texture Array Height: " << textureArray->height() << std::endl;

    MTL::CommandQueue* commandQueue = device->newCommandQueue();
    MTL::CommandBuffer* commandBuffer = commandQueue->commandBuffer();
    
    for (int i = 0; i < images.size(); i++) {
        textureInfos.push_back({widths[i], heights[i]});            
            
        MTL::Region region = MTL::Region(0, 0, 0, widths[i], heights[i], 1);
        NS::UInteger bytesPerRow = 4 * widths[i];
        
        textureArray->replaceRegion(region, 0, i, images[i], bytesPerRow, 0);
        
        MTL::BlitCommandEncoder* blitEncoder = commandBuffer->blitCommandEncoder();
        blitEncoder->generateMipmaps(textureArray);
        blitEncoder->endEncoding();
        stbi_image_free(images[i]);
    }
    commandBuffer->commit();
    commandBuffer->waitUntilCompleted();
    commandQueue->release();
}

void TextureArray::createTextureInfosBuffer() {
    // Create Texture Info Buffer
    size_t bufferSize = textureInfos.size() * sizeof(TextureInfo);
    std::cout << "Texture Count: " << textureInfos.size() << std::endl;
    std::cout << "TextureInfos size: " << bufferSize << std::endl;
    textureInfosBuffer = device->newBuffer(textureInfos.data(), bufferSize, MTL::ResourceStorageModeShared);
    textureInfosBuffer->setLabel(NS::String::string("Texture Info Array", NS::ASCIIStringEncoding));
}

TextureArray::~TextureArray() {
    std::cout << "TextureArray->release()" << std::endl;
    textureInfosBuffer->release();
    textureArray->release();
}
