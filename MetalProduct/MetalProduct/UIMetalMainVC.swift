//
//  UIMetalMainVC.swift
//  MetalProduct
//
//  Created by 王龙飞 on 2022/10/8.
//

import UIKit

import MetalKit

class UIMetalMainVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        loadMetal()
        
        view.addSubview(mtkView)
        
        
        view.backgroundColor = .white
    }
    
    //MARK: - loadUI
    func loadMetal() {
        
        
        metalRender = DFMetalRender(mtkView)
        mtkView.delegate = metalRender
        
    }


    
    
    
    //MARK: - lazy
    private lazy var mtkView: MTKView = {
        
        let view = MTKView(frame: UIScreen.main.bounds)
        
        view.device = DFMetalApi.shareInstace.metalDevice
        
        return view
    }()

    private var metalRender: DFMetalRender?
    
    
    
    

}
