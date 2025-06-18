//
//  TrackerSettingsViewController.swift
//  Tracker
//
//  Created by Jojo Smith on 3/17/25.
//

import UIKit

protocol TrackerSettingsViewControllerDelegate: AnyObject {
    func addTracker(category: String, tracker: Tracker)
}

enum TrackerTypes: String {
    case habit = "Новая привычка"
    case notRegular = "Нерегулярное событие"
}

final class TrackerSettingsViewController: UIViewController, ScheduleViewControllerDelegate, UITextFieldDelegate {
    
    
    let tableView = UITableView()
    let emojiCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let colorCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    weak var delegate: TrackerSettingsViewControllerDelegate?
    var trackerType: TrackerTypes?
    
    private var selectedEmojiIndex: IndexPath?
    private var selectedColorIndex: IndexPath?
    private var selectedWeekdays: [Weekday]?
    private var selectedColors: String?
    private var selectedEmoji: String?
    private var chosenCategoryName: String?
    private var selectedColor: UIColor?
    private let textField = UITextField()
    private let button = UIButton()
    private let clearButton = UIButton(type: .custom)
    private let emojies = [ "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    
    private let colors: [UIColor] = [
        .colorSelection1, .colorSelection2, .colorSelection3, .colorSelection4, .colorSelection5, .colorSelection6, .colorSelection7, .colorSelection8, .colorSelection9, .colorSelection10, .colorSelection11, .colorSelection12, .colorSelection13, .colorSelection14, .colorSelection15, .colorSelection16, .colorSelection17, .colorSelection18
    ]
    
    func setWeekdays(weekdays: [Weekday]) {
        selectedWeekdays = weekdays
        updateCreateButtonState()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    private func makeTitleLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func makeTextField() -> UITextField {
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 16
        textField.placeholder = "Введите название трекера"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        textField.leftViewMode = .always
        textField.addTarget(self, action: #selector(didEditTextField), for: .editingChanged)
        textField.delegate = self
        setupClearButton()
        return textField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func makeCreateButton() -> UIButton {
        button.addTarget(self, action: #selector(self.didTapCreateButton), for: .touchUpInside)
        button.setTitle("Создать", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    private func makeCancelButton() -> UIButton {
        let button = UIButton()
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.red.cgColor
        button.addTarget(self, action: #selector(self.didTapCancelButton), for: .touchUpInside)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .clear
        button.tintColor = .red
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    private func makeTableView() -> UITableView {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.allowsMultipleSelection = false
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.heightAnchor.constraint(equalToConstant: trackerType == TrackerTypes.habit ? 149 : 74).isActive = true
        return tableView
    }
    
    private func makeEmojiLabel() -> UILabel {
        let emojiLabel = UILabel()
        emojiLabel.text = "Emoji"
        emojiLabel.textColor = .black
        emojiLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.setContentHuggingPriority(.required, for: .vertical)
        emojiLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        return emojiLabel
    }
    
    private func makeColorLabel() -> UILabel {
        let color = UILabel()
        color.text = "Цвет"
        color.textColor = .black
        color.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        color.translatesAutoresizingMaskIntoConstraints = false
        return color
    }
    
    @objc
    private func didTapCreateButton() {
        guard let trackerType else {
            assertionFailure("no tracekr type")
            return
        }
        
        let context = PersistenceController.shared.context
        
        guard let categoryName = chosenCategoryName else {
            print("Category name is empty")
            return
        }
    
        guard let category = CoreDataService.shared.fetchCategory(byName: categoryName, context: context) else {
            print("Категория не найдена")
            return
        }
        let date = Date()
        if trackerType == TrackerTypes.notRegular {
            let trackerCD = TrackerCD(context: context)
            trackerCD.id = UUID()
            trackerCD.name = textField.text ?? ""
            trackerCD.color = selectedColors
            trackerCD.emoji = selectedEmoji
            trackerCD.calendar = nil
            trackerCD.date = date
            trackerCD.category = category
            
        
            do {
                try context.save()
                print("Трекер сохранен")
            } catch {
                print("[TrackerSettingsViewController]: Ошибка сохранения в CD \(error)")
                return
            }
            let tracker = Tracker(id: trackerCD.id ?? UUID(), name: textField.text ?? "", color: selectedColor ?? .colorSelection1, emoji: selectedEmoji ?? "", calendar: nil, date: date)
            delegate?.addTracker(category: categoryName, tracker: tracker)
            return
        }
        guard let selectedWeekdays else {
            print("noSelectedDays")
            return
        }
        
        guard let calendarData = try? JSONEncoder().encode(selectedWeekdays) else {
            print("ошибка при кодировании selectedWeekdays")
            return
        }
        
        let trackerCD = TrackerCD(context: context)
        trackerCD.id = UUID()
        trackerCD.name = textField.text ?? ""
        trackerCD.color = selectedColors
        trackerCD.emoji = selectedEmoji
        trackerCD.calendar = calendarData as NSData
        trackerCD.date = nil
        trackerCD.category = category
        
    
        do {
            try context.save()
            print("Трекер сохранен")
        } catch {
            print("[TrackerSettingsViewController]: Ошибка сохранения в CD \(error)")
            return
        }
        
        let tracker = Tracker(id: trackerCD.id ?? UUID(), name: textField.text ?? "", color: selectedColor ?? .colorSelection1, emoji: selectedEmoji ?? "", calendar: selectedWeekdays, date: nil)
        delegate?.addTracker(category: categoryName, tracker: tracker)
    }
    
    private func setupClearButton() {
        clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        clearButton.tintColor = .gray
        clearButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        clearButton.frame = CGRect(x: 0, y: 0, width: 17, height: 17)
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 29, height: 75))
        clearButton.center = CGPoint(x: paddingView.frame.width - 12 - 8.5, y: paddingView.frame.height / 2)
        paddingView.addSubview(clearButton)
        
        textField.rightView = paddingView
        textField.rightViewMode = .whileEditing
        clearButton.isHidden = true
    }
    
    func updateCreateButtonState() {
        var isFormValid = false
        if trackerType == TrackerTypes.habit {
            isFormValid = !(textField.text?.isEmpty ?? true) &&
            selectedWeekdays != nil &&
            selectedEmoji != nil &&
            selectedColor != nil &&
            chosenCategoryName != nil
        } else {
            isFormValid = !(textField.text?.isEmpty ?? true) &&
            selectedEmoji != nil &&
            selectedColor != nil &&
            chosenCategoryName != nil
        }
        
        if isFormValid {
            button.isEnabled = true
            button.backgroundColor = .black
        } else {
            button.isEnabled = false
            button.backgroundColor = .greyButton
        }
    }
    
    private func makeEmojiCollection() -> UICollectionView {
        emojiCollection.dataSource = self
        emojiCollection.delegate = self
        emojiCollection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "emojiCell")
        emojiCollection.allowsMultipleSelection = false
        return emojiCollection
    }
    
    private func makeColorCollection() -> UICollectionView {
        colorCollection.dataSource = self
        colorCollection.delegate = self
        colorCollection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ColorCell")
        colorCollection.allowsMultipleSelection = false
        return colorCollection
    }
    
    @objc
    private func didTapCancelButton() {
        self.dismiss(animated: true)
    }
    
    @objc
    private func didEditTextField() {
        clearButton.isHidden = textField.text?.isEmpty ?? true
        updateCreateButtonState()
    }
    
    @objc
    private func clearTextField() {
        textField.text = ""
        clearButton.isHidden = true
        updateCreateButtonState()
    }
    
    private func setUp() {
        view.backgroundColor = .white
        let label = makeTitleLabel(text: trackerType?.rawValue ?? "")
        let textField = makeTextField()
        let tableView = makeTableView()
        let cancelButton = makeCancelButton()
        let createButton = makeCreateButton()
        let emojiCollection = makeEmojiCollection()
        let emojiLabel = makeEmojiLabel()
        let colorLabel = makeColorLabel()
        emojiCollection.translatesAutoresizingMaskIntoConstraints = false
        
        let colorCollection = makeColorCollection()
        colorCollection.translatesAutoresizingMaskIntoConstraints = false
        
        let scrollView = UIScrollView(frame: view.frame)
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        
        contentView.addSubviews([label, textField, tableView, emojiLabel, colorLabel, emojiCollection, colorCollection, cancelButton, createButton])
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 34),
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            textField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 38),
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.widthAnchor.constraint(equalToConstant: view.frame.width - 32),
            textField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            tableView.widthAnchor.constraint(equalToConstant: view.frame.width - 32),
            tableView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            emojiLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 28),
            emojiLabel.widthAnchor.constraint(equalToConstant: 52),
            emojiLabel.heightAnchor.constraint(equalToConstant: 18),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 26),
            
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            emojiCollection.widthAnchor.constraint(equalToConstant: view.frame.width - 36),
            emojiCollection.heightAnchor.constraint(equalToConstant: 200),
            emojiCollection.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiCollection.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 4),
            
            colorLabel.topAnchor.constraint(equalTo: emojiCollection.bottomAnchor, constant: 8),
            colorLabel.widthAnchor.constraint(equalToConstant: 52),
            colorLabel.heightAnchor.constraint(equalToConstant: 18),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 26),
            
            colorCollection.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 4),
            colorCollection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            colorCollection.heightAnchor.constraint(equalToConstant: 200),
            
