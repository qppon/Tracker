//
//  ViewController.swift
//  Tracker
//
//  Created by Jojo Smith on 3/3/25.
//

import UIKit

final class TrackersViewController: UIViewController, TrackerSettingsViewControllerDelegate, UISearchBarDelegate {
    
    private let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let datePicker = UIDatePicker()
    var currentDate = Date()
    
    private let placeholderLabel = UILabel()
    private let placeholderImage = UIImageView(image: .placeHolder)
    private var searchBarTrailingConstraint: NSLayoutConstraint!
    private var trackerStore: TrackerStore!
    private let searchBar = UISearchBar()
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var trackers: [TrackerCD] = []
    private let weekdays = ["Воскресенье", "Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота"]
    private let colors = Colors()
    
    func deleteTracker(tracker: Tracker) {
        var newCategories: [TrackerCategory] = self.categories
        
        guard let categoryIndex = self.categories.firstIndex(where: {$0.category == tracker.category}) else {
            return
        }
        var newTrackers: [Tracker] = newCategories[categoryIndex].trackers
        newTrackers.removeAll(where: {$0.id == tracker.id})
        
        let updatedCategor = TrackerCategory(category: tracker.category, trackers: newTrackers)
        
        newCategories[categoryIndex] = updatedCategor
        
        self.categories = newCategories
        
        self.trackerStore.deleteTracker(trackerID: tracker.id)
    }
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AnalyticsService.shared.sendEvent(event: "open", screen: "Main")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        AnalyticsService.shared.sendEvent(event: "close", screen: "Main")
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
                let isPined = cDTracker.isPined
                let category = cDTracker.category?.category ?? ""
                
                return Tracker(
                    id: id,
                    name: name,
                    color: UIColor.fromHex(hex: color),
                    emoji: emoji,
                    calendar: calendar,
                    date: cDTracker.date,
                    isPined: isPined,
                    category: category
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
        button.tintColor = colors.labelColor
        return button
    }
    
    private lazy var filter: UIButton = {
        let filter = UIButton()
        filter.isHidden = true
        filter.backgroundColor = .ypBlue
        filter.setTitle(NSLocalizedString("filtrs", comment: ""), for: .normal)
        filter.layer.cornerRadius = 16
        filter.translatesAutoresizingMaskIntoConstraints = false
        filter.setContentCompressionResistancePriority(.required, for: .vertical)
        filter.addTarget(self, action: #selector(didTapFilter), for: .touchUpInside)
        filter.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        return filter
    }()
    
    @objc
    private func didTapFilter() {
        AnalyticsService.shared.sendEvent(event: "click", screen: "Main", item: "filter")
        
        let filtrController = FiltrController()
        filtrController.delegate = self
        filtrController.modalPresentationStyle = .automatic
        present(filtrController, animated: true, completion: nil)
    }
    
    private func makeTrackersLabel() -> UILabel {
        let label = UILabel()
        label.text = NSLocalizedString("trecers.title", comment: "")
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = colors.labelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.tintColor = .ypBlue
        button.isHidden = true
        return button
    }()
    
    private func makeSearchBar() -> UISearchBar {
        searchBar.placeholder = "Поиск"
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
        return searchBar
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    cancelButton.isHidden = false
    searchBarTrailingConstraint.constant = -104
    UIView.animate(withDuration: 0.1) {
        self.view.layoutIfNeeded()
    }
}
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        setVisibleTrackers()
    }

    @objc
    private func stopFind() {
        cancelButton.isHidden = true
        searchBarTrailingConstraint.constant = -16
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
        searchBar.text = ""
        setVisibleTrackers()
        searchBar.resignFirstResponder()
    }
    
