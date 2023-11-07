//
//  mtl_engine.mm
//  MetalTutorial
//

#include "mtl_engine.hpp"

void MTLEngine::init() {
    initDevice();
    initWindow();
    
    createSphere();
    createLight();
    createBuffers();
    createDefaultLibrary();
    createCommandQueue();
    createRenderPipeline();
    createLightSourceRenderPipeline();
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
    sphereTransformationBuffer->release();
    lightTransformationBuffer->release();
    msaaRenderTargetTexture->release();
    depthTexture->release();
    renderPassDescriptor->release();
    metalDevice->release();
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

void MTLEngine::createSphere(int numLatitudeLines, int numLongitudeLines) {
    std::vector<VertexData> vertices;
    const float PI = 3.14159265359f;

    for (int lat = 0; lat < numLatitudeLines; ++lat) {
        for (int lon = 0; lon < numLongitudeLines; ++lon) {
            // Define the corners of the square
            std::array<simd::float4, 4> squareVertices;
            
            for (int i = 0; i < 4; ++i) {
                float theta = (lat + (i / 2)) * PI / numLatitudeLines;
                float phi = (lon + (i % 2)) * 2 * PI / numLongitudeLines;
                float sinTheta = sinf(theta);
                float cosTheta = cosf(theta);
                float sinPhi = sinf(phi);
                float cosPhi = cosf(phi);

                squareVertices[i] = {cosPhi * sinTheta, cosTheta, sinPhi * sinTheta, 1.0f};
            }

            // Calculate the normal for the square (use the first triangle to compute it)
            simd::float3 edge1 = squareVertices[1].xyz - squareVertices[0].xyz;
            simd::float3 edge2 = squareVertices[3].xyz - squareVertices[0].xyz;
            simd::float3 faceNormal = simd::cross(edge1, edge2);
            faceNormal = simd::normalize(faceNormal);
            simd::float4 normal = {faceNormal.x, faceNormal.y, faceNormal.z, 0.0f};

            // Create two triangles for the square face with counter-clockwise winding order
            vertices.push_back(VertexData{squareVertices[0], normal}); // First triangle
            vertices.push_back(VertexData{squareVertices[1], normal});
            vertices.push_back(VertexData{squareVertices[2], normal});

            vertices.push_back(VertexData{squareVertices[1], normal}); // Second triangle
            vertices.push_back(VertexData{squareVertices[3], normal});
            vertices.push_back(VertexData{squareVertices[2], normal});
        }
    }
    sphereVertexBuffer = metalDevice->newBuffer(vertices.data(), sizeof(VertexData) * vertices.size(), MTL::ResourceStorageModeShared);

    vertexCount = vertices.size();
}

void MTLEngine::createLight() {
    // Cube for use in a right-handed coordinate system with triangle faces
    // specified with a Counter-Clockwise winding order.
    VertexData lightSource[] = {
        // Front face            // Normals
        {{-0.5,-0.5, 0.5, 1.0}, {0.0, 0.0, 1.0, 1.0}},
        {{ 0.5,-0.5, 0.5, 1.0}, {0.0, 0.0, 1.0, 1.0}},
        {{ 0.5, 0.5, 0.5, 1.0}, {0.0, 0.0, 1.0, 1.0}},
        {{ 0.5, 0.5, 0.5, 1.0}, {0.0, 0.0, 1.0, 1.0}},
        {{-0.5, 0.5, 0.5, 1.0}, {0.0, 0.0, 1.0, 1.0}},
        {{-0.5,-0.5, 0.5, 1.0}, {0.0, 0.0, 1.0, 1.0}},
        
        // Back face
        {{ 0.5,-0.5,-0.5, 1.0}, {0.0, 0.0,-1.0, 1.0}},
        {{-0.5,-0.5,-0.5, 1.0}, {0.0, 0.0,-1.0, 1.0}},
        {{-0.5, 0.5,-0.5, 1.0}, {0.0, 0.0,-1.0, 1.0}},
        {{-0.5, 0.5,-0.5, 1.0}, {0.0, 0.0,-1.0, 1.0}},
        {{ 0.5, 0.5,-0.5, 1.0}, {0.0, 0.0,-1.0, 1.0}},
        {{ 0.5,-0.5,-0.5, 1.0}, {0.0, 0.0,-1.0, 1.0}},

        // Top face
        {{-0.5, 0.5, 0.5, 1.0}, {0.0, 1.0, 0.0, 1.0}},
        {{ 0.5, 0.5, 0.5, 1.0}, {0.0, 1.0, 0.0, 1.0}},
        {{ 0.5, 0.5,-0.5, 1.0}, {0.0, 1.0, 0.0, 1.0}},
        {{ 0.5, 0.5,-0.5, 1.0}, {0.0, 1.0, 0.0, 1.0}},
        {{-0.5, 0.5,-0.5, 1.0}, {0.0, 1.0, 0.0, 1.0}},
        {{-0.5, 0.5, 0.5, 1.0}, {0.0, 1.0, 0.0, 1.0}},

        // Bottom face
        {{-0.5,-0.5,-0.5, 1.0}, {0.0,-1.0, 0.0, 1.0}},
        {{ 0.5,-0.5,-0.5, 1.0}, {0.0,-1.0, 0.0, 1.0}},
        {{ 0.5,-0.5, 0.5, 1.0}, {0.0,-1.0, 0.0, 1.0}},
        {{ 0.5,-0.5, 0.5, 1.0}, {0.0,-1.0, 0.0, 1.0}},
        {{-0.5,-0.5, 0.5, 1.0}, {0.0,-1.0, 0.0, 1.0}},
        {{-0.5,-0.5,-0.5, 1.0}, {0.0,-1.0, 0.0, 1.0}},

        // Left face
        {{-0.5,-0.5,-0.5, 1.0}, {-1.0,0.0, 0.0, 1.0}},
        {{-0.5,-0.5, 0.5, 1.0}, {-1.0,0.0, 0.0, 1.0}},
        {{-0.5, 0.5, 0.5, 1.0}, {-1.0,0.0, 0.0, 1.0}},
        {{-0.5, 0.5, 0.5, 1.0}, {-1.0,0.0, 0.0, 1.0}},
        {{-0.5, 0.5,-0.5, 1.0}, {-1.0,0.0, 0.0, 1.0}},
        {{-0.5,-0.5,-0.5, 1.0}, {-1.0,0.0, 0.0, 1.0}},

        // Right face
        {{ 0.5,-0.5, 0.5, 1.0}, {1.0, 0.0, 0.0, 1.0}},
        {{ 0.5,-0.5,-0.5, 1.0}, {1.0, 0.0, 0.0, 1.0}},
        {{ 0.5, 0.5,-0.5, 1.0}, {1.0, 0.0, 0.0, 1.0}},
        {{ 0.5, 0.5,-0.5, 1.0}, {1.0, 0.0, 0.0, 1.0}},
        {{ 0.5, 0.5, 0.5, 1.0}, {1.0, 0.0, 0.0, 1.0}},
        {{ 0.5,-0.5, 0.5, 1.0}, {1.0, 0.0, 0.0, 1.0}},
    };
    
    lightVertexBuffer = metalDevice->newBuffer(&lightSource, sizeof(lightSource), MTL::ResourceStorageModeShared);
}

void MTLEngine::createBuffers() {
    sphereTransformationBuffer = metalDevice->newBuffer(sizeof(TransformationData), MTL::ResourceStorageModeShared);
    lightTransformationBuffer = metalDevice->newBuffer(sizeof(TransformationData), MTL::ResourceStorageModeShared);
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
    MTL::Function* vertexShader = metalDefaultLibrary->newFunction(NS::String::string("sphereVertexShader", NS::ASCIIStringEncoding));
    assert(vertexShader);
    MTL::Function* fragmentShader = metalDefaultLibrary->newFunction(NS::String::string("sphereFragmentShader", NS::ASCIIStringEncoding));
    assert(fragmentShader);
    
    MTL::RenderPipelineDescriptor* renderPipelineDescriptor = MTL::RenderPipelineDescriptor::alloc()->init();
    renderPipelineDescriptor->setVertexFunction(vertexShader);
    renderPipelineDescriptor->setFragmentFunction(fragmentShader);
    assert(renderPipelineDescriptor);
    MTL::PixelFormat pixelFormat = (MTL::PixelFormat)metalLayer.pixelFormat;
    renderPipelineDescriptor->colorAttachments()->object(0)->setPixelFormat(pixelFormat);
    renderPipelineDescriptor->setSampleCount(4);
    renderPipelineDescriptor->setLabel(NS::String::string("Sphere Render Pipeline", NS::ASCIIStringEncoding));
    renderPipelineDescriptor->setDepthAttachmentPixelFormat(MTL::PixelFormatDepth32Float);
    renderPipelineDescriptor->setTessellationOutputWindingOrder(MTL::WindingClockwise);
    
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

void MTLEngine::createLightSourceRenderPipeline() {
    MTL::Function* vertexShader = metalDefaultLibrary->newFunction(NS::String::string("lightVertexShader", NS::ASCIIStringEncoding));
    assert(vertexShader);
    MTL::Function* fragmentShader = metalDefaultLibrary->newFunction(NS::String::string("lightFragmentShader", NS::ASCIIStringEncoding));
    assert(fragmentShader);
    
    MTL::RenderPipelineDescriptor* renderPipelineDescriptor = MTL::RenderPipelineDescriptor::alloc()->init();
    renderPipelineDescriptor->setVertexFunction(vertexShader);
    renderPipelineDescriptor->setFragmentFunction(fragmentShader);
    assert(renderPipelineDescriptor);
    MTL::PixelFormat pixelFormat = (MTL::PixelFormat)metalLayer.pixelFormat;
    renderPipelineDescriptor->colorAttachments()->object(0)->setPixelFormat(pixelFormat);
    renderPipelineDescriptor->setSampleCount(4);
    renderPipelineDescriptor->setLabel(NS::String::string("Light Source Render Pipeline", NS::ASCIIStringEncoding));
    renderPipelineDescriptor->setDepthAttachmentPixelFormat(MTL::PixelFormatDepth32Float);
    renderPipelineDescriptor->setTessellationOutputWindingOrder(MTL::WindingClockwise);
    
    NS::Error* error;
    metalLightSourceRenderPSO = metalDevice->newRenderPipelineState(renderPipelineDescriptor, &error);
    
    renderPipelineDescriptor->release();
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
    // Moves the Sphere 1 unit down the negative Z-axis
    matrix_float4x4 translationMatrix = matrix4x4_translation(0.0f, 0.0f, -1.0);
    matrix_float4x4 scaleMatrix = matrix4x4_scale(0.5, 0.5, 0.5);

    matrix_float4x4 modelMatrix = matrix_multiply(translationMatrix, scaleMatrix);
    
    simd::float3 R = simd::float3 {1, 0, 0}; // Unit-Right
    simd::float3 U = simd::float3 {0, 1, 0}; // Unit-Up
    simd::float3 F = simd::float3 {0, 0,-1}; // Unit-Forward
    simd::float3 P = simd::float3 {0, 0, 0}; // Camera Position in World Space
    
    matrix_float4x4 viewMatrix = matrix_make_rows(R.x, R.y, R.z, dot(-R, P),
                                                  U.x, U.y, U.z, dot(-U, P),
                                                 -F.x,-F.y,-F.z, dot( F, P),
                                                  0, 0, 0, 1);
    
    float aspectRatio = (metalLayer.frame.size.width / metalLayer.frame.size.height);
    float fov = 90 * (M_PI / 180.0f);
    float nearZ = 0.1f;
    float farZ = 100.0f;
    
    matrix_float4x4 perspectiveMatrix = matrix_perspective_right_hand(fov, aspectRatio, nearZ, farZ);
    TransformationData transformationData = { modelMatrix, viewMatrix, perspectiveMatrix };
    memcpy(sphereTransformationBuffer->contents(), &transformationData, sizeof(transformationData));
    
    // Sphere Vertex Shader Data
    simd_float4 sphereColor = simd_make_float4(0.5, 0.9, 0.7, 1.0);
    simd_float4 lightColor = simd_make_float4(1.0, 1.0, 1.0, 1.0);
    simd_float4 lightPosition = simd_make_float4(-2.5, 1.5, 1, 1);
    simd_float4 cameraPosition = simd_make_float4(P.xyz, 1.0);

    renderCommandEncoder->setVertexBytes(&sphereColor, sizeof(sphereColor), 2);
    renderCommandEncoder->setVertexBytes(&lightColor, sizeof(lightColor), 3);
    renderCommandEncoder->setVertexBytes(&lightPosition, sizeof(lightPosition), 4);
    renderCommandEncoder->setVertexBytes(&cameraPosition, sizeof(cameraPosition), 5);
    
    renderCommandEncoder->setFrontFacingWinding(MTL::WindingCounterClockwise);
    renderCommandEncoder->setCullMode(MTL::CullModeBack);
//    renderCommandEncoder->setTriangleFillMode(MTL::TriangleFillModeLines);
    renderCommandEncoder->setRenderPipelineState(metalRenderPSO);
    renderCommandEncoder->setDepthStencilState(depthStencilState);
    renderCommandEncoder->setVertexBuffer(sphereVertexBuffer, 0, 0);
    renderCommandEncoder->setVertexBuffer(sphereTransformationBuffer, 0, 1);
    MTL::PrimitiveType typeTriangle = MTL::PrimitiveTypeTriangle;

    renderCommandEncoder->drawPrimitives(typeTriangle, (NS::UInteger)0, vertexCount);

    scaleMatrix = matrix4x4_scale(0.25f, 0.25f, 0.25f);
    translationMatrix = matrix4x4_translation(lightPosition.xyz);
    
    modelMatrix = simd_mul(translationMatrix, scaleMatrix);
        
    renderCommandEncoder->setRenderPipelineState(metalLightSourceRenderPSO);

    transformationData = { modelMatrix, viewMatrix, perspectiveMatrix };
    memcpy(lightTransformationBuffer->contents(), &transformationData, sizeof(transformationData));
    
    renderCommandEncoder->setVertexBuffer(lightVertexBuffer, 0, 0);
    renderCommandEncoder->setVertexBuffer(lightTransformationBuffer, 0, 1);

    renderCommandEncoder->setFragmentBytes(&lightColor, sizeof(lightColor), 0);
    renderCommandEncoder->drawPrimitives(typeTriangle, (NS::UInteger)0, (NS::UInteger)36);
}
