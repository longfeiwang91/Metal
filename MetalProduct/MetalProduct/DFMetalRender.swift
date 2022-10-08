//
//  DFMetalRender.swift
//  MetalProduct
//
//  Created by 王龙飞 on 2022/10/8.
//

import UIKit

import MetalKit

class DFMetalRender: NSObject, MTKViewDelegate {
    
    
    private var device: MTLDevice?
    
    private var commandQueue: MTLCommandQueue?
    
    init(_ mtkView: MTKView) {
        
        super.init()
        
        device = mtkView.device
        
        /// MTLCommandQueue由MTL Device创建， 用于组织MTLCommandBuffer， 保证指令MTLCommandBuffer有序地发送到GPU

        commandQueue = device?.makeCommandQueue()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        
        
        if let renderPassDescriptor = view.currentRenderPassDescriptor {
            
            /// 重置颜色
            renderPassDescriptor.colorAttachments[0].texture = view.currentDrawable?.texture
            
            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
            
            renderPassDescriptor.colorAttachments[0].loadAction = .clear
            
            ///
            ///MTLCommandBuffer会提供一些encoder，包括
            ///编码绘制指令的MTLRenderCommandEncoder，
            ///编码计算指令的MTLComputeCommandEncoder，
            ///编码纹理缓存拷贝指令的MTLBlitCommandEncoder
            ///
            /// 对于一个commandBuffer， 只有调用encoder的结束操作，才能进行下一个encoder的创建， 同时可以设置执行完指令的回调。
            ///
            /// 每一帧都会产生一个MTLCommandBuffer对象，用于填放指令，GPUs类型很多，每一种都有各自接收和执行指令方式。在MLTCommandEncoder把指令进行封装以后，MTLCommandBuffer再做聚合到一次提交
            ///
            /// MTLRenderPassDescriptor是一个轻量级的临时对象，里面存放较多的属性配置，提供给MTLCommandBuffer创建MTLRenderCommandEncoder对象调用
            
            /// 命令buffer
            let commandBuffer = commandQueue?.makeCommandBuffer()
            
            let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
            
            commandEncoder?.endEncoding()
            
            if let drawable = view.currentDrawable {
                
                commandBuffer?.present(drawable)
            }
            
            commandBuffer?.commit()
            
        }
        
    }
    
    

}
