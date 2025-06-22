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
        let navigationViewController = UINavigationController(rootViewController: trackersViewController)
        let statisticsViewController = StatisticsViewController()
        
        statisticsViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tapbar.title", comment: ""),
            image: UIImage(resource: .statisticsTabBarIcon),
            selectedImage: nil
        )
        
        trackersViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("trecers.title", comment: ""),
            image: UIImage(resource: .tracersTabBarIcon),
            selectedImage: nil
        )
        
        self.viewControllers = [navigationViewController, statisticsViewController]
    }
}
