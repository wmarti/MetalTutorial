title: Lesson 0: Setup

# Setting up Xcode for use with `metal-cpp`

In order to write Metal code, either for an iOS based device or MacOS, we're pretty much going to need Xcode. Development for Apple devices can be done in other editors, but it is not recommended, as Xcode is created by Apple specifically for development within its ecosystem. If you don't have it already, you can download it for free from the [Mac App Store](https://apps.apple.com/us/app/xcode/id497799835?mt=12). 

Metal is designed to be written in a programming language called Objective-C. Objective-C, along with Apple's Swift programming language, are the languages typically used to write macOS and iOS applications. In this tutorial series, however, we're going to be writing our application primarily in C++, as this is the industry standard for writing Computer Graphics related applications, whether it be for real-time rendering in video games, or for CAD software. I say "primarily" because we'll actually be using a bit of "Objective-C++", which allows us to mix Objective-C code with C++ to make things a little easier for us. Even though Metal is typically written in pure Objective-C, for convenience Apple has released a set of C++ bindings that act as an interface to the the Metal Graphics API, allowing us to write high-performance graphics and compute applications for Apple devices in (almost) pure C++. This wrapper is very light-weight, and acts as a one-to-one translation between the native Objective-C functions calls and C++. You're going to need to download the library [here](https://developer.apple.com/metal/cpp/).

Once you have downloaded the `metal-cpp` library, open Xcode and `Create a new Xcode project`. For this tutorial we're going to be targetting Mac devices, so under the `macOS` templates, select `Command Line Tool`. This will set the default language to C++ and give us an empty `Hello-World` project.

The first thing we want to do is drag and drop our freshly downloaded and unzipped 'metal-cpp' folder into our Xcode project.

![image](/images/metal-cpp.gif){ loading=lazy }

Now that we've got it copied over to our project, we need to make sure Xcode can find it. If we head over to the `Build Settings` section of our project target, under `Search Paths`, go ahead and add the metal-cpp folder to your header search paths:
````
$(PROJECT_DIR)/metal-cpp
````

![header](/images/header_search_paths.png){loading=lazy}

The next thing we should do is link with the necessary Apple frameworks to be able to use Metal. Head over to the `Build Phases` section, and under `Link Binary With Libraries`, add these three frameworks:
````
Foundation.framework
Metal.framework
QuartzCore.framework
````

![linking](/images/linking.png)

Now, Metal should be ready to go. Apple's `metal-cpp` guide tells us that we need to define the `metal-cpp` implementation in only *one* of our `.cpp` files. We're going to create a new file called `mtl_implementation.cpp` to do this for us, fill it with the necessary `define` and `include` statements:

````cpp
//  mtl_implementation.cpp
#define NS_PRIVATE_IMPLEMENTATION
#define CA_PRIVATE_IMPLEMENTATION
#define MTL_PRIVATE_IMPLEMENTATION
#include <Foundation/Foundation.hpp>
#include <Metal/Metal.hpp>
#include <QuartzCore/QuartzCore.hpp>
````

Back in our `main.cpp` file, you add the Metal include, and create a default device:

````cpp
//  main.cpp
#include <Metal/Metal.hpp>
...
int main() {
    ...
    MTL::Device* device = MTL::CreateSystemDefaultDevice();
    ...
}
````
Now, you can build and run:
![ready](/images/ready.png)

If everything went smoothly, you should see some output in the Xcode console mentioning Metal API Validation and what not. If you don't, make sure you followed all of the steps correctly.