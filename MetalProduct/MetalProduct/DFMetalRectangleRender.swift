//
//  DFMetalRectangleRender.swift
//  MetalProduct
//
//  Created by 王龙飞 on 2022/10/10.
//

import UIKit

import MetalKit

class DFMetalRectangleRender: NSObject, MTKViewDelegate {
    
    private var device: MTLDevice?
    
    private var commandQueue: MTLCommandQueue?
    
    
    private var renderPipelineState: MTLRenderPipelineState!
    
    private var rectBuffer: MTLBuffer?
    
    private var rectVertexs: [CCVertex] = [
        
        CCVertex(pos: vector_float4(  0.5,  0.5, 0, 1.0), color: vector_float4(0, 0, 1, 1)),
        CCVertex(pos: vector_float4( -0.5,  0.5, 0, 1.0), color: vector_float4(0, 1, 0, 1)),
        CCVertex(pos: vector_float4(  0.5, -0.5, 0, 1.0), color: vector_float4(1, 0, 0, 1)),
        CCVertex(pos: vector_float4( -0.5, -0.5, 0, 1.0), color: vector_float4(1, 1, 0, 1)),
    ]
    
    init(_ mtkView: MTKView) {
        
        super.init()
        
        device = mtkView.device
        
        commandQueue = device?.makeCommandQueue()
        
        let library = device?.makeDefaultLibrary()
        
        let vertexFunction = library?.makeFunction(name: "vertexShader")
        let fragmentFunction = library?.makeFunction(name: "fragmentShader")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        
        /// 颜色的像素空间
        pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        
        
        
        do {
            
            try renderPipelineState = device?.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            
            print("create render pipline failed \(error)")
        }
        
        rectBuffer = device?.makeBuffer(bytes: rectVertexs, length: rectVertexs.count * MemoryLayout<CCVertex>.size, options: .storageModeShared)
        
    }
    
    //MARK: - delegate
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        
        view.clearColor = MTLClearColorMake(1.0, 1.0, 1.0, 1.0)
        
        if let renderPassDescriptor = view.currentRenderPassDescriptor {
            
            renderPassDescriptor.colorAttachments[0].texture = view.currentDrawable?.texture
            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1.0, 1.0, 1.0, 1.0)
            renderPassDescriptor.colorAttachments[0].loadAction = .clear
            
            let commandBuffer = commandQueue?.makeCommandBuffer()
            
            let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
            
            commandEncoder?.setRenderPipelineState(renderPipelineState)
            commandEncoder?.setVertexBuffer(rectBuffer, offset: 0, index: 0)
            commandEncoder?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: rectVertexs.count)
            
            commandEncoder?.endEncoding()
            
            if let drawable = view.currentDrawable {
                
                commandBuffer?.present(drawable)
                
                commandBuffer?.commit()
            }
            
        }
        
    }

}
