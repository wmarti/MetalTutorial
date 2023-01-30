//
//  mtl_engine.cpp
//  Metal-Guide
//

#include "mtl_engine.hpp"

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
    // ...
}

void MTLEngine::initDevice() {
    metalDevice = MTL::CreateSystemDefaultDevice();
}

void MTLEngine::initWindow() {
    glfwInit();
    glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
    glfwWindow = glfwCreateWindow(800, 800, "Metal Engine", NULL, NULL);
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
