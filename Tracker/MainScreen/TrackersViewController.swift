//
//  ViewController.swift
//  Tracker
//
//  Created by Jojo Smith on 3/3/25.
//

import UIKit

final class TrackersViewController: UIViewController, TrackerSettingsViewControllerDelegate {
    
    private let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let datePicker = UIDatePicker()
    var currentDate = Date()
    
    private var trackerStore: TrackerStore!
    
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var trackers: [TrackerCD] = []
    private let weekdays = ["Воскресенье", "Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота"]
    
    
    
    func addTracker(category: String, tracker: Tracker) {
        dismiss(animated: true)
        var updatedCategories = categories
        
        if let categoryIndex = updatedCategories.firstIndex(where: { $0.category == category }) {
            let updatedTrackers = updatedCategories[categoryIndex].trackers + [tracker]
            
            let updatedCategory = TrackerCategory(category: updatedCategories[categoryIndex].category, trackers: updatedTrackers)
            updatedCategories[categoryIndex] = updatedCategory
        } else {
            let newCategory = TrackerCategory(category: category, trackers: [tracker])
            updatedCategories.append(newCategory)
        }
        
        self.categories = updatedCategories
        
        
        setVisibleTrackers()
    }
    
    
    
    override func viewDidLoad() {
        
        trackerStore = TrackerStore(context: PersistenceController.shared.context)
        trackerStore.onUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.updateCategoriesFromCoreData()
            }
        }
        super.viewDidLoad()
        loadTrackers()
        loadCompletedTrackers()
        collection.reloadData()
        setUp()
        setVisibleTrackers()
    }
    
    private func loadCompletedTrackers() {
        let fetchedCompletedTrackers = TrackerRecordStore.shared.fetchRecords()
        TrackerRecordStore.shared.completedTrackers = fetchedCompletedTrackers
        for fetchedCompletedTracker in fetchedCompletedTrackers {
            guard let id = fetchedCompletedTracker.id,
                  let date = fetchedCompletedTracker.date else {
                return
            }
            let trackerRecord = TrackerRecord(id: id, date: date)
            completedTrackers.append(trackerRecord)
        }
    }
    
    func loadTrackers() {
        self.trackers = trackerStore.getTrackers()
        updateCategoriesFromCoreData()
        collection.reloadData()
    }
    
    func updateCategoriesFromCoreData() {
        let fetchedCategories = TrackerCategoryStore.shared.fetchCategories()
        
        categories = fetchedCategories.map { category in
            
            let trackers: [Tracker] = (category.trackers as? Set<TrackerCD>)?.compactMap { cDTracker in
                guard let id = cDTracker.id else {
                    fatalError()
                }
                
                let name = cDTracker.name ?? "Без названия"
                let emoji = cDTracker.emoji ?? "❓"
                let color = cDTracker.color ?? ""
                let calendarData = cDTracker.calendar as? Data
                let calendar = decodeCalendar(from: calendarData)
                
                return Tracker(
                    id: id,
                    name: name,
                    color: UIColor.fromHex(hex: color),
                    emoji: emoji,
                    calendar: calendar,
                    date: cDTracker.date
                )
            } ?? []
            
            let category = category.category ?? "Без категории"
            return TrackerCategory(category: category, trackers: trackers)
        }
        
    }
    
    func decodeCalendar(from data: Data?) -> [Weekday] {
        guard let data = data else { return [] }
        do {
            return try JSONDecoder().decode([Weekday].self, from: data)
        } catch {
            print("Ошибка декодирования календаря: \(error)")
            return []
        }
    }
    
    private func makePlusButton() -> UIButton {
        let button = UIButton.systemButton(with: UIImage(resource: .addTracker),
                                           target: self,
                                           action: #selector(self.didTapPlusButton))
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
    
    private func makeSearchBar() -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
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
    
    private func makeDatePicker() -> UIDatePicker {
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return datePicker
    }
    
    private func setUpNavBar() {
        let PlusButton = makePlusButton()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: PlusButton)
        
        let datePicker = makeDatePicker()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func setUp() {
        setUpNavBar()
        view.backgroundColor = .white
        let trackersLabel = makeTrackersLabel()
        let searchBar = makeSearchBar()
        let placeHolderImage = makePlaceHolderImage()
        let placeHolderLabel = makePlaceHolderLabel()
        
        
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.dataSource = self
        collection.delegate = self
        collection.register(TrackerCell.self, forCellWithReuseIdentifier: "cell")
        collection.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collection.isHidden = visibleCategories.isEmpty
        
        view.addSubviews([trackersLabel, searchBar, placeHolderImage, placeHolderLabel, collection])
        
        let guide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            trackersLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: 1),
            trackersLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            
            searchBar.topAnchor.constraint(equalTo: trackersLabel.bottomAnchor, constant: 7),
            searchBar.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            searchBar.widthAnchor.constraint(equalToConstant: view.frame.width - 32),
            searchBar.heightAnchor.constraint(equalToConstant: 36),
            
            placeHolderImage.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 230),
            placeHolderImage.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            placeHolderImage.widthAnchor.constraint(equalToConstant: 80),
            placeHolderImage.heightAnchor.constraint(equalToConstant: 80),
            
            placeHolderLabel.topAnchor.constraint(equalTo: placeHolderImage.bottomAnchor, constant: 8),
            placeHolderLabel.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            
            collection.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            collection.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            collection.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            collection.widthAnchor.constraint(equalToConstant: view.frame.width)
        ])
    }
    
    @objc
    private func didTapPlusButton() {
        let makeTrackerViewController = MakeTrackerViewController()
        makeTrackerViewController.trackersViewController = self
        navigationController?.present(makeTrackerViewController, animated: true)
    }
    
    @objc
    private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        setVisibleTrackers()
    }
    
    private func setVisibleTrackers() {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: currentDate) - 1
        var newTrackers: [Tracker] = []
        if categories.isEmpty {
            return
        }
        
        for tracker in categories[0].trackers {
            if !(tracker.calendar?.isEmpty ?? true) {
                if let trackerCalendar = tracker.calendar {
                    for trackerWeekday in trackerCalendar {
                        if weekdays.firstIndex(of: trackerWeekday.rawValue)! == weekday {
                            newTrackers.append(tracker)
                        }
                    }
                }
            }
            else {
                guard let trackerDate = tracker.date else {
                    assertionFailure("no tracker date")
                    return
                }
                if calendar.compare(trackerDate, to: currentDate, toGranularity: .day) == .orderedSame {
                    newTrackers.append(tracker)
                }
            }
            
        }
        if newTrackers.isEmpty {
            collection.isHidden = true
            return
        } else {
            visibleCategories = [TrackerCategory(category: categories[0].category, trackers: newTrackers)]
            collection.isHidden = false
            collection.reloadData()
        }
    }
}

