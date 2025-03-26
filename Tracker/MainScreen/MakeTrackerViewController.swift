//
//  MakeTrackerViewController.swift
//  Tracker
//
//  Created by Jojo Smith on 3/12/25.
//

import UIKit


final class MakeTrackerViewController: UIViewController {
    
    weak var trackersViewController: TrackerSettingsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUp()
    }
    
    
    func setUp() {
        let label = makeLabel()
        let habitButton = makeButton(text: "Привычка")
        let notHabitButton = makeButton(text: "Нерегулярное событие")
        
        view.addSubviews([label, habitButton, notHabitButton])
        
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 34),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            habitButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 295),
            habitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            habitButton.widthAnchor.constraint(equalToConstant: view.frame.width - 40),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            
            notHabitButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
            notHabitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            notHabitButton.widthAnchor.constraint(equalToConstant: view.frame.width - 40),
            notHabitButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func makeLabel() -> UILabel {
        let label = UILabel()
        label.text = "Создание трекера"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func makeButton(text: String) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(text, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textColor = .white
        button.backgroundColor = UIColor(resource: .black)
        button.layer.cornerRadius = 16
        
        if text == "Привычка" {
            button.addTarget(self, action: #selector(self.didTapHabitButton), for: .touchUpInside)
        } else {
            button.addTarget(self, action: #selector(self.didTapNotHabitButton), for: .touchUpInside)
        }
        return button
    }
    
    @objc
    func didTapHabitButton() {
        let trackerSettingsViewController = TrackerSettingsViewController()
        trackerSettingsViewController.trackerType = TrackerTypes.habit
        trackerSettingsViewController.delegate = trackersViewController
        present(trackerSettingsViewController, animated: true)
    }
    
    @objc
    func didTapNotHabitButton() {
        let trackerSettingsViewController = TrackerSettingsViewController()
        trackerSettingsViewController.trackerType = TrackerTypes.notRegular
        trackerSettingsViewController.delegate = trackersViewController
        present(trackerSettingsViewController, animated: true)
    }
}