            cancelButton.topAnchor.constraint(equalTo: colorCollection.bottomAnchor, constant: 40),
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalToConstant: (view.frame.width - 48) / 2),
            
            createButton.widthAnchor.constraint(equalToConstant: (view.frame.width - 48) / 2),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.topAnchor.constraint(equalTo: colorCollection.bottomAnchor, constant: 40),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -70)
        ])
    }
}

extension TrackerSettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let trackerType else { return 1 }
        
        return trackerType.rawValue == TrackerTypes.habit.rawValue ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let image = UIImageView(image: .arrow)
        image.translatesAutoresizingMaskIntoConstraints = false
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? TableViewCell else {
            return UITableViewCell()
        }
        if indexPath.row == 0 {
            if let chosenCategoryName {
                cell.changeCategoryOrWeekdayLabel(categories: chosenCategoryName)
            }
            cell.titleLabel.text = "Категория"
        } else {
            if let selectedWeekdays {
                let selectedDaysString = selectedWeekdays.map { day in
                    switch day {
                    case .monday:
                        return("Пн")
                    case .tuesday:
                        return("Вт")
                    case .wednesday:
                        return("Ср")
                    case .thursday:
                        return("Чт")
                    case .friday:
                        return("Пт")
                    case .saturday:
                        return("Сб")
                    case .sunday:
                        return("Вс")
                    }
                }.joined(separator: ", ")
                cell.changeCategoryOrWeekdayLabel(categories: selectedDaysString)
            }
            cell.titleLabel.text = "Расписание"
        }

        
        
        return cell
    }
}

