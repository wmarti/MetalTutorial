//
//  VertexData.h
//  Metal-Tutorial
//

#pragma once
#include <simd/simd.h>

using namespace simd;

struct VertexData {
    float4 position;
    float4 normal;
};

struct TransformationData {
    float4x4 translationMatrix;
    float4x4 perspectiveMatrix;
};
