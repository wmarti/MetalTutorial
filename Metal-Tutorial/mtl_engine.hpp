//
//  mtl_engine.hpp
//  MetalTutorial
//

#pragma once

#define GLFW_INCLUDE_NONE
#import <GLFW/glfw3.h>
#define GLFW_EXPOSE_NATIVE_COCOA
#import <GLFW/glfw3native.h>
#include <stb/stb_image.h>

#include <Metal/Metal.hpp>
#include <Metal/Metal.h>
#include <QuartzCore/CAMetalLayer.hpp>
#include <QuartzCore/CAMetalLayer.h>
#include <QuartzCore/QuartzCore.hpp>
#include <simd/simd.h>

#include "VertexData.hpp"
#include "Texture.hpp"
#include "AAPLMathUtilities.h"
#include "mesh.hpp"

#include <iostream>
#include <filesystem>

class MTLEngine {
public:
    void init();
    void run();
    void cleanup();
    
private:
    void initDevice();
    void initWindow();
    
    void createCube();
    void createBuffers();
    void createDefaultLibrary();
    void createCommandQueue();
    void createRenderPipeline();
    void createLightSourceRenderPipeline();
    void createDepthAndMSAATextures();
    void createRenderPassDescriptor();
    
    // Upon resizing, update Depth and MSAA Textures.
    void updateRenderPassDescriptor();
    
    void draw();
    void sendRenderCommand();
    void encodeRenderCommand(MTL::RenderCommandEncoder* renderEncoder);
    
    static void frameBufferSizeCallback(GLFWwindow *window, int width, int height);
    void resizeFrameBuffer(int width, int height);
    
    MTL::Device* metalDevice;
    GLFWwindow* glfwWindow;
    NSWindow* metalWindow;
    CAMetalLayer* metalLayer;
    CA::MetalDrawable* metalDrawable;
    bool windowResizeFlag = false;
    int newWidth, newHeight;
    
    MTL::Library* metalDefaultLibrary;
    MTL::CommandQueue* metalCommandQueue;
    MTL::CommandBuffer* metalCommandBuffer;
    MTL::RenderPipelineState* metalRenderPSO;
    MTL::RenderPipelineState* metalLightSourceRenderPSO;
    MTL::RenderPassDescriptor* renderPassDescriptor;
    MTL::Buffer* meshVertexBuffer;
    uint64_t meshVertexCount;
    MTL::Buffer* lightVertexBuffer;
    MTL::Buffer* transformationBuffer;
    MTL::DepthStencilState* depthStencilState;
    MTL::Texture* msaaRenderTargetTexture;
    MTL::Texture* depthTexture;
    MTL::Texture* diffuseTextures;
    MTL::Buffer* diffuseTextureInfos;
    MTL::Texture* normalMaps;
    MTL::Buffer* normalTextureInfos;
    MTL::Buffer* indexBuffer;
    unsigned long indexCount;
    int sampleCount = 4;
};