extension TrackerSettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let scheduleViewController = ScheduleViewController()
            scheduleViewController.delegate = self
            present(scheduleViewController, animated: true)
        }
        if indexPath.row == 0 {
            let categoryViewController = CategoryViewController(delegate: self, selectedCategory: chosenCategoryName, viewModel: CategoryViewModel())
            present(categoryViewController, animated: true)
        }
    }
    
}

extension TrackerSettingsViewController: CategoryViewControllerDelegate {
    func didSelect(category: String) {
        chosenCategoryName = category
        updateCreateButtonState()
        tableView.reloadData()
    }
}

extension TrackerSettingsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == emojiCollection ? emojies.count : colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiCell", for: indexPath)
            
            cell.contentView.subviews.forEach { $0.removeFromSuperview()}
            
            let label = UILabel()
            label.text = emojies[indexPath.item]
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 32)
            label.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
            label.translatesAutoresizingMaskIntoConstraints = false
            
            cell.contentView.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor
            ).isActive = true
            label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
            
            cell.contentView.addSubview(label)
            cell.contentView.layer.cornerRadius = 16
            cell.contentView.layer.masksToBounds = true
            if indexPath == selectedEmojiIndex {
                cell.contentView.backgroundColor = .forEmoji
            } else {
                cell.contentView.backgroundColor = .clear
            }
            return cell
        }
        
        if collectionView == colorCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath)
            
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            
            let color = colors[indexPath.item]
            
            let outerView = UIView()
            outerView.frame = CGRect(x: 0, y: 0, width: 52, height: 52)
            outerView.layer.cornerRadius = 8
            outerView.translatesAutoresizingMaskIntoConstraints = false
            outerView.backgroundColor = color
            cell.contentView.addSubview(outerView)
            
            let middleView = UIView()
            middleView.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
            middleView.layer.cornerRadius = 8
            middleView.alpha = 1
            middleView.backgroundColor = .white
            middleView.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(middleView)
            
            let innerView = UIView()
            innerView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            innerView.layer.cornerRadius = 8
            innerView.alpha = 1
            innerView.backgroundColor = color
            innerView.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(innerView)
            
            NSLayoutConstraint.activate([
                outerView.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                outerView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                outerView.widthAnchor.constraint(equalToConstant: 52),
                outerView.heightAnchor.constraint(equalToConstant: 52),
                
                middleView.centerXAnchor.constraint(equalTo: outerView.centerXAnchor),
                middleView.centerYAnchor.constraint(equalTo: outerView.centerYAnchor),
                middleView.widthAnchor.constraint(equalToConstant: 46),
                middleView.heightAnchor.constraint(equalToConstant: 46),
                
                innerView.centerXAnchor.constraint(equalTo: middleView.centerXAnchor),
                innerView.centerYAnchor.constraint(equalTo: middleView.centerYAnchor),
                innerView.widthAnchor.constraint(equalToConstant: 40),
                innerView.heightAnchor.constraint(equalToConstant: 40)
            ])
            
            if selectedColorIndex == indexPath {
                outerView.alpha = 0.3
                selectedColors = colors[indexPath.item].toHex()
            } else {
                outerView.alpha = 0
            }
            
            return cell
        }
        
        return UICollectionViewCell()
    }
}

