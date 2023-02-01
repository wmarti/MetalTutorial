//
//  main.mm
//  Metal-Guide
//

#include <iostream>

#include "mtl_engine.hpp"

int main() {
    
    MTLEngine engine;
    engine.init();
    engine.run();
    engine.cleanup();
    
    return 0;
}
