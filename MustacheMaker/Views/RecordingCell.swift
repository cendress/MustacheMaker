//
//  RecordingCell.swift
//  MustacheMaker
//
//  Created by Christopher Endress on 5/10/24.
//

import AVFoundation
import CoreData
import UIKit

class RecordingCell: UICollectionViewCell {
  static let identifier = "RecordingCell"
  
  private var tagLabel: UILabel!
  private var durationLabel: UILabel!
  private var previewImageView: UIImageView!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  //MARK: - Setup UI method
  
  private func setupViews() {
    backgroundColor = .lightGray
    
    tagLabel = UILabel()
    tagLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    tagLabel.textColor = .label
    
    durationLabel = UILabel()
    durationLabel.font = UIFont.systemFont(ofSize: 12)
    durationLabel.textColor = .label
    
    previewImageView = UIImageView()
    previewImageView.contentMode = .scaleAspectFill
    previewImageView.clipsToBounds = true
    previewImageView.image = UIImage(systemName: "questionmark.video")
    
    addSubview(tagLabel)
    addSubview(durationLabel)
    addSubview(previewImageView)
    
    tagLabel.translatesAutoresizingMaskIntoConstraints = false
    durationLabel.translatesAutoresizingMaskIntoConstraints = false
    previewImageView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      previewImageView.topAnchor.constraint(equalTo: topAnchor),
      previewImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
      previewImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
      previewImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.6),
      
      tagLabel.topAnchor.constraint(equalTo: previewImageView.bottomAnchor, constant: 2),
      tagLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
      tagLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
      
      durationLabel.topAnchor.constraint(equalTo: tagLabel.bottomAnchor, constant: 2),
      durationLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
      durationLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5)
    ])
  }
  
  func configure(with recording: NSManagedObject) {
    if let tag = recording.value(forKey: "tag") as? String {
      tagLabel.text = tag
    }
    
    if let duration = recording.value(forKey: "duration") as? Double {
      durationLabel.text = "\(formatDuration(duration))"
    }
    
    if let videoURL = recording.value(forKey: "videoURL") as? String {
      setThumbnailFromVideo(videoURL: videoURL)
    } else {
      previewImageView.image = UIImage(systemName: "questionmark.video")
    }
  }
  
  //MARK: - Helper methods
  
  private func formatDuration(_ duration: Double) -> String {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .positional
    formatter.allowedUnits = [.minute, .second]
    formatter.zeroFormattingBehavior = [.pad]
    return formatter.string(from: TimeInterval(duration)) ?? ""
  }
  
  private func setThumbnailFromVideo(videoURL: String) {
    DispatchQueue.global().async {
      let asset = AVAsset(url: URL(fileURLWithPath: videoURL))
      let assetImgGenerate = AVAssetImageGenerator(asset: asset)
      assetImgGenerate.appliesPreferredTrackTransform = true
      let time = CMTimeMakeWithSeconds(1.0, preferredTimescale: 600)
      
      do {
        let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
        let thumbnail = UIImage(cgImage: img)
        DispatchQueue.main.async {
          self.previewImageView.image = thumbnail
        }
      } catch {
        DispatchQueue.main.async {
          self.previewImageView.image = UIImage(systemName: "questionmark.video")
        }
      }
    }
  }
}
