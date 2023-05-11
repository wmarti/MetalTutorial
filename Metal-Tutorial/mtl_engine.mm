//
//  mtl_engine.mm
//  MetalTutorial
//

#include "mtl_engine.hpp"

void MTLEngine::init() {
    initDevice();
    initWindow();
    
    createCube();
    createBuffers();
    createDefaultLibrary();
    createCommandQueue();
    createRenderPipeline();
    createDepthAndMSAATextures();
    createRenderPassDescriptor();
}

void MTLEngine::run() {
    while (!glfwWindowShouldClose(glfwWindow)) {
        @autoreleasepool {
            metalDrawable = (__bridge CA::MetalDrawable*)[metalLayer nextDrawable];
            draw();
        }
        glfwPollEvents();
    }
}

void MTLEngine::cleanup() {
    glfwTerminate();
    transformationBuffer->release();
    msaaRenderTargetTexture->release();
    depthTexture->release();
    renderPassDescriptor->release();
    metalDevice->release();
    delete grassTexture;
}

void MTLEngine::initDevice() {
    metalDevice = MTL::CreateSystemDefaultDevice();
}

void MTLEngine::frameBufferSizeCallback(GLFWwindow *window, int width, int height) {
    MTLEngine* engine = (MTLEngine*)glfwGetWindowUserPointer(window);
    engine->resizeFrameBuffer(width, height);
}

void MTLEngine::resizeFrameBuffer(int width, int height) {
    metalLayer.drawableSize = CGSizeMake(width, height);
    // Deallocate the textures if they have been created
    if (msaaRenderTargetTexture) {
        msaaRenderTargetTexture->release();
        msaaRenderTargetTexture = nullptr;
    }
    if (depthTexture) {
        depthTexture->release();
        depthTexture = nullptr;
    }
    createDepthAndMSAATextures();
    metalDrawable = (__bridge CA::MetalDrawable*)[metalLayer nextDrawable];
    updateRenderPassDescriptor();
}

void MTLEngine::initWindow() {
    glfwInit();
    glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
    glfwWindow = glfwCreateWindow(800, 600, "Metal Engine", NULL, NULL);
    
    if (!glfwWindow) {
        glfwTerminate();
        exit(EXIT_FAILURE);
    }
    
    glfwSetWindowUserPointer(glfwWindow, this);
    glfwSetFramebufferSizeCallback(glfwWindow, frameBufferSizeCallback);
    int width, height;
    glfwGetFramebufferSize(glfwWindow, &width, &height);
    
    metalWindow = glfwGetCocoaWindow(glfwWindow);
    metalLayer = [CAMetalLayer layer];
    metalLayer.device = (__bridge id<MTLDevice>)metalDevice;
    metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
    metalLayer.drawableSize = CGSizeMake(width, height);
    metalWindow.contentView.layer = metalLayer;
    metalWindow.contentView.wantsLayer = YES;
    
    metalDrawable = (__bridge CA::MetalDrawable*)[metalLayer nextDrawable];
}

