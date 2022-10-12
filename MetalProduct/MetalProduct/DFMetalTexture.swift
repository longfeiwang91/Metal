//
//  DFMetalTexture.swift
//  MetalProduct
//
//  Created by 王龙飞 on 2022/10/12.
//

import UIKit

import MetalKit

class DFMetalTexture: NSObject {
    
    
    public var texture: MTLTexture?
    
    public var mtlDevice: MTLDevice
    
    private var texturename: String
    
    private var extention: String
    
    init(name: String, ext: String = "png", device: MTLDevice) {
        
        texturename = name
        mtlDevice = device
        extention = ext
        
        super.init()
        
       
        
        texture = loadTexture()
    }
    
    
    private func loadTexture() -> MTLTexture? {
        
        var resultTexture: MTLTexture?
        
        if let url = Bundle.main.url(forResource: texturename, withExtension: extention) {
            
            let textureLoader = MTKTextureLoader(device: self.mtlDevice)
            
            do {
                
                resultTexture = try textureLoader.newTexture(URL: url, options: [
                    MTKTextureLoader.Option.origin: MTKTextureLoader.Origin.flippedVertically,
                    MTKTextureLoader.Option.SRGB: false
                ])
            } catch {
                
                print("MTKTextureLoader error: \(error)")
            }
        }
        
        
        return resultTexture
    }

}
