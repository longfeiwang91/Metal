//
//  DFMetalCubeRender.swift
//  MetalProduct
//
//  Created by 王龙飞 on 2022/10/12.
//

import Foundation

import simd

import MetalKit

class DFMetalCubeRender: NSObject, MTKViewDelegate {
    
    private var m_angle: Float = 0.0
    private var m_viewportSize: vector_uint2 = .zero
    
    /// 旋转矩阵
    private var m_matrix: DFMatrixContent = DFMatrixContent()
    
    private var device: MTLDevice?
    private var commandQueue: MTLCommandQueue?
    
    
    private var renderPipelineState: MTLRenderPipelineState!
    
    private var cubeBuffer: MTLBuffer?
    
    private var cubeIndexBuffer: MTLBuffer?
    
    private var cubeVertexs: [DFVertex] = [
        
        DFVertex(pos: vector_float4( -1.0,  1.0,  1.0, 1.0), color: vector_float4(1.0, 0.0, 0.0, 1)),
        DFVertex(pos: vector_float4( -1.0, -1.0,  1.0, 1.0), color: vector_float4(0, 1, 0, 1)),
        DFVertex(pos: vector_float4(  1.0, -1.0,  1.0, 1.0), color: vector_float4(0, 0, 1, 1)),
        DFVertex(pos: vector_float4(  1.0,  1.0,  1.0, 1.0), color: vector_float4(1, 0, 1, 1)),
        DFVertex(pos: vector_float4( -1.0,  1.0, -1.0, 1.0), color: vector_float4(0, 0, 1, 1)),
        DFVertex(pos: vector_float4( -1.0, -1.0, -1.0, 1.0), color: vector_float4(0, 1, 0, 1)),
        DFVertex(pos: vector_float4(  1.0, -1.0, -1.0, 1.0), color: vector_float4(1, 0, 0, 1)),
        DFVertex(pos: vector_float4(  1.0,  1.0, -1.0, 1.0), color: vector_float4(1, 0, 1, 1)),
    ]
    
    
    private let cubeIndexVertex: [UInt16] = [
        0, 1, 2,  0, 2, 3, //Front
        4, 6, 5,  4, 7, 6, //Back
        4, 5, 1,  4, 1, 0, //Left
        3, 6, 7,  3, 2, 6, //Right
        4, 0, 3,  4, 3, 7, //Top
        1, 5, 6,  1, 6, 2, //Bottom
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
        
        cubeBuffer = device?.makeBuffer(bytes: cubeVertexs,
                                        length: cubeVertexs.count * MemoryLayout<DFVertex>.size,
                                        options: .storageModeShared)
        
        cubeIndexBuffer = device?.makeBuffer(bytes: cubeIndexVertex,
                                         length: cubeIndexVertex.count * MemoryLayout<UInt16>.size,
                                         options: .storageModeShared)
        
    }
    
    //MARK: - delegate
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
        m_viewportSize = vector_uint2(x: UInt32(size.width), y: UInt32(size.height))
        
    }
    
    func draw(in view: MTKView) {
        
        view.clearColor = MTLClearColorMake(1.0, 1.0, 1.0, 1.0)
        
        
        /// 缩放矩阵
        let scaleMatrix = simd_float4x4(scaleX: 0.5, y: 0.5, z: 0.5)
        
        
        /// 旋转矩阵
        let rotateMatrix = simd_float4x4(rotationAngle: m_angle, x: 0, y: 1, z: 0)
        
        /// 平移矩阵
        let transMatrix = simd_float4x4(translationX: 0, y: 0, z: -3)
        
        
        /// matrix_multiply(a , b)  顺序是 b * a
        
        let modelMatrix = matrix_multiply(transMatrix, matrix_multiply(rotateMatrix, scaleMatrix))
        
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
            commandEncoder?.setVertexBuffer(cubeBuffer, offset: 0, index: 0)
            
            commandEncoder?.setVertexBytes(&m_matrix, length: MemoryLayout<DFMatrixContent>.size, index: 1)
            
            
            commandEncoder?.setFrontFacing(.clockwise)
            
            ///  设置背面剔除
            commandEncoder?.setCullMode(.back)
            
            
            commandEncoder?.drawIndexedPrimitives(type: .triangle, indexCount: cubeIndexVertex.count, indexType: .uint16, indexBuffer: cubeIndexBuffer!, indexBufferOffset: 0)
            
            commandEncoder?.endEncoding()
            
            if let drawable = view.currentDrawable {
                
                commandBuffer?.present(drawable)
                
                commandBuffer?.commit()
            }
            
        }
        
    }

}
