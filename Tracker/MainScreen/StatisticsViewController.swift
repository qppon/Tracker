//
//  Statistics.swift
//  Tracker
//
//  Created by Jojo Smith on 3/7/25.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
    private lazy var cryImage = UIImageView(image: UIImage(resource: .cry))
    
    private lazy var card: UIView = {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.masksToBounds = false
        return card
    }()
    
    private lazy var cryLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "Статистика"
        titleLabel.textColor = .forText
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return titleLabel
    }()
    
    private lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.98, green: 0.27, blue: 0.27, alpha: 1.0).cgColor,
            UIColor(red: 0.0, green: 0.68, blue: 0.43, alpha: 1.0).cgColor,
            UIColor(red: 0.2, green: 0.45, blue: 0.9, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.cornerRadius = 16
        return gradientLayer
    }()
    
    private lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlack
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Трекеров завершено"
        subtitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        subtitleLabel.textColor = .ypBlack
        return subtitleLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDaysLabel()
        setUpUI()
        view.backgroundColor = .white
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setDaysLabel()
    }
    private func setDaysLabel() {
        let numOfTrackerRecords = TrackerRecordStore.shared.fetchRecords().count
        numberLabel.text = String(numOfTrackerRecords)
        if numberLabel.text != "0" {
            cryImage.isHidden = true
            cryLabel.isHidden = true
            card.isHidden = false
            numberLabel.isHidden = false
            subtitleLabel.isHidden = false
        } else {
            card.isHidden = true
            numberLabel.isHidden = true
            subtitleLabel.isHidden = true
            cryImage.isHidden = false
            cryLabel.isHidden = false
        }
    }
    
    private func setUpUI() {
        [titleLabel, card, cryImage, cryLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            
            card.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            card.heightAnchor.constraint(equalToConstant: 90),
            
            cryImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cryImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cryImage.widthAnchor.constraint(equalToConstant: 80),
            cryImage.heightAnchor.constraint(equalToConstant: 80),
            
            cryLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cryLabel.topAnchor.constraint(equalTo: cryImage.bottomAnchor, constant: 8)
        ])
        
        [numberLabel, subtitleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        card.layer.insertSublayer(gradientLayer, at: 0)
        
        NSLayoutConstraint.activate([
            numberLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            numberLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            
            subtitleLabel.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: 7),
            subtitleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let card = view.subviews.first(where: { $0.layer.sublayers?.contains(gradientLayer) == true }) {
            gradientLayer.frame = card.bounds
            
            let maskLayer = CAShapeLayer()
            let outerPath = UIBezierPath(roundedRect: card.bounds, cornerRadius: 16)
            let innerPath = UIBezierPath(roundedRect: card.bounds.insetBy(dx: 1.5, dy: 1.5), cornerRadius: 14)
            outerPath.append(innerPath)
            maskLayer.path = outerPath.cgPath
            maskLayer.fillRule = .evenOdd
            gradientLayer.mask = maskLayer
        }
    }
}
