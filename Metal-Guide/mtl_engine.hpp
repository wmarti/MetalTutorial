//
//  mtl_engine.hpp
//  MetalTutorial
//

#pragma once

#define GLFW_INCLUDE_NONE
#import <GLFW/glfw3.h>
#define GLFW_EXPOSE_NATIVE_COCOA
#import <GLFW/glfw3native.h>

#include <Metal/Metal.hpp>
#include <Metal/Metal.h>
#include <QuartzCore/CAMetalLayer.hpp>
#include <QuartzCore/CAMetalLayer.h>
#include <QuartzCore/QuartzCore.hpp>
#include <simd/simd.h>


#include "VertexData.hpp"
#include "Texture.hpp"
#include <stb/stb_image.h>
#include "AAPLMathUtilities.h"

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
    void createDefaultLibrary();
    void createCommandQueue();
    void createRenderPipeline();
    void createLightSourceRenderPipeline();
    
    void encodeRenderCommand(MTL::RenderCommandEncoder* renderEncoder);
    void sendRenderCommand();
    void draw();
    
    static void framebuffer_size_callback(GLFWwindow* window, int width, int height);
    
    MTL::Device* metalDevice;
    GLFWwindow* glfwWindow;
    NSWindow* metalWindow;
    CAMetalLayer* metalLayer;
    CA::MetalDrawable* metalDrawable;
    
    MTL::Library* metalDefaultLibrary;
    MTL::CommandQueue* metalCommandQueue;
    MTL::CommandBuffer* metalCommandBuffer;
    MTL::RenderPipelineState* metalRenderPSO;
    MTL::RenderPipelineState* metalLightSourceRenderPSO;
    MTL::Buffer* cubeVertexBuffer;
    MTL::Buffer* lightVertexBuffer;
    MTL::Buffer* transformationBuffer;
    MTL::DepthStencilState* depthStencilState;
    
    Texture* grassTexture;
};
