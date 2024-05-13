//
//  RecordingListCollectionVC.swift
//  MustacheMaker
//
//  Created by Christopher Endress on 5/10/24.
//

import CoreData
import UIKit

class RecordingsListCollectionVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  var recordings: [NSManagedObject] = []
  
  init() {
    let layout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    layout.minimumInteritemSpacing = 15
    layout.minimumLineSpacing = 15
    super.init(collectionViewLayout: layout)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = "Recordings"
    navigationController?.navigationBar.prefersLargeTitles = true
    
    collectionView.backgroundColor = .systemBackground
    collectionView.register(RecordingCell.self, forCellWithReuseIdentifier: RecordingCell.identifier)
    fetchRecordings()
    
    NotificationCenter.default.addObserver(self, selector: #selector(fetchRecordings), name: NSNotification.Name("NewRecordingSaved"), object: nil)
  }
  
  // Deinitialize notification observer to deallocate from memory
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  //MARK: - Collection view delegate & data source methods
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return recordings.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    // Optionally cast cells for safety
    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecordingCell.identifier, for: indexPath) as? RecordingCell {
      let recording = recordings[indexPath.row]
      cell.configure(with: recording)
      return cell
    }
    
    // Return a default cell if casting fails
    return collectionView.dequeueReusableCell(withReuseIdentifier: "DefaultCellIdentifier", for: indexPath)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let layout = collectionViewLayout as! UICollectionViewFlowLayout
    let numberOfColumns: CGFloat = 2
    let totalSpacing = layout.sectionInset.left + layout.sectionInset.right + (layout.minimumInteritemSpacing * (numberOfColumns - 1))
    let adjustedWidth = (collectionView.bounds.width - totalSpacing) / numberOfColumns
    return CGSize(width: adjustedWidth, height: 150)
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let recording = recordings[indexPath.row]
    let alertController = UIAlertController(title: "Edit Tag", message: "Enter a new tag:", preferredStyle: .alert)
    alertController.addTextField { textField in
      textField.text = recording.value(forKey: "tag") as? String
      textField.autocapitalizationType = .words
    }
    
    let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
      guard let textField = alertController.textFields?.first, let newTag = textField.text else { return }
      self?.updateTag(for: recording, newTag: newTag, at: indexPath)
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    alertController.addAction(saveAction)
    alertController.addAction(cancelAction)
    
    present(alertController, animated: true)
  }
  
  //MARK: - Update tag
  
  private func updateTag(for recording: NSManagedObject, newTag: String, at indexPath: IndexPath) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      print("Could not get AppDelegate")
      return
    }
    
    let context = appDelegate.persistentContainer.viewContext
    recording.setValue(newTag, forKey: "tag")
    
    do {
      try context.save()
      print("Tag updated successfully: \(newTag)")
      collectionView.reloadItems(at: [indexPath])
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
    }
  }
  
  
  //MARK: - Fetch data method
  
  @objc private func fetchRecordings() {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Recording")
    
    do {
      recordings = try managedContext.fetch(fetchRequest)
      collectionView.reloadData()
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
  }
}
