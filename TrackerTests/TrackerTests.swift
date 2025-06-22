//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Jojo Smith on 6/22/25.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

    func testViewControllerSnapshot() {

                let vc = TrackersViewController()
                vc.loadViewIfNeeded()
                vc.view.layoutIfNeeded()

        assertSnapshot(of: vc, as: .image)
    }
}