    private func addTapGestureToHideKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGesture))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc
    func tapGesture() {
        searchBar.resignFirstResponder()
    }
    
    private func makePlaceHolderImage() -> UIImageView {
        placeholderImage.translatesAutoresizingMaskIntoConstraints = false
        placeholderImage.contentMode = .scaleAspectFill
        return placeholderImage
    }
    
    private func makePlaceHolderLabel() -> UILabel {
        placeholderLabel.text = "Что будем отслеживать?"
        placeholderLabel.font = .systemFont(ofSize: 12, weight: .medium)
        placeholderLabel.textColor = colors.labelColor
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        return placeholderLabel
    }
    
    private func makeDatePicker() -> UIDatePicker {
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.overrideUserInterfaceStyle = .light
        datePicker.backgroundColor = .white
        datePicker.clipsToBounds = true
        datePicker.layer.cornerRadius = 8
        datePicker.date = Date()
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
        view.backgroundColor = colors.viewBackgroundColor
        let trackersLabel = makeTrackersLabel()
        let searchBar = makeSearchBar()
        let placeHolderImage = makePlaceHolderImage()
        let placeHolderLabel = makePlaceHolderLabel()
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(stopFind), for: .touchUpInside)
        addTapGestureToHideKeyboard()
        
        
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.dataSource = self
        collection.delegate = self
        collection.backgroundColor = colors.viewBackgroundColor
        collection.register(TrackerCell.self, forCellWithReuseIdentifier: "cell")
        collection.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collection.isHidden = visibleCategories.isEmpty
        
        searchBarTrailingConstraint = searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        
        view.addSubviews([trackersLabel, searchBar, placeHolderImage, placeHolderLabel, collection, cancelButton, filter])
        
        let guide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            trackersLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: 1),
            trackersLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            
            searchBar.topAnchor.constraint(equalTo: trackersLabel.bottomAnchor, constant: 7),
            searchBarTrailingConstraint,
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
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
            collection.widthAnchor.constraint(equalToConstant: view.frame.width),
            
            cancelButton.leadingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: 5),
            cancelButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            
            filter.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filter.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filter.heightAnchor.constraint(equalToConstant: 50),
            filter.widthAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    @objc
    private func didTapPlusButton() {
        AnalyticsService.shared.sendEvent(event: "click", screen: "Main", item: "add_track")
        
        let makeTrackerViewController = MakeTrackerViewController()
        makeTrackerViewController.trackersViewController = self
        navigationController?.present(makeTrackerViewController, animated: true)
    }
    
    @objc
    private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        setVisibleTrackers()
    }
    
    private func setNewTracker(tracker: Tracker) -> Tracker? {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: currentDate) - 1
        if !(tracker.calendar?.isEmpty ?? true) {
            if let trackerCalendar = tracker.calendar {
                for trackerWeekday in trackerCalendar {
                    if weekdays.firstIndex(of: trackerWeekday.rawValue) ?? 0 == weekday {
                        return tracker
                    }
                }
            }
        }
        else {
            guard let trackerDate = tracker.date else {
                assertionFailure("no tracker date")
                return nil
            }
            if calendar.compare(trackerDate, to: currentDate, toGranularity: .day) == .orderedSame {
                return tracker
            }
        }
        return nil
    }
    
    private func setPinedTrackers() -> TrackerCategory? {
        let calendar = Calendar.current
        var trackers: [Tracker] = []
        for category in categories {
            for tracker in category.trackers {
                if tracker.isPined == true {
                    if let newTracker = setNewTracker(tracker: tracker) {
                        trackers.append(newTracker)
                    }
                }
            }
        }
        if !trackers.isEmpty {
            return TrackerCategory(category: "Закрепленные", trackers: trackers)
        }
        return nil
    }
    
    private func setUpPLaceholderOrColletcoin(completedOrNot: TrackerFilter? = nil) {
        if visibleCategories.isEmpty {
            collection.isHidden = true
            filter.isHidden = true
            if completedOrNot != nil {
                placeholderImage.image = .notFind
                placeholderLabel.text = "Ничего не найдено"
                filter.isHidden = false
            } else if (searchBar.text?.isEmpty ?? true) {
                placeholderImage.image = .placeHolder
                placeholderLabel.text = "Что будем отслеживать?"
                filter.isHidden = true
            }
            else {
                placeholderImage.image = .notFind
                placeholderLabel.text = "Ничего не найдено"
            }
            return
        }
        filter.isHidden = false
        collection.isHidden = false
        collection.reloadData()
    }
    
    private func setVisibleTrackers(completedOrNot: TrackerFilter? = nil) {
        let calendar = Calendar.current
        visibleCategories = []
        if let pinedTrackers = setPinedTrackers() {
            visibleCategories.append(pinedTrackers)
        }
        if categories.isEmpty {
            return
        }
        for category in categories {
            var newTrackers: [Tracker] = []
            for tracker in category.trackers {
                if tracker.isPined == false {
                    if let trackerFilter = completedOrNot {
                        if trackerFilter == .completed {
                            for completedTracker in completedTrackers {
                                if completedTracker.id == tracker.id {
                                    if calendar.compare(completedTracker.date, to: currentDate, toGranularity: .day) == .orderedSame {
                                        newTrackers.append(tracker)
                                        break
                                    }
                                }
                            }
                        } else {
                            if let newTracker = setNewTracker(tracker: tracker){
                                if !completedTrackers.contains(where: {(calendar.compare($0.date, to: currentDate, toGranularity: .day) == .orderedSame) && $0.id == newTracker.id}) {
                                    newTrackers.append(newTracker)
                                }
                            }
                        }
                    }
                    else if let searchText = searchBar.text, !searchText.isEmpty {
                        if tracker.name.contains(searchText) {
                            if let newTracker = setNewTracker(tracker: tracker) {
                                newTrackers.append(newTracker)
                            }
                        }
                    } else {
                        if let newTracker = setNewTracker(tracker: tracker) {
                            newTrackers.append(newTracker)
                        }
                    }
                }
            }
            if !newTrackers.isEmpty {
                visibleCategories.append(TrackerCategory(category: category.category, trackers: newTrackers))
            }
        }
        setUpPLaceholderOrColletcoin(completedOrNot: completedOrNot)
    }
    
}

