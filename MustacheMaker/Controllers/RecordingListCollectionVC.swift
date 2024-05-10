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
    super.init(collectionViewLayout: UICollectionViewFlowLayout())
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
    // May need tweaking
    return CGSize(width: collectionView.bounds.width / 3 - 10, height: 150)
  }
  
  //MARK: - Fetch data method
  
  private func fetchRecordings() {
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
