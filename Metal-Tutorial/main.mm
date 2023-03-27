//
//  main.mm
//  MetalTutorial
//

#include "mtl_engine.hpp"

int main() {
    @autoreleasepool {
        MTLEngine engine;
        engine.init();
        engine.run();
        engine.cleanup();
    }
    return 0;
}
