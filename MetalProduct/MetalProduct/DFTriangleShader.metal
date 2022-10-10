//
//  DFTriangleShader.metal
//  MetalProduct
//
//  Created by 王龙飞 on 2022/10/8.
//

#include <metal_stdlib>
using namespace metal;

#import "DFMetalData.h"


typedef  struct {
    
    float4 position [[position]];
    
    float4 color;
    
} RasterizerData;

//// 顶点着色器的输出 是片源着色器的输入

/// 顶点着色器
vertex RasterizerData vertexShader(uint vid [[vertex_id]], constant CCVertex *vertexs [[buffer(0)]]) {
    
    RasterizerData outData;
    
    outData.position = vertexs[vid].pos;
    
    outData.color = vertexs[vid].color;
    
    return  outData;
}


/// 片源着色器
fragment float4 fragmentShader(RasterizerData inData [[stage_in]]) {
    
    return inData.color;
}
