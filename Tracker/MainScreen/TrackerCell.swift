//
//  TrackerCell.swift
//  Tracker
//
//  Created by Jojo Smith on 3/10/25.
//

import UIKit

protocol TrackerCellDelegate: AnyObject {
    func didTapDoneButton(isCompleted: Bool, trackerId: UUID)
}

final class TrackerCell: UICollectionViewCell {
    let cardView = UIView()
    let circleView = UIView()
    let emojiLabel = UILabel()
    let textLabel = UILabel()
    let daysLabel = UILabel()
    let doneButton = UIButton()
    let colors = Colors()
    
    let pinImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "pin"))
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
    
    weak var delegate: TrackerCellDelegate?
    
    var id: UUID?
    var isComplted = false
    var isCompletable = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.layer.cornerRadius = 16
        
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.layer.cornerRadius = 12
        
        circleView.backgroundColor = .white.withAlphaComponent(0.3)
        
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.font = .systemFont(ofSize: 16, weight: .medium)
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        textLabel.textColor = .white
        
        
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        daysLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        daysLabel.textColor = colors.labelColor
        
        
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.layer.cornerRadius = 17
        doneButton.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        
        circleView.addSubview(emojiLabel)
        contentView.addSubviews([cardView, daysLabel, doneButton])
        cardView.addSubviews([circleView, textLabel, pinImageView])
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            circleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            circleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            circleView.heightAnchor.constraint(equalToConstant: 24),
            circleView.widthAnchor.constraint(equalToConstant: 24),
            
            emojiLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            
            textLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            textLabel.widthAnchor.constraint(equalToConstant: contentView.frame.width - 24),
            textLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysLabel.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 16),
            
            doneButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            doneButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            doneButton.heightAnchor.constraint(equalToConstant: 34),
            doneButton.widthAnchor.constraint(equalToConstant: 34),
            
            pinImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            pinImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            pinImageView.widthAnchor.constraint(equalToConstant: 8),
            pinImageView.heightAnchor.constraint(equalToConstant:12)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc
    private func didTapDoneButton() {
        guard isCompletable,
        let id else {
            return
        }
        isComplted = !isComplted
        let newButtonImage = isComplted ? UIImage(resource: .done) : UIImage(resource: .addTracker)
        doneButton.setImage(newButtonImage, for: .normal)
        doneButton.alpha = isComplted ? 0.3 : 1
        delegate?.didTapDoneButton(isCompleted: isComplted, trackerId: id)
    }
}