extension TrackerSettingsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == colorCollection {
            let itemsPerRow: CGFloat = 6
            let spacing: CGFloat = 10
            let totalSpacing = (itemsPerRow - 1) * spacing
            let availableWidth = collectionView.bounds.width - totalSpacing
            let itemSize = floor(availableWidth / itemsPerRow)
            
            return CGSize(width: itemSize, height: itemSize)
        }
        
        if collectionView == emojiCollection {
            let itemsPerRow: CGFloat = 6
            let spacing: CGFloat = 10
            let totalSpacing = (itemsPerRow - 1) * spacing
            let availableWidth = collectionView.bounds.width - totalSpacing
            let itemSize = floor(availableWidth / itemsPerRow)
            
            return CGSize(width: itemSize, height: itemSize)
        }
        
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == colorCollection {
            if selectedColorIndex == indexPath {
                selectedColorIndex = nil
                selectedColor = nil
            } else {
                selectedColorIndex = indexPath
                selectedColor = colors[indexPath.item]
            }
        } else if collectionView == emojiCollection {
            if selectedEmojiIndex == indexPath {
                selectedEmojiIndex = nil
                selectedEmoji = nil
            } else {
                selectedEmojiIndex = indexPath
                selectedEmoji = emojies[indexPath.item]
            }
        }
        updateCreateButtonState()
        collectionView.reloadData()
    }
}

final class TableViewCell: UITableViewCell {
    
    private var titleLabelTopConstraint: NSLayoutConstraint?
    private var titleLabelCenterYConstraint: NSLayoutConstraint?
    private let image = UIImageView(image: .arrow)
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    
    lazy var categoryOrWeekdayLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setUpUI()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func updateTitleLabelConstraints() {
        if let text = categoryOrWeekdayLabel.text, !text.isEmpty {
            titleLabelCenterYConstraint?.isActive = false
            titleLabelTopConstraint?.isActive = true
        } else {
            titleLabelTopConstraint?.isActive = false
            titleLabelCenterYConstraint?.isActive = true
            
        }
        setNeedsLayout()
    }
    func changeCategoryOrWeekdayLabel(categories: String) {
        categoryOrWeekdayLabel.text = categories
        updateTitleLabelConstraints()
    }
    
    private func setUpUI() {
        selectionStyle = .none
        backgroundColor = .systemGray6
        [titleLabel, categoryOrWeekdayLabel, image].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        titleLabelTopConstraint = titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15)
        titleLabelCenterYConstraint = titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        titleLabelTopConstraint?.isActive = true
        titleLabelCenterYConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            categoryOrWeekdayLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            categoryOrWeekdayLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
            image.heightAnchor.constraint(equalToConstant: 24),
            image.widthAnchor.constraint(equalToConstant: 24),
            image.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            image.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        updateTitleLabelConstraints()
    }
}
