//
//  VertexData.h
//  Metal-Tutorial
//

#pragma once
#include <simd/simd.h>

struct VertexData {
    simd::float4 vertex;
    simd::float2 textureCoordinate;
};
