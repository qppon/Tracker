//
//  PageViewContrtoller.swift
//  Tracker
//
//  Created by Jojo Smith on 6/13/25.
//
enum PageType {
    case blue
    case red
}

import UIKit

final class PageViewContrtoller: UIViewController {
    private let image: UIImage
    private let text: String
    var onFinish: (() -> Void)?
    
    init(pageType: PageType) {
        if pageType == PageType.blue {
            self.image = .backgrBlue
            self.text = "Отслеживайте только \n то, что хотите"
        } else {
            self.image = .backgrRed
            self.text = "Даже если это \n не литры воды и йога"
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 432),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        let button = UIButton(type: .system)
        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(finishTapped), for: .touchUpInside)
        
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 60),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -84)
        ])
    }
    
    @objc private func finishTapped() {
        onFinish?()
    }
}
