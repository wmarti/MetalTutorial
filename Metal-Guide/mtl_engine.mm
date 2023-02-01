//
//  mtl_engine.mm
//  Metal-Guide
//

#include "mtl_engine.hpp"
#include <iostream>

void MTLEngine::init() {
    initDevice();
    initWindow();
}

void MTLEngine::run() {
    while (!glfwWindowShouldClose(glfwWindow)) {
        
        glfwPollEvents();
    }
}

void MTLEngine::cleanup() {
    glfwTerminate();
}

void MTLEngine::initDevice() {
    metalDevice = MTL::CreateSystemDefaultDevice();
}

void MTLEngine::initWindow() {
    glfwInit();
    glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
    glfwWindow = glfwCreateWindow(800, 600, "Metal Engine", NULL, NULL);
    if (!glfwWindow) {
        glfwTerminate();
        exit(EXIT_FAILURE);
    }
    
    metalWindow = glfwGetCocoaWindow(glfwWindow);
    metalLayer = [CAMetalLayer layer];
    metalLayer.device = (__bridge id<MTLDevice>)metalDevice;
    metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
    metalWindow.contentView.layer = metalLayer;
    metalWindow.contentView.wantsLayer = YES;
}