void MTLEngine::createCube() {
    VertexData cubeVertices[] = {
        // Back face
         {{ 0.5, -0.5, -0.5, 1.0f},  {1.0f, 0.0f}}, // bottom-right 2
         {{ 0.5,  0.5, -0.5, 1.0f},  {1.0f, 1.0f}}, // top-right    3
         {{-0.5,  0.5, -0.5, 1.0f},  {0.0f, 1.0f}}, // top-left     1
         {{ 0.5, -0.5, -0.5, 1.0f},  {1.0f, 0.0f}}, // bottom-right 2
         {{-0.5,  0.5, -0.5, 1.0f},  {0.0f, 1.0f}}, // top-left     1
         {{-0.5, -0.5, -0.5, 1.0f},  {0.0f, 0.0f}}, // bottom-left  0
        // Right face
         {{0.5, -0.5,  0.5, 1.0f},  {0.0f, 0.0f}}, // bottom-right 6
         {{0.5,  0.5,  0.5, 1.0f},  {0.0f, 1.0f}}, // top-right    7
         {{0.5,  0.5, -0.5, 1.0f},  {1.0f, 1.0f}}, // top-right    3
         {{0.5, -0.5,  0.5, 1.0f},  {0.0f, 0.0f}}, // bottom-right 6
         {{0.5,  0.5, -0.5, 1.0f},  {1.0f, 1.0f}}, // top-right    3
         {{0.5, -0.5, -0.5, 1.0f},  {1.0f, 0.0f}}, // bottom-right 2
        // Front face
         {{-0.5, -0.5,  0.5, 1.0f},  {0.0f, 0.0f}}, // bottom-left  4
         {{-0.5,  0.5,  0.5, 1.0f},  {0.0f, 1.0f}}, // top-left     5
         {{ 0.5,  0.5,  0.5, 1.0f},  {1.0f, 1.0f}}, // top-right    7
         {{-0.5, -0.5,  0.5, 1.0f},  {0.0f, 0.0f}}, // bottom-left  4
         {{ 0.5,  0.5,  0.5, 1.0f},  {1.0f, 1.0f}}, // top-right    7
         {{ 0.5, -0.5,  0.5, 1.0f},  {1.0f, 0.0f}}, // bottom-right 6
        // Left face
         {{-0.5, -0.5, -0.5, 1.0f},  {0.0f, 0.0f}}, // bottom-left  0
         {{-0.5,  0.5, -0.5, 1.0f},  {0.0f, 1.0f}}, // top-left     1
         {{-0.5,  0.5,  0.5, 1.0f},  {1.0f, 1.0f}}, // top-left     5
         {{-0.5, -0.5, -0.5, 1.0f},  {0.0f, 0.0f}}, // bottom-left  0
         {{-0.5,  0.5,  0.5, 1.0f},  {1.0f, 1.0f}}, // top-left     5
         {{-0.5, -0.5,  0.5, 1.0f},  {1.0f, 0.0f}}, // bottom-left  4
        // Top face
         {{-0.5,  0.5,  0.5, 1.0f},  {0.0f, 0.0f}}, // top-left     5
         {{-0.5,  0.5, -0.5, 1.0f},  {0.0f, 1.0f}}, // top-left     1
         {{ 0.5,  0.5, -0.5, 1.0f},  {1.0f, 1.0f}}, // top-right    3
         {{-0.5,  0.5,  0.5, 1.0f},  {0.0f, 0.0f}}, // top-left     5
         {{ 0.5,  0.5, -0.5, 1.0f},  {1.0f, 1.0f}}, // top-right    3
         {{ 0.5,  0.5,  0.5, 1.0f},  {1.0f, 0.0f}}, // top-right    7
        // Bottom face
         {{-0.5, -0.5, -0.5, 1.0f},   {0.0f, 0.0f}}, // bottom-left  0
         {{-0.5, -0.5,  0.5, 1.0f},   {0.0f, 1.0f}}, // bottom-left  4
         {{ 0.5, -0.5,  0.5, 1.0f},   {1.0f, 1.0f}}, // bottom-right 6
         {{-0.5, -0.5, -0.5, 1.0f},   {0.0f, 0.0f}}, // bottom-left  0
         {{ 0.5, -0.5,  0.5, 1.0f},   {1.0f, 1.0f}}, // bottom-right 6
         {{ 0.5, -0.5, -0.5, 1.0f},   {1.0f, 0.0f}}  // bottom-right 2
    };
    
    cubeVertexBuffer = metalDevice->newBuffer(&cubeVertices, sizeof(cubeVertices), MTL::ResourceStorageModeShared);

    // Make sure to change working directory to Metal-Tutorial root
    // directory via Product -> Scheme -> Edit Scheme -> Run -> Options
    grassTexture = new Texture("assets/mc_grass.jpeg", metalDevice);
}

void MTLEngine::createBuffers() {
    transformationBuffer = metalDevice->newBuffer(sizeof(TransformationData), MTL::ResourceStorageModeShared);
}

