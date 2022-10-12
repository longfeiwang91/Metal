//
//  UIMetalMainVC.swift
//  MetalProduct
//
//  Created by 王龙飞 on 2022/10/8.
//

import UIKit

import SnapKit


public enum MetalType: UInt {
    
    case triangle
    
    case rectangle
    
    case rotation
    
    case cube
    
    case rectuv
    
    case cubeuv
}

class UIMetalMainVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            
            make.edges.equalTo(self.view)
            
        }
        
    }
    

    //MARK: - delegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellID, for: indexPath)
        
        cell.textLabel?.text = "\(dataSource[indexPath.row])"
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataSource.count
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let type = dataSource[indexPath.row]
        
        let detailVC = UIMetalDetailVC(type)
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    
    //MARK: - lazy
    private let tableViewCellID = "tableViewCellID"
    
    lazy var dataSource: [MetalType] = {
        
        let array: [MetalType] = [
            .triangle,
            .rectangle,
            .rotation,
            .cube,
            .rectuv,
            .cubeuv
        ]
        return array
    }()
    
    lazy var tableView: UITableView = {
        
        let tableView = UITableView.init(frame: .zero, style: .plain)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: tableViewCellID)
        
        
        tableView.rowHeight = 80
        
        return tableView
    }()

    
    
    

}
