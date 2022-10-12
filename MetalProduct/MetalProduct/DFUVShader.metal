//
//  DFUVShader.metal
//  MetalProduct
//
//  Created by 王龙飞 on 2022/10/12.
//

#include <metal_stdlib>
using namespace metal;

#import "DFMetalData.h"


typedef  struct {
    
    float4 position [[position]];
    
    float2 uv;
    
} RasterizerData;

//// 顶点着色器的输出 是片源着色器的输入

/// 顶点着色器
vertex RasterizerData vertexUVShader(uint vid [[vertex_id]],
                                   constant DFVertex6 *vertexs [[buffer(0)]],
                                   constant DFMatrixContent& mvp [[buffer(1)]]) {
    
    RasterizerData outData;
    
    outData.position = mvp.matrix * vertexs[vid].pos;
    
    outData.uv = vertexs[vid].uv;
    
    return  outData;
}


/// 片源着色器
fragment half4 fragmentUVShader(RasterizerData inData [[stage_in]],
                                     texture2d<half> colorTexture [[texture(0)]]) {
    
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    
    half4 colorSample = colorTexture.sample(textureSampler, inData.uv).rgba;
    
    return colorSample;
}