extension TrackersViewController: FiltrControllerDelegate {
    func didSelectFilter(_ filter: TrackerFilter) {
        switch filter{
        case .all:
            setVisibleTrackers()
        case .completed:
            setVisibleTrackers(completedOrNot: filter)
        case .notCompleted:
            setVisibleTrackers(completedOrNot: filter)
        case .today:
            datePicker.date = Date()
            currentDate = Date()
            setVisibleTrackers()
        }
        
    }
}

extension TrackersViewController: UICollectionViewDataSource, TrackerCellDelegate {
    
    func didTapDoneButton(isCompleted: Bool, trackerId: UUID) {
        AnalyticsService.shared.sendEvent(event: "click", screen: "Main", item: "track")
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
        return visibleCategories[section].trackers.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TrackerCell else {
            print("трекер не найден")
            return UICollectionViewCell()
        }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let isComplted = isTrackerCompleted(trackerId: tracker.id)
        cell.isComplted = isComplted
        cell.delegate = self
        
        let isBefore = Calendar.current.compare(Date(), to: currentDate, toGranularity: .day)
        cell.isCompletable = isBefore != .orderedAscending
        
        cell.cardView.backgroundColor = tracker.color
        
        cell.textLabel.text = tracker.name
        
        cell.emojiLabel.text = tracker.emoji
        cell.pinImageView.isHidden = !tracker.isPined
        
        cell.doneButton.backgroundColor = tracker.color
        let plusButtonImage = isComplted ? UIImage(resource: .done) : UIImage(resource: .addTracker)
        cell.doneButton.setImage(plusButtonImage.withTintColor(colors.viewBackgroundColor), for: .normal)
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
        let format = NSLocalizedString("days.count", comment: "")
        return String.localizedStringWithFormat(format, numberOfDays)
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? SupplementaryView else {
            return UICollectionReusableView()
        }
        view.titleLabel.text = visibleCategories[indexPath.section].category
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.width - 42) / 2, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section < visibleCategories.count - 1 {
            return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        } else {
            return UIEdgeInsets(top: 0, left: 16, bottom: 60, right: 16)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
}

extension TrackersViewController {
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
            let tracker = self.visibleCategories[indexPath.section].trackers[indexPath.row]
            let pinTitle = tracker.isPined ? "Открепить" : "Закрепить"
                        
            let saveAction = UIAction(title: pinTitle) { _ in
                self.trackerStore.togleIsPined(trackerID: tracker.id)
                self.loadTrackers()
                self.setVisibleTrackers()
            }
            
            let editAction = UIAction(title: "Редактировать") { _ in
                if tracker.date == nil {
                    let trackerSettingsViewController = TrackerSettingsViewController()
                    trackerSettingsViewController.trackerType = TrackerTypes.habit
                    trackerSettingsViewController.tracker = tracker
                    trackerSettingsViewController.delegate = self
                    self.present(trackerSettingsViewController, animated: true)
                } else {
                    let trackerSettingsViewController = TrackerSettingsViewController()
                    trackerSettingsViewController.trackerType = TrackerTypes.notRegular
                    trackerSettingsViewController.tracker = tracker
                    trackerSettingsViewController.delegate = self
                    self.present(trackerSettingsViewController, animated: true)
                }
            }
            
            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { _ in
                AnalyticsService.shared.sendEvent(event: "click", screen: "Main", item: "delete")
                
                let alert = UIAlertController(
                    title: nil,
                    message: "Уверены что хотите удалить трекер?",
                    preferredStyle: .actionSheet
                )
                
                let confirm = UIAlertAction(title: "Удалить", style: .destructive) { _ in
                    var newCategories: [TrackerCategory] = self.categories
                    
                    guard let categoryIndex = self.categories.firstIndex(where: {$0.category == tracker.category}) else {
                        return
                    }
                    var newTrackers: [Tracker] = newCategories[categoryIndex].trackers
                    newTrackers.removeAll(where: {$0.id == tracker.id})
                    
                    let updatedCategor = TrackerCategory(category: tracker.category, trackers: newTrackers)
                    
                    newCategories[categoryIndex] = updatedCategor
                    
                    self.categories = newCategories
                    
                    self.trackerStore.deleteTracker(trackerID: tracker.id)
                    
                    if let trackerRecord = self.completedTrackers.first(where: {tracker.id == $0.id}) {
                        TrackerRecordStore.shared.deleteRecord(completedTracker: trackerRecord)
                    }
                    self.setVisibleTrackers()
                }
                
                let cancel = UIAlertAction(title: "Отменить", style: .cancel)
                
                alert.addAction(confirm)
                alert.addAction(cancel)
                self.present(alert, animated: true)
            }
            
            return UIMenu(title: "", children: [saveAction, editAction, deleteAction])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell else {
            return nil
        }
        
        let targetView = cell.cardView
        let parameters = UIPreviewParameters()
        parameters.visiblePath = UIBezierPath(roundedRect: targetView.bounds, cornerRadius: 16)
        parameters.backgroundColor = .clear
        
        return UITargetedPreview(view: targetView, parameters: parameters)
    }
}
