//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Jojo Smith on 6/14/25.
//

import UIKit
protocol CategoryViewControllerDelegate: UIViewController {
    func didSelect(category: String)
}

final class CategoryViewController: UIViewController {
    
    weak var delegate: CategoryViewControllerDelegate?
    private var selectedCategory: String?
    private var viewModel: CategoryViewModelProtocol
    
    init(delegate: CategoryViewControllerDelegate?, selectedCategory: String? = nil, viewModel: CategoryViewModelProtocol) {
        self.delegate = delegate
        self.selectedCategory = selectedCategory
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private lazy var tableView: UITableView =  {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(CategoryCell.self,
                           forCellReuseIdentifier: "CategoryCell")
        tableView.bounces = false
        tableView.layer.masksToBounds = true
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .placeHolder
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.text = "Привычки и события можно \n объединять по смыслу"
        label.isHidden = true
        return label
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setUpUI()
    }
    
    private func bind() {
        viewModel.categoriesChanged = {[weak self] categories in
            guard let self = self else {
                return}
            tableView.reloadData()
            setUpPlaceholder()
        }
    }
    
    private func setUpUI() {
        view.backgroundColor = .systemBackground
        setUpPlaceholder()
        
        [titleLabel, tableView, placeholderImageView, placeholderLabel, addCategoryButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -24),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            
            placeholderImageView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -276),
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: placeholderImageView.centerXAnchor),
            
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func setUpPlaceholder() {
        let trackerCategories = viewModel.numberOfCategories()
        placeholderImageView.isHidden = trackerCategories > 0
        placeholderLabel.isHidden = trackerCategories > 0
    }
        
    @objc
    private func didTapCreateButton() {
        let vc = CreateCategoryViewController()
        vc.delegate = self
        present(vc, animated: true)
    }
}

extension CategoryViewController: CreateCategoryViewControllerDelegate {
    func create(category: TrackerCategory) {
        viewModel.createCategory(category)
    }
    
    func update(category: TrackerCategory, categoryName: String) {
        viewModel.updateCategory(category: category, newCategoryName: categoryName)
    }
}

extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCategories()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as? CategoryCell else {
            return UITableViewCell()
        }
        
        guard let trackerCategory = viewModel.getCategory(at: indexPath) else {
            return UITableViewCell()
        }
        cell.textLabel?.text = trackerCategory
        
        if selectedCategory != nil && cell.textLabel?.text == selectedCategory {
            cell.setCheckMark()
        } else {
            cell.removeCheckMark()
        }
        return cell
    }
}

extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedCategory = viewModel.getCategory(at: indexPath) {
            delegate?.didSelect(category: selectedCategory)
            tableView.reloadData()
            dismiss(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPath.count > 0 else {return nil}
        
        let trackerCategory = viewModel.getCategory(at: indexPath)
        
        return UIContextMenuConfiguration(actionProvider: {actions in
            return UIMenu(
                children: [
                    UIAction(title: "Редактировать") {_ in
                        let createCategoryViewController = CreateCategoryViewController()
                        createCategoryViewController.delegate = self
                        createCategoryViewController.category = TrackerCategory(category: trackerCategory ?? "", trackers: [])
                        self.present(createCategoryViewController, animated: true)
                    },
                    UIAction(title: "Удалить", attributes: .destructive) {_ in
                        let alertController = UIAlertController(title: "", message: "Эта категория точно не нужна?", preferredStyle: .actionSheet)
                        
                        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { _ in
                            self.viewModel.deleteCategory(at: indexPath)
                        }
                        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
                        alertController.addAction(deleteAction)
                        alertController.addAction(cancelAction)
                        
                        self.present(alertController, animated: true)
                    }
                ])
        })
    }
}

final class CategoryCell: UITableViewCell {

    static let categoryCellIdentifier = "categoryCell"
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    
    private lazy var checkMarkImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super .init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCheckMark() {
        checkMarkImageView.image = .categoryCheckmark
    }
    
    func removeCheckMark() {
        checkMarkImageView.image = nil
    }

    private func initialize() {
        accessoryType = .none
        contentView.backgroundColor = .ypLightGray
        [titleLabel,
         checkMarkImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 75),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            checkMarkImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -21),
            checkMarkImageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