void MTLEngine::createDefaultLibrary() {
    metalDefaultLibrary = metalDevice->newDefaultLibrary();
    if(!metalDefaultLibrary){
        std::cerr << "Failed to load default library.";
        std::exit(-1);
    }
}

void MTLEngine::createCommandQueue() {
    metalCommandQueue = metalDevice->newCommandQueue();
}

void MTLEngine::createRenderPipeline() {
    MTL::Function* vertexShader = metalDefaultLibrary->newFunction(NS::String::string("vertexShader", NS::ASCIIStringEncoding));
    assert(vertexShader);
    MTL::Function* fragmentShader = metalDefaultLibrary->newFunction(NS::String::string("fragmentShader", NS::ASCIIStringEncoding));
    assert(fragmentShader);
    
    MTL::RenderPipelineDescriptor* renderPipelineDescriptor = MTL::RenderPipelineDescriptor::alloc()->init();
    renderPipelineDescriptor->setVertexFunction(vertexShader);
    renderPipelineDescriptor->setFragmentFunction(fragmentShader);
    assert(renderPipelineDescriptor);
    MTL::PixelFormat pixelFormat = (MTL::PixelFormat)metalLayer.pixelFormat;
    renderPipelineDescriptor->colorAttachments()->object(0)->setPixelFormat(pixelFormat);
    renderPipelineDescriptor->setSampleCount(sampleCount);
    renderPipelineDescriptor->setDepthAttachmentPixelFormat(MTL::PixelFormatDepth32Float);
    
    NS::Error* error;
    metalRenderPSO = metalDevice->newRenderPipelineState(renderPipelineDescriptor, &error);
    
    if (metalRenderPSO == nil) {
        std::cout << "Error creating render pipeline state: " << error << std::endl;
        std::exit(0);
    }
    
    MTL::DepthStencilDescriptor* depthStencilDescriptor = MTL::DepthStencilDescriptor::alloc()->init();
    depthStencilDescriptor->setDepthCompareFunction(MTL::CompareFunctionLessEqual);
    depthStencilDescriptor->setDepthWriteEnabled(true);
    depthStencilState = metalDevice->newDepthStencilState(depthStencilDescriptor);
    
    renderPipelineDescriptor->release();
    vertexShader->release();
    fragmentShader->release();
}

void MTLEngine::createDepthAndMSAATextures() {
    MTL::TextureDescriptor* msaaTextureDescriptor = MTL::TextureDescriptor::alloc()->init();
    msaaTextureDescriptor->setTextureType(MTL::TextureType2DMultisample);
    msaaTextureDescriptor->setPixelFormat(MTL::PixelFormatBGRA8Unorm);
    msaaTextureDescriptor->setWidth(metalLayer.drawableSize.width);
    msaaTextureDescriptor->setHeight(metalLayer.drawableSize.height);
    msaaTextureDescriptor->setSampleCount(sampleCount);
    msaaTextureDescriptor->setUsage(MTL::TextureUsageRenderTarget);

    msaaRenderTargetTexture = metalDevice->newTexture(msaaTextureDescriptor);

    MTL::TextureDescriptor* depthTextureDescriptor = MTL::TextureDescriptor::alloc()->init();
    depthTextureDescriptor->setTextureType(MTL::TextureType2DMultisample);
    depthTextureDescriptor->setPixelFormat(MTL::PixelFormatDepth32Float);
    depthTextureDescriptor->setWidth(metalLayer.drawableSize.width);
    depthTextureDescriptor->setHeight(metalLayer.drawableSize.height);
    depthTextureDescriptor->setUsage(MTL::TextureUsageRenderTarget);
    depthTextureDescriptor->setSampleCount(sampleCount);

    depthTexture = metalDevice->newTexture(depthTextureDescriptor);

    msaaTextureDescriptor->release();
    depthTextureDescriptor->release();
}

