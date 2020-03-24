//
//  MenuView.swift
//  WonderfulList
//
//  Created by 周伟 on 2020/3/17.
//  Copyright © 2020 周伟. All rights reserved.
//

import UIKit

protocol MenuViewDelegate {
    func didClickSelectedRow(menuId: Int, menu: MenuView)
}

class MenuView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    // 显示在menu每一行的文字
    var menus: [Menu]?
    
    // 当前显示状态，初始状态为false
    var isNowHidden = true
    
    var tableView: UITableView?
    var delegate: MenuViewDelegate?
    
    init(frame: CGRect, menus: [Menu]) {
        super.init(frame: frame)
        self.menus = menus
        self.backgroundColor = UIColor.clear
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height), style: .plain)
        tableView!.delegate = self
        tableView!.dataSource = self
        tableView!.isScrollEnabled = false
        tableView!.layer.masksToBounds = true
        tableView!.layer.cornerRadius = 5.0
        tableView!.backgroundColor = UIColor.gray
        
        self.addSubview(tableView!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    不画三角形
//    override func draw(_ rect: CGRect) {
//        // 绘制小三角形
//        guard let context = UIGraphicsGetCurrentContext() else {
//            return
//        }
//
//        let path = CGMutablePath()
//        let width = bounds.width
//
//        // 设置三角形的位置
//        path.move(to: CGPoint(x: width - 9, y: 0))
//        path.addLine(to: CGPoint(x: width - 18, y: 8))
//        path.addLine(to: CGPoint(x: width, y: 8))
//        context.setFillColor(UIColor.black.cgColor)
//        context.addPath(path)
//        context.fillPath()
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        let image = UIImage(named: menus![indexPath.row].image)
        cell.imageView?.image = image
        cell.textLabel?.text = "\(menus![indexPath.row].title)"
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.textLabel?.textAlignment = NSTextAlignment.left
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didClickSelectedRow(menuId: menus![indexPath.row].id, menu: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func removeMenu() {
        self.removeFromSuperview()
        self.isNowHidden = true
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view?.isMember(of: CustomTableView.self) ?? true {
            self.removeMenu()
        }
        return view
    }
}

struct Menu {
    var id: Int
    var image: String
    var title: String
}
