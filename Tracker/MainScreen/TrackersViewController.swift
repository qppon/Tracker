//
//  ViewController.swift
//  Tracker
//
//  Created by Jojo Smith on 3/3/25.
//

import UIKit

class TrackersViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    private func makePlusButton() -> UIButton {
        let button = UIButton.systemButton(with: UIImage(resource: .addTracker),
                                           target: self,
                                           action: #selector(self.didTapPlusButton))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor(resource: .black)
        return button
    }
    
    private func makeTrackersLabel() -> UILabel {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor(resource: .black)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func makeDatePicker() -> UIView {
        let datePicker = UIView()
        datePicker.backgroundColor = .systemGray5
        datePicker.layer.cornerRadius = 8
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        let dateLabel = UILabel()
        dateLabel.text = "14.12.22"
        dateLabel.font = .systemFont(ofSize: 17, weight: .regular)
        dateLabel.textColor = UIColor(resource: .black)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        datePicker.addSubview(dateLabel)
        dateLabel.centerXAnchor.constraint(equalTo: datePicker.centerXAnchor).isActive = true
        dateLabel.centerYAnchor.constraint(equalTo: datePicker.centerYAnchor).isActive = true
        
        return datePicker
    }
    
    private func makeSearchBar() -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.text = "Поиск"
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        return searchBar
    }
    
    private func makePlaceHolderImage() -> UIImageView {
        let image = UIImageView(image: .placeHolder)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        return image
    }
    
    private func makePlaceHolderLabel() -> UILabel {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(resource: .black)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    
    private func setUp() {
        view.backgroundColor = .white
        let button = makePlusButton()
        let trackersLabel = makeTrackersLabel()
        let date = makeDatePicker()
        let searchBar = makeSearchBar()
        let placeHolderImage = makePlaceHolderImage()
        let placeHolderLabel = makePlaceHolderLabel()
        
        view.addSubviews([trackersLabel, button, date, searchBar, placeHolderImage, placeHolderLabel])
        
        
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: guide.topAnchor, constant: 1),
            button.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 6),
            button.widthAnchor.constraint(equalToConstant: 42),
            button.heightAnchor.constraint(equalToConstant: 42),
            
            trackersLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: 50),
            trackersLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            
            date.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),
            date.topAnchor.constraint(equalTo: guide.topAnchor, constant: 5),
            date.widthAnchor.constraint(equalToConstant: 77),
            date.heightAnchor.constraint(equalToConstant: 34),
            
            searchBar.topAnchor.constraint(equalTo: trackersLabel.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: trackersLabel.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: date.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 36),
            
            placeHolderImage.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 230),
            placeHolderImage.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            placeHolderImage.widthAnchor.constraint(equalToConstant: 80),
            placeHolderImage.heightAnchor.constraint(equalToConstant: 80),
            
            placeHolderLabel.topAnchor.constraint(equalTo: placeHolderImage.bottomAnchor, constant: 8),
            placeHolderLabel.centerXAnchor.constraint(equalTo: guide.centerXAnchor)
        ])
    }
    @objc
    private func didTapPlusButton() {
        
    }


}

