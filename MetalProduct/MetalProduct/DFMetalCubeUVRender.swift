//
//  DFMetalUVRender.swift
//  MetalProduct
//
//  Created by 王龙飞 on 2022/10/12.
//

import Foundation

import simd

import MetalKit

class DFMetalCubeUVRender: NSObject, MTKViewDelegate {
    
    private var m_angle: Float = 0.0
    private var m_viewportSize: vector_uint2 = .zero
    
    /// 旋转矩阵
    private var m_matrix: DFMatrixContent = DFMatrixContent()
    
    private var device: MTLDevice?
    private var commandQueue: MTLCommandQueue?
    
    
    private var renderPipelineState: MTLRenderPipelineState!
    
    private var cubeBuffer: MTLBuffer?
    
    private var cubeIndexBuffer: MTLBuffer?
    
    private var quadrTextures: [MTLTexture] = []
    
    private var cubeVertexs: [DFVertex6] = [
        
        DFVertex6(pos: vector_float4( -1.0, -1.0,  1.0, 1.0), uv: vector_float2( 0, 0)),
        DFVertex6(pos: vector_float4( -1.0,  1.0,  1.0, 1.0), uv: vector_float2( 0, 1)),
        DFVertex6(pos: vector_float4(  1.0, -1.0,  1.0, 1.0), uv: vector_float2( 1, 0)),
        DFVertex6(pos: vector_float4(  1.0,  1.0,  1.0, 1.0), uv: vector_float2( 1, 1)),
        
        DFVertex6(pos: vector_float4(  1.0, -1.0, -1.0, 1.0), uv: vector_float2( 0, 0)),
        DFVertex6(pos: vector_float4(  1.0,  1.0, -1.0, 1.0), uv: vector_float2( 0, 1)),
        DFVertex6(pos: vector_float4( -1.0, -1.0, -1.0, 1.0), uv: vector_float2( 1, 0)),
        DFVertex6(pos: vector_float4( -1.0,  1.0, -1.0, 1.0), uv: vector_float2( 1, 1)),
        
        DFVertex6(pos: vector_float4( -1.0, -1.0, -1.0, 1.0), uv: vector_float2( 0, 0)),
        DFVertex6(pos: vector_float4( -1.0,  1.0, -1.0, 1.0), uv: vector_float2( 0, 1)),
        DFVertex6(pos: vector_float4( -1.0, -1.0,  1.0, 1.0), uv: vector_float2( 1, 0)),
        DFVertex6(pos: vector_float4( -1.0,  1.0,  1.0, 1.0), uv: vector_float2( 1, 1)),
        
        DFVertex6(pos: vector_float4(  1.0, -1.0,  1.0, 1.0), uv: vector_float2( 0, 0)),
        DFVertex6(pos: vector_float4(  1.0,  1.0,  1.0, 1.0), uv: vector_float2( 0, 1)),
        DFVertex6(pos: vector_float4(  1.0, -1.0, -1.0, 1.0), uv: vector_float2( 1, 0)),
        DFVertex6(pos: vector_float4(  1.0,  1.0, -1.0, 1.0), uv: vector_float2( 1, 1)),
        
        DFVertex6(pos: vector_float4( -1.0,  1.0,  1.0, 1.0), uv: vector_float2( 0, 0)),
        DFVertex6(pos: vector_float4( -1.0,  1.0, -1.0, 1.0), uv: vector_float2( 0, 1)),
        DFVertex6(pos: vector_float4(  1.0,  1.0,  1.0, 1.0), uv: vector_float2( 1, 0)),
        DFVertex6(pos: vector_float4(  1.0,  1.0, -1.0, 1.0), uv: vector_float2( 1, 1)),
        
        DFVertex6(pos: vector_float4( -1.0, -1.0, -1.0, 1.0), uv: vector_float2( 0, 0)),
        DFVertex6(pos: vector_float4( -1.0, -1.0,  1.0, 1.0), uv: vector_float2( 0, 1)),
        DFVertex6(pos: vector_float4(  1.0, -1.0, -1.0, 1.0), uv: vector_float2( 1, 0)),
        DFVertex6(pos: vector_float4(  1.0, -1.0,  1.0, 1.0), uv: vector_float2( 1, 1)),
    
    ]
    
    
    private let cubeIndexVertex: [UInt16] = [
         0,  1,  2,   1,  3,  2, //Front
         4,  5,  6,   5,  7,  6, //Back
         8,  9, 10,   9, 11, 10, //Left
        12, 13, 14,  13, 15, 14, //Right
        16, 17, 18,  17, 19, 18, //Top
        20, 21, 22,  21, 23, 22, //Bottom
    ]
    
    init(_ mtkView: MTKView) {
        
        super.init()
        
        device = mtkView.device
        
        commandQueue = device?.makeCommandQueue()
        
        let library = device?.makeDefaultLibrary()
        
        let vertexFunction = library?.makeFunction(name: "vertexUVShader")
        let fragmentFunction = library?.makeFunction(name: "fragmentUVShader")
        
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
        
        if let mtkDevice = device {
            
            for index in 1...6 {
                
                let texture = DFMetalTexture(name: "\(index)", device: mtkDevice).texture
                
                quadrTextures.append(texture!)
            }
        }
    }
    
    //MARK: - delegate
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
        m_viewportSize = vector_uint2(x: UInt32(size.width), y: UInt32(size.height))
        
    }
    
    func draw(in view: MTKView) {
        
        view.clearColor = MTLClearColorMake(1.0, 1.0, 1.0, 1.0)
        
        
        /// 缩放矩阵
        let scaleMatrix = simd_float4x4(scaleX: 0.8, y: 0.8, z: 0.8)
        
        
        /// 旋转矩阵 在不同分量
        let rotateXMatrix = simd_float4x4(rotationAngle: m_angle, x: 1, y: 0, z: 0)
        
        let rotateYMatrix = simd_float4x4(rotationAngle: m_angle, x: 0, y: 1, z: 0)
        
        let rotateZMatrix = simd_float4x4(rotationAngle: m_angle, x: 0, y: 0, z: 1)
        
        let rotateMatrix0 = matrix_multiply(rotateYMatrix, rotateXMatrix)
        let rotateMatrix1 = matrix_multiply(rotateZMatrix, rotateMatrix0)
        
        /// 平移矩阵
        let transMatrix = simd_float4x4(translationX: 0, y: 0, z: -3)
        
        
        /// matrix_multiply(a , b)  顺序是 b * a
        
        let modelMatrix = matrix_multiply(transMatrix, matrix_multiply(rotateMatrix1, scaleMatrix))
        
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
            
            
            
            for index in 0...5 {
                
                commandEncoder?.setFragmentTexture(self.quadrTextures[index], index: 0)
                
                commandEncoder?.drawIndexedPrimitives(type: .triangle, indexCount: cubeIndexVertex.count / 6, indexType: .uint16, indexBuffer: cubeIndexBuffer!, indexBufferOffset: index * 6 * MemoryLayout<UInt16>.size)
                
            }
            

            commandEncoder?.endEncoding()
            
            if let drawable = view.currentDrawable {
                
                commandBuffer?.present(drawable)
                
                commandBuffer?.commit()
            }
            
        }
        
    }

}
