//
//  DFMetalRotationRender.swift
//  MetalProduct
//
//  Created by 王龙飞 on 2022/10/11.
//

import UIKit

import simd

import MetalKit

class DFMetalRotationRender: NSObject, MTKViewDelegate {
    
    private var m_angle: Float = 0.0
    private var m_viewportSize: vector_uint2 = .zero
    
    private var m_matrix: DFMatrixContent = DFMatrixContent()
    
    private var device: MTLDevice?
    
    private var commandQueue: MTLCommandQueue?
    
    
    private var renderPipelineState: MTLRenderPipelineState!
    
    private var rectBuffer: MTLBuffer?
    
    private var rectVertexs: [DFVertex] = [
        
        DFVertex(pos: vector_float4(  0.5,  0.5, 0, 1.0), color: vector_float4(0, 0, 1, 1)),
        DFVertex(pos: vector_float4( -0.5,  0.5, 0, 1.0), color: vector_float4(0, 1, 0, 1)),
        DFVertex(pos: vector_float4(  0.5, -0.5, 0, 1.0), color: vector_float4(1, 0, 0, 1)),
        DFVertex(pos: vector_float4( -0.5, -0.5, 0, 1.0), color: vector_float4(1, 1, 0, 1)),
    ]
    
    init(_ mtkView: MTKView) {
        
        super.init()
        
        device = mtkView.device
        
        commandQueue = device?.makeCommandQueue()
        
        let library = device?.makeDefaultLibrary()
        
        let vertexFunction = library?.makeFunction(name: "vertexRotateShader")
        let fragmentFunction = library?.makeFunction(name: "fragmentRotateShader")
        
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
        
        rectBuffer = device?.makeBuffer(bytes: rectVertexs, length: rectVertexs.count * MemoryLayout<DFVertex>.size, options: .storageModeShared)
        
    }
    
    //MARK: - delegate
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
        m_viewportSize = vector_uint2(x: UInt32(size.width), y: UInt32(size.height))
        
    }
    
    func draw(in view: MTKView) {
        
        view.clearColor = MTLClearColorMake(1.0, 1.0, 1.0, 1.0)
        
        
        let transMatrix = simd_float4x4(translationX: 0, y: 0, z: -1)
        
        let rotateMatrix = simd_float4x4(rotationAngle: m_angle, x: 0, y: 0, z: 1)
        
        let modelMatrix = matrix_multiply(transMatrix, rotateMatrix)
        
        let aspect = Float(m_viewportSize.x) / Float(m_viewportSize.y)
        
        let projectionMatrix = simd_float4x4(projectFov: radians(fromDegree: 90), aspect: aspect, nearZ: 0.01, farZ: 1000)
        
        let mvpMatrix = matrix_multiply(projectionMatrix, modelMatrix)
        
        m_matrix.matrix = mvpMatrix
        
        m_angle += 0.01
        
        if let renderPassDescriptor = view.currentRenderPassDescriptor {
            
            renderPassDescriptor.colorAttachments[0].texture = view.currentDrawable?.texture
            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1.0, 1.0, 1.0, 1.0)
            renderPassDescriptor.colorAttachments[0].loadAction = .clear
            
            let commandBuffer = commandQueue?.makeCommandBuffer()
            
            let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
            
            commandEncoder?.setRenderPipelineState(renderPipelineState)
            commandEncoder?.setVertexBuffer(rectBuffer, offset: 0, index: 0)
            
            commandEncoder?.setVertexBytes(&m_matrix, length: MemoryLayout<DFMatrixContent>.size, index: 1)
            
            commandEncoder?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: rectVertexs.count)
            
            commandEncoder?.endEncoding()
            
            if let drawable = view.currentDrawable {
                
                commandBuffer?.present(drawable)
                
                commandBuffer?.commit()
            }
            
        }
        
    }

}

