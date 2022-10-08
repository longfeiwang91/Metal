//
//  DFMetalApi.swift
//  MetalProduct
//
//  Created by 王龙飞 on 2022/10/8.
//

import UIKit

class DFMetalApi: NSObject {
    
    
    /// MTLDevice对象代表GPU， 通常使用MTLCreateSystemDefaultDevice 获取默认的GPU。
    
    static var shareInstace: DFMetalApi = DFMetalApi()
    
    public var metalDevice: MTLDevice?
    
    private override init() {
     
        guard let metalDevice = MTLCreateSystemDefaultDevice() else {
            
            fatalError("GPU doesn't support metal")
        }
        
        self.metalDevice = metalDevice
        
        print("GPU support Metal :\(metalDevice.name)")
        
        print("GPU support maxThreadsPerThreadgroup :\(metalDevice.maxThreadsPerThreadgroup)")
        
        print("GPU support readWriteTextureSupport :\(metalDevice.readWriteTextureSupport)")
    }

}
