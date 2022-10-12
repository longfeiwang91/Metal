//
//  UIMetalDetailVC.swift
//  MetalProduct
//
//  Created by 王龙飞 on 2022/10/10.
//

import UIKit

import MetalKit

class UIMetalDetailVC: UIViewController {
    
    var renderType: MetalType = .triangle
    
    
    init(_ type: MetalType) {
        
        super.init(nibName: nil, bundle: nil)
        
        
        renderType = type
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        loadMetal()
        
        
        loadUI()
    }
    
    
    //MARK: - loadData
    func loadMetal() {
        
        switch renderType {
        case .triangle:
            render = DFMetalTriangleRender(mtkView)
        case .rectangle:
            render = DFMetalRectangleRender(mtkView)
        case .rotation:
            render = DFMetalRotationRender(mtkView)
            
            render?.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
            
        case .cube:
            render = DFMetalCubeRender(mtkView)
            
            render?.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
            
        }
        
       
        mtkView.delegate = render
    }
 
    //MARK: - loadUI
    func loadUI() {
        
        view.backgroundColor = .white
        view.addSubview(mtkView)
    }

    

    //MARK: - lazy
    private lazy var mtkView: MTKView = {
        
        let view = MTKView(frame: UIScreen.main.bounds)
        
        view.device = DFMetalApi.shareInstace.metalDevice
        
        return view
    }()


    private var render: MTKViewDelegate?
}
