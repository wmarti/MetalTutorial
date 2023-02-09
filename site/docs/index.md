# Welcome to Metal
## Introduction
Welcome to the Metal Tutorial. This tutorial will teach you the basics of the Metal graphics and compute API, and help you understand how to program with it in C++ via the `metal-cpp` library that Apple has now officially released. The documentation for it is non-existant, and it is missing some key features, so I'll show you how to work around those in the following chapters. This will not necessarily serve as a guide or introduction to Computer Graphics, but more as a way to get up and running with Metal using C++. For those who are completely new, I'll try to go over everything in as much detail as I possibly can, and link to other existing guides for more information when needed. I hope that this can be of use to you. If you'd like to contribute your own content to the tutorial series, or correct any mistakes that I've made, you can find the github repository [here](https://github.com/wmarti/MetalTutorial).

## Metal Documenation and Other Useful Resources
Here are some resources that you may find helpful both while completing these tutorials, as well as when using Metal more generally:
### Official Apple Metal Documentation
- [Metal Documentation](https://developer.apple.com/documentation/metal)
- [Metal Specification](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf)
- [Creating and Sampling Textures](https://developer.apple.com/documentation/metal/creating_and_sampling_textures)
- [Creating Threads and Threadgroups](https://developer.apple.com/documentation/metal/creating_threads_and_threadgroups)

### Useful Metal Resources
- [Intro to Metal Compute](https://eugenebokhan.io/introduction-to-metal-compute-part-four)
- [Constant vs Device Address Space](https://stackoverflow.com/questions/59010429/what-the-purpose-of-declaring-a-variable-with-const-constant)
- ["Pass by reference" in Metal](https://stackoverflow.com/questions/39266789/glsl-out-in-the-argument)
- [Metal Best Practices Guide (Drawables)](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/MTLBestPracticesGuide/Drawables.html#//apple_ref/doc/uid/TP40016642-CH2-SW1)
- [Metal-CPP discussion reddit](https://www.reddit.com/r/GraphicsProgramming/comments/qzyqjz/metalcpp_is_a_lowoverhead_c_interface_for_metal/)

### Computer Graphics Fundamentals
- [Linear Algebra](https://www.3blue1brown.com/topics/linear-algebra)

### Ray Tracing
- [GPU Ray-Tracing in One an Afternoon](https://roar11.com/2019/10/gpu-ray-tracing-in-an-afternoon/)
- [GPU Ray-Tracing in One Weekend](https://scribe.citizen4.eu/@jcowles/gpu-ray-tracing-in-one-weekend-3e7d874b3b0f)
- [CUDA Compute Ray-Tracing](https://developer.nvidia.com/blog/accelerated-ray-tracing-cuda/)
- [GPU Accelerated Path-Tracer (hemispheres/rand)](https://bheisler.github.io/post/writing-gpu-accelerated-path-tracer-part-2/)
- [Random Number Generation and Sampling (like on hemisphere)](https://cseweb.ucsd.edu/classes/sp17/cse168-a/CSE168_07_Random.pdf)
