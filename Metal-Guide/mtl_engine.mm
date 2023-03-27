//
//  mtl_engine.mm
//  MetalTutorial
//

#include "mtl_engine.hpp"

void MTLEngine::init() {
    initDevice();
    initWindow();
    
    createCube();
    createDefaultLibrary();
    createCommandQueue();
    createRenderPipeline();
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
         {{ 0.5, -0.5, -0.5, 1.0f},   {1.0f, 0.0f}} // bottom-right 2
    };
    
    cubeVertexBuffer = metalDevice->newBuffer(&cubeVertices, sizeof(cubeVertices), MTL::ResourceStorageModeShared);

    // Make sure to change working directory to Metal-Tutorial root
    // directory via Product -> Scheme -> Edit Scheme -> Run -> Options
    grassTexture = new Texture("assets/mc_grass.jpeg", metalDevice);
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
    renderPipelineDescriptor->setSampleCount(4);
    renderPipelineDescriptor->setDepthAttachmentPixelFormat(MTL::PixelFormatDepth32Float);
//    renderPipelineDescriptor->setRasterizationEnabled(true);
    renderPipelineDescriptor->setTessellationOutputWindingOrder(MTL::WindingClockwise);
    
    NS::Error* error;
    metalRenderPSO = metalDevice->newRenderPipelineState(renderPipelineDescriptor, &error);
    
    MTL::DepthStencilDescriptor* depthStencilDescriptor = MTL::DepthStencilDescriptor::alloc()->init();
    depthStencilDescriptor->setDepthCompareFunction(MTL::CompareFunctionLessEqual);
    depthStencilDescriptor->setDepthWriteEnabled(true);
    depthStencilState = metalDevice->newDepthStencilState(depthStencilDescriptor);
    
    renderPipelineDescriptor->release();
}

void MTLEngine::draw() {
    sendRenderCommand();
}

void MTLEngine::sendRenderCommand() {
    metalCommandBuffer = metalCommandQueue->commandBuffer();
    
    MTL::RenderPassDescriptor* renderPassDescriptor = MTL::RenderPassDescriptor::alloc()->init();
    MTL::RenderPassColorAttachmentDescriptor* colorAttachment = renderPassDescriptor->colorAttachments()->object(0);
    MTL::RenderPassDepthAttachmentDescriptor* depthAttachment = renderPassDescriptor->depthAttachment();

    MTL::TextureDescriptor* msaaTextureDescriptor = MTL::TextureDescriptor::alloc()->init();
    msaaTextureDescriptor->setTextureType(MTL::TextureType2DMultisample);
    msaaTextureDescriptor->setPixelFormat(MTL::PixelFormatBGRA8Unorm);
    msaaTextureDescriptor->setWidth(metalDrawable->texture()->width());
    msaaTextureDescriptor->setHeight(metalDrawable->texture()->height());
    msaaTextureDescriptor->setSampleCount(4);
    msaaTextureDescriptor->setUsage(MTL::TextureUsageRenderTarget);
    
    MTL::Texture* msaaRenderTargetTexture = metalDevice->newTexture(msaaTextureDescriptor);
    
    colorAttachment->setTexture(msaaRenderTargetTexture);
    colorAttachment->setResolveTexture(metalDrawable->texture());
    colorAttachment->setLoadAction(MTL::LoadActionClear);
    colorAttachment->setClearColor(MTL::ClearColor(41.0f/255.0f, 42.0f/255.0f, 48.0f/255.0f, 1.0));
    colorAttachment->setStoreAction(MTL::StoreActionMultisampleResolve);
    
    MTL::TextureDescriptor* depthTextureDescriptor = MTL::TextureDescriptor::alloc()->init();
    depthTextureDescriptor->setTextureType(MTL::TextureType2DMultisample);
    depthTextureDescriptor->setPixelFormat(MTL::PixelFormatDepth32Float);
    depthTextureDescriptor->setWidth(metalDrawable->texture()->width());
    depthTextureDescriptor->setHeight(metalDrawable->texture()->width());
    depthTextureDescriptor->setUsage(MTL::TextureUsageRenderTarget);
    depthTextureDescriptor->setSampleCount(4);

    MTL::Texture* depthTexture = metalDevice->newTexture(depthTextureDescriptor);
    
    depthAttachment->setTexture(depthTexture);
    depthAttachment->setLoadAction(MTL::LoadActionClear);
    depthAttachment->setStoreAction(MTL::StoreActionDontCare);
    depthAttachment->setClearDepth(1.0);
    
    MTL::RenderCommandEncoder* renderCommandEncoder = metalCommandBuffer->renderCommandEncoder(renderPassDescriptor);
    encodeRenderCommand(renderCommandEncoder);
    renderCommandEncoder->endEncoding();

    metalCommandBuffer->presentDrawable(metalDrawable);
    metalCommandBuffer->commit();
    metalCommandBuffer->waitUntilCompleted();
    
    msaaTextureDescriptor->release();
    msaaRenderTargetTexture->release();
    depthTextureDescriptor->release();
    depthTexture->release();
    renderPassDescriptor->release();
}

void MTLEngine::encodeRenderCommand(MTL::RenderCommandEncoder* renderCommandEncoder) {
    matrix_float4x4 translationMatrix = matrix_identity_float4x4;
    translationMatrix.columns[3][2] = 2;
    
    matrix_float4x4 rotationMatrix = matrix_identity_float4x4;
    float angleInDegrees = glfwGetTime() * 90;
    float angleInRadians = angleInDegrees * M_PI / 180.0f;
    float cosTheta = cos(angleInRadians);
    float sinTheta = sin(angleInRadians);
    rotationMatrix.columns[0][0] = cosTheta;
    rotationMatrix.columns[2][0] = -sinTheta;
    rotationMatrix.columns[0][2] = sinTheta;
    rotationMatrix.columns[2][2] = cosTheta;

    matrix_float4x4 modelMatrix = matrix_identity_float4x4;
    modelMatrix = simd_mul(translationMatrix, rotationMatrix);
    
    float aspectRatio = (metalLayer.frame.size.width / metalLayer.frame.size.height);
    float fov = M_PI / 2.0f;
    float nearZ = 0.1f;
    float farZ = 100.0f;
    
    matrix_float4x4 perspectiveMatrix = matrix_perspective_left_hand(fov, aspectRatio, nearZ, farZ);
    TransformationData transformationData = { modelMatrix, perspectiveMatrix };
    transformationBuffer = metalDevice->newBuffer(&transformationData, sizeof(transformationData), MTL::ResourceStorageModeShared);
    
    renderCommandEncoder->setFrontFacingWinding(MTL::WindingCounterClockwise);
    renderCommandEncoder->setCullMode(MTL::CullModeBack);
    //    renderCommandEncoder->setTriangleFillMode(MTL::TriangleFillModeLines);
    renderCommandEncoder->setRenderPipelineState(metalRenderPSO);
    renderCommandEncoder->setDepthStencilState(depthStencilState);
    renderCommandEncoder->setVertexBuffer(cubeVertexBuffer, 0, 0);
    renderCommandEncoder->setVertexBuffer(transformationBuffer, 0, 1);
    MTL::PrimitiveType typeTriangle = MTL::PrimitiveTypeTriangle;
    NS::UInteger vertexStart = 0;
    NS::UInteger vertexCount = 6 * 6;
    renderCommandEncoder->setFragmentTexture(grassTexture->texture, 0);
    renderCommandEncoder->drawPrimitives(typeTriangle, vertexStart, vertexCount);
}
