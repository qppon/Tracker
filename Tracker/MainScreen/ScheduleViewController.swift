//
//  scheduleViewController.swift
//  Tracker
//
//  Created by Jojo Smith on 3/18/25.
//

import UIKit
protocol ScheduleViewControllerDelegate: AnyObject {
    func setWeekdays(weekdays: [Weekday])
}
final class ScheduleViewController: UIViewController {
    
    weak var delegate: ScheduleViewControllerDelegate?
    
    private let tableView = UITableView()
    
    private let weekdays = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    
    private var selectedWeekdays: [Weekday] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    private func makeLabel() -> UILabel {
        let label = UILabel()
        label.text = "Расписание"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func makeButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textColor = .white
        button.backgroundColor = UIColor(resource: .ypBlack)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(self.didTapButton), for: .touchUpInside)
        
        return button
    }
    
    private func makeTableView() -> UITableView {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.allowsMultipleSelection = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        return tableView
    }
    
    @objc
    private func didTapButton() {
        delegate?.setWeekdays(weekdays: selectedWeekdays)
        dismiss(animated: true)
    }
    
    
    private func setUp() {
        view.backgroundColor = .white
        let label = makeLabel()
        let button = makeButton()
        let tableView = makeTableView()
        
        view.addSubviews([label, button, tableView])
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 34),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            button.widthAnchor.constraint(equalToConstant: view.frame.width - 40),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.heightAnchor.constraint(equalToConstant: 60),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            tableView.widthAnchor.constraint(equalToConstant: view.frame.width - 32),
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -47),
            tableView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 30)
        ])
    }
}

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.frame.height / 7
    }
}

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let switchView = UISwitch()
        switchView.onTintColor = .ypBlue
        switchView.translatesAutoresizingMaskIntoConstraints = false
        switchView.addTarget(self, action: #selector(didSwitch(_:)), for: .valueChanged)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        
        cell.backgroundColor = .systemGray6
        cell.textLabel?.text = weekdays[indexPath.row]
        cell.accessoryView = switchView
        return cell
    }
    
    @objc
    private func didSwitch(_ sender: UISwitch) {
        if let cell = sender.superview as? UITableViewCell,
           let indexPath = tableView.indexPath(for: cell) {
            let day = weekdays[indexPath.row]
            
            if sender.isOn {
                if let weekday = Weekday(rawValue: day) {
                    selectedWeekdays.append(weekday)
                }
            } else {
                if let weekday = Weekday(rawValue: day),
                   let index = selectedWeekdays.firstIndex(of: weekday) {
                    selectedWeekdays.remove(at: index)
                }
            }
        }
    }
}
enum Weekday: String, CaseIterable, Encodable, Decodable {
    case sunday = "Воскресенье"
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
}