void MTLEngine::createRenderPassDescriptor() {
    renderPassDescriptor = MTL::RenderPassDescriptor::alloc()->init();
    
    MTL::RenderPassColorAttachmentDescriptor* colorAttachment = renderPassDescriptor->colorAttachments()->object(0);
    MTL::RenderPassDepthAttachmentDescriptor* depthAttachment = renderPassDescriptor->depthAttachment();

    colorAttachment->setTexture(msaaRenderTargetTexture);
    colorAttachment->setResolveTexture(metalDrawable->texture());
    colorAttachment->setLoadAction(MTL::LoadActionClear);
    colorAttachment->setClearColor(MTL::ClearColor(41.0f/255.0f, 42.0f/255.0f, 48.0f/255.0f, 1.0));
    colorAttachment->setStoreAction(MTL::StoreActionMultisampleResolve);
    
    depthAttachment->setTexture(depthTexture);
    depthAttachment->setLoadAction(MTL::LoadActionClear);
    depthAttachment->setStoreAction(MTL::StoreActionDontCare);
    depthAttachment->setClearDepth(1.0);
}

void MTLEngine::updateRenderPassDescriptor() {
    renderPassDescriptor->colorAttachments()->object(0)->setTexture(msaaRenderTargetTexture);
    renderPassDescriptor->colorAttachments()->object(0)->setResolveTexture(metalDrawable->texture());
    renderPassDescriptor->depthAttachment()->setTexture(depthTexture);
}

void MTLEngine::draw() {
    sendRenderCommand();
}

void MTLEngine::sendRenderCommand() {
    metalCommandBuffer = metalCommandQueue->commandBuffer();
    
    updateRenderPassDescriptor();
    MTL::RenderCommandEncoder* renderCommandEncoder = metalCommandBuffer->renderCommandEncoder(renderPassDescriptor);
    encodeRenderCommand(renderCommandEncoder);
    renderCommandEncoder->endEncoding();

    metalCommandBuffer->presentDrawable(metalDrawable);
    metalCommandBuffer->commit();
    metalCommandBuffer->waitUntilCompleted();
}

void MTLEngine::encodeRenderCommand(MTL::RenderCommandEncoder* renderCommandEncoder) {
    matrix_float4x4 translationMatrix = matrix4x4_translation(0, 0, -2);
    
    float angleInDegrees = glfwGetTime() * -90;
    float angleInRadians = angleInDegrees * M_PI / 180.0f;
    matrix_float4x4 rotationMatrix = matrix4x4_rotation(angleInRadians, 0.0, -1.0, 0.0);

    matrix_float4x4 modelMatrix = matrix_identity_float4x4;
    modelMatrix = simd_mul(translationMatrix, rotationMatrix);
    
    float aspectRatio = (metalLayer.frame.size.width / metalLayer.frame.size.height);
    float fov = M_PI / 2.0f;
    float nearZ = 0.1f;
    float farZ = 100.0f;
    
    matrix_float4x4 perspectiveMatrix = matrix_perspective_right_hand(fov, aspectRatio, nearZ, farZ);
    TransformationData transformationData = { modelMatrix, perspectiveMatrix };
    memcpy(transformationBuffer->contents(), &transformationData, sizeof(transformationData));
    
    renderCommandEncoder->setFrontFacingWinding(MTL::WindingClockwise);
    renderCommandEncoder->setCullMode(MTL::CullModeBack);
//    renderCommandEncoder->setTriangleFillMode(MTL::TriangleFillModeLines);
    renderCommandEncoder->setRenderPipelineState(metalRenderPSO);
    renderCommandEncoder->setDepthStencilState(depthStencilState);
    renderCommandEncoder->setVertexBuffer(cubeVertexBuffer, 0, 0);
    renderCommandEncoder->setVertexBuffer(transformationBuffer, 0, 1);
    MTL::PrimitiveType typeTriangle = MTL::PrimitiveTypeTriangle;
    NS::UInteger vertexStart = 0;
    NS::UInteger vertexCount = 36;
    renderCommandEncoder->setFragmentTexture(grassTexture->texture, 0);
    renderCommandEncoder->drawPrimitives(typeTriangle, vertexStart, vertexCount);
}
