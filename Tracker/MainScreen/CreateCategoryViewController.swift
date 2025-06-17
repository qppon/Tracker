//
//  CreateCategoryViewController.swift
//  Tracker
//
//  Created by Jojo Smith on 6/15/25.
//

import UIKit
protocol CreateCategoryViewControllerDelegate: UIViewController {
    func create(category: TrackerCategory)
    func update(category: TrackerCategory, categoryName: String)
}

final class CreateCategoryViewController: UIViewController, UITextFieldDelegate {
    
    weak var delegate: CreateCategoryViewControllerDelegate?
    var category: TrackerCategory?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 16
        textField.placeholder = "Введите название категории"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        textField.leftViewMode = .always
        textField.addTarget(self, action: #selector(didEditTextField), for: .editingChanged)
        textField.delegate = self
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 29, height: 75))
        clearButton.center = CGPoint(x: paddingView.frame.width - 12 - 8.5, y: paddingView.frame.height / 2)
        paddingView.addSubview(clearButton)
        textField.rightView = paddingView
        textField.rightViewMode = .whileEditing
        clearButton.isHidden = true
        return textField
    }()
    
    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .gray
        button.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 17, height: 17)
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .gray
        button.isEnabled = false
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        return button
    }()
    
    
    override func viewDidLoad() {
        setUpUI()
    }
    
    @objc
    private func didEditTextField() {
        if let text = textField.text, !text.isEmpty {
            clearButton.isHidden = false
            createButton.isEnabled = true
            createButton.backgroundColor = .black
        } else {
            clearButton.isHidden = true
            createButton.isEnabled = false
            createButton.backgroundColor = .gray
        }
    }
    
    @objc
    private func clearTextField() {
        textField.text = ""
        clearButton.isHidden = true
        createButton.isEnabled = false
        createButton.backgroundColor = .gray
    }
    
    @objc
    private func didTapCreateButton() {
        guard let categoryName = textField.text,
              !categoryName.isEmpty else {return}
        if let category {
            delegate?.update(category: category, categoryName: categoryName)
        } else {
            let newCategory = TrackerCategory(category: categoryName, trackers: [])
            delegate?.create(category: newCategory)
        }
        dismiss(animated: true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    private func addTapGestureToHideKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGesture))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func tapGesture() {
        textField.resignFirstResponder()
    }
    
    private func setUpUI() {
        addTapGestureToHideKeyboard()
        textField.delegate = self
        view.backgroundColor = .systemBackground
        titleLabel.text = (category != nil) ? "Редактировать категорию" : "Новая категория"
        textField.text = category?.category
        
        
        [titleLabel, textField, createButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}