extension TrackersViewController: UICollectionViewDataSource, TrackerCellDelegate {
    
    func didTapDoneButton(isCompleted: Bool, trackerId: UUID) {
        if isCompleted {
            completedTrackers.append(TrackerRecord(id: trackerId, date: currentDate))
            TrackerRecordStore.shared.saveRecord(forTracker: trackerId, onDate: currentDate)
        } else {
            completedTrackers.removeAll { Calendar.current.compare($0.date, to: currentDate, toGranularity: .day) == .orderedSame && $0.id == trackerId}
            TrackerRecordStore.shared.deleteRecord(completedTracker: TrackerRecord(id: trackerId, date: currentDate))
        }
        collection.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if visibleCategories.isEmpty {
            return 0
        }
        return visibleCategories[0].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TrackerCell else {
            print("трекер не найден")
            return UICollectionViewCell()
        }
        let tracker = visibleCategories[0].trackers[indexPath.row]
        let isComplted = isTrackerCompleted(trackerId: tracker.id)
        cell.isComplted = isComplted
        cell.delegate = self
        
        let isBefore = Calendar.current.compare(Date(), to: currentDate, toGranularity: .day)
        cell.isCompletable = isBefore != .orderedAscending
        
        cell.cardView.backgroundColor = tracker.color
        
        cell.textLabel.text = tracker.name
        
        cell.emojiLabel.text = tracker.emoji
        
        cell.doneButton.backgroundColor = tracker.color
        let plusButtonImage = isComplted ? UIImage(resource: .done) : UIImage(resource: .addTracker)
        cell.doneButton.setImage(plusButtonImage.withTintColor(.white), for: .normal)
        cell.doneButton.alpha = isComplted ? 0.3 : 1
        
        cell.id = tracker.id
        let numberOfDays = completedTrackers.count { $0.id == tracker.id }
        
        cell.daysLabel.text = setDaysLabel(numberOfDays: numberOfDays)
        
        return cell
    }
    
    private func isTrackerCompleted(trackerId: UUID) -> Bool {
        completedTrackers.contains { $0.id == trackerId && Calendar.current.compare($0.date, to: currentDate, toGranularity: .day) == .orderedSame}
    }
    
    private func setDaysLabel(numberOfDays: Int) -> String {
        let lastDigit = numberOfDays % 10
        let lastTwoDigits = numberOfDays % 100
        
        if numberOfDays == 0 || (lastTwoDigits >= 11 && lastTwoDigits <= 19) {
            return "\(numberOfDays) дней"
        } else if lastDigit == 1 {
            return "\(numberOfDays) день"
        } else if (2...4).contains(lastDigit) {
            return "\(numberOfDays) дня"
        } else {
            return "\(numberOfDays) дней"
        }
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? SupplementaryView
        view?.titleLabel.text = "Домашний уют"
        return view!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 167, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
}

