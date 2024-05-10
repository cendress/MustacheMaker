//
//  RecordingCell.swift
//  MustacheMaker
//
//  Created by Christopher Endress on 5/10/24.
//

import CoreData
import UIKit

class RecordingCell: UICollectionViewCell {
  static let identifier = "RecordingCell"
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupViews() {
    backgroundColor = .lightGray
  }
  
  func configure(with recording: NSManagedObject) {
    // Set UI components
  }
}
