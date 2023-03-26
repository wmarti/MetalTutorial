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

struct TransformationData {
    matrix_float4x4 translationMatrix;
    matrix_float4x4 perspectiveMatrix;
};

struct CubeVertexData {
    simd::float4 vertex;
    simd::float4 normal;
};
