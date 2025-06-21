//
//  FilterViewController.swift
//  Tracker
//
//  Created by Jojo Smith on 6/20/25.
//


import UIKit

protocol FiltrControllerDelegate: AnyObject {
    func didSelectFilter(_ filter: TrackerFilter)
}

enum TrackerFilter: Int {
    case all = 0
    case today
    case completed
    case notCompleted
}

final class FiltrController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate: FiltrControllerDelegate?
    private let options = ["Все трекеры", "Трекеры на сегодня", "Завершённые", "Не завершённые"]
    private let selectedFilterKey = "SelectedFilterIndex"
    
    private var selectedIndex: Int {
        get {
            if UserDefaults.standard.object(forKey: selectedFilterKey) == nil {
                return 0
            } else {
                return UserDefaults.standard.integer(forKey: selectedFilterKey)
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: selectedFilterKey)
        }
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 16
        tableView.backgroundColor = .systemGray6
        tableView.rowHeight = 75
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FilterCell")
        return tableView
    }()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "Фильтры"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .forText
        return titleLabel
    }()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUpUI()
    }
    
    private func setUpUI() {
        [tableView, titleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 38),
            
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.widthAnchor.constraint(equalToConstant: 343),
            tableView.heightAnchor.constraint(equalToConstant: 299)
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
        
        cell.textLabel?.text = options[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.textLabel?.textColor = .forText
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        cell.accessoryType = (indexPath.row == selectedIndex) ? .checkmark : .none
        cell.tintColor = .blue
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        
        tableView.reloadData()
        
        if let selectedFilter = TrackerFilter(rawValue: indexPath.row) {
            delegate?.didSelectFilter(selectedFilter)
        }
        
        dismiss(animated: true)
    }
}


