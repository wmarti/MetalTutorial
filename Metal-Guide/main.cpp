//
//  main.cpp
//  Metal-Guide
//

#define NS_PRIVATE_IMPLEMENTATION
#define CA_PRIVATE_IMPLEMENTATION
#define MTL_PRIVATE_IMPLEMENTATION
#include <Foundation/Foundation.hpp>
#include <Metal/Metal.hpp>
#include <QuartzCore/QuartzCore.hpp>

#include <iostream>

int main(int argc, const char * argv[]) {
    // insert code here...
    
    MTL::Device* metalDevice = MTL::CreateSystemDefaultDevice();
    
    std::cout << "Hello, World from Metal-CPP!\n";
    return 0;
}
