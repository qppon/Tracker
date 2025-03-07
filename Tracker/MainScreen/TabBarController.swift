//
//  TabBarController.swift
//  Tracker
//
//  Created by Jojo Smith on 3/7/25.
//

import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackersViewController = TrackersViewController()
        let statisticsViewController = StatisticsViewController()
        
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(resource: .statisticsTabBarIcon),
            selectedImage: nil
        )
        
        trackersViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(resource: .tracersTabBarIcon),
            selectedImage: nil
        )
        
        

        
        self.viewControllers = [trackersViewController, statisticsViewController]
    }
}
