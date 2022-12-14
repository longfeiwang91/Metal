//
//  DFMetalData.h
//  MetalProduct
//
//  Created by 王龙飞 on 2022/10/8.
//

#ifndef DFMetalData_h
#define DFMetalData_h

#include <simd/simd.h>

/// 写swift struct metal 没办法使用
typedef struct {
    
    vector_float4 pos;
    vector_float4 color;
    
} DFVertex;


typedef struct {
    
    vector_float4 pos;
    vector_float4 uv;
    
} DFVertex8;

typedef struct {
    
    vector_float4 pos;
    vector_float2 uv;
    
} DFVertex6;


typedef struct {
    
    simd_float4x4 matrix;
    
    
} DFMatrixContent;


#endif /* DFMetalData_h */
