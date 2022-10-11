//
//  DFRotateShader.metal
//  MetalProduct
//
//  Created by 王龙飞 on 2022/10/11.
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
vertex RasterizerData vertexRotateShader(uint vid [[vertex_id]],
                                   constant DFVertex *vertexs [[buffer(0)]],
                                   constant DFMatrixContent& mvp [[buffer(1)]]) {
    
    RasterizerData outData;
    
    outData.position = mvp.matrix * vertexs[vid].pos;
    
    outData.color = vertexs[vid].color;
    
    return  outData;
}


/// 片源着色器
fragment float4 fragmentRotateShader(RasterizerData inData [[stage_in]]) {
    
    return inData.color;
}


