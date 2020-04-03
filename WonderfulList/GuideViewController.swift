//
//  GuideViewController.swift
//  WonderfulList
//
//  Created by 周伟 on 2020/4/3.
//  Copyright © 2020 周伟. All rights reserved.
//

import UIKit

class GuideViewController: UIViewController {
    
    let guides = [
        GuideContent(title: "清爽简洁的首页", image: "guide-p1", bgColor: UIColor.white),
        GuideContent(title: "任务卡片列表，更有多种主题", image: "guide-p2", bgColor: UIColor.white),
        GuideContent(title: "丰富的任务内容，还可以设置提醒", image: "guide-p3", bgColor: UIColor.white),
        GuideContent(title: "还在纠结要不要删除已完成的任务，那就归档吧", image: "guide-p4", bgColor: UIColor.white)
    ]

    @IBOutlet weak var letsBeginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.black
        pageControl.backgroundColor = UIColor.white
        
        letsBeginButton.alpha = 0
        
        let pageViewController = storyboard?.instantiateViewController(withIdentifier: "GuidePageVC") as! UIPageViewController
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        let firstPageContentVC = getPageContentVewController(index: 0)
        pageViewController.setViewControllers([firstPageContentVC!], direction: .forward, animated: true, completion: nil)
        pageViewController.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 60)
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        
        didMove(toParent: self)
    }

    @IBAction func letsBegin(_ sender: Any) {
        let rootVC = UIApplication.shared.delegate as! AppDelegate
        rootVC.window?.rootViewController = storyboard?.instantiateInitialViewController()
    }
}

extension GuideViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let pageIndex = (viewController as! GuideContentViewController).pageIndex
        if pageIndex == 0 {
            return nil
        }
        
        return getPageContentVewController(index: pageIndex - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let pageIndex = (viewController as! GuideContentViewController).pageIndex
        if pageIndex == guides.count - 1 {
            return nil
        }
        
        return getPageContentVewController(index: pageIndex + 1)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return guides.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished, letsBeginButton.alpha == 0 {
            let currentVC = pageViewController.viewControllers![0] as! GuideContentViewController
            if currentVC.pageIndex == guides.count - 1 {
                UIView.animate(withDuration: 1) {
                    self.letsBeginButton.alpha = 1
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func getPageContentVewController(index: Int) -> GuideContentViewController? {
        if index < 0 || index >= guides.count {
            return nil
        }
        
        let pageContentVC = storyboard?.instantiateViewController(withIdentifier: "GuideContentVC") as! GuideContentViewController
        pageContentVC.guideTitle = guides[index].title
        pageContentVC.guideImage = guides[index].image
        pageContentVC.pageIndex = index
        
        return pageContentVC
    }
}
