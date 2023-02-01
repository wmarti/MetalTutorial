//
//  main.cpp
//  Metal-Guide
//

#include <Metal/Metal.hpp>

#include <iostream>

int main(int argc, const char * argv[]) {
    // insert code here...
    
    MTL::Device* metalDevice = MTL::CreateSystemDefaultDevice();
    
    std::cout << "Hello, World from Metal-CPP!\n";
    return 0;
}
