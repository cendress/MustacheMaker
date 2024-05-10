//
//  ViewController.swift
//  MustacheMaker
//
//  Created by Christopher Endress on 5/9/24.
//

import ARKit
import UIKit

class CameraVC: UIViewController, ARSCNViewDelegate {
  private var arSCNView: ARSCNView!
  private var startRecordingButton: UIButton!
  private var stopRecordingButton: UIButton!
  private var currentFaceNode: SCNNode?
  
  private let padding: CGFloat = 20
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupARSession()
  }
  
  //MARK: - Setup UI method
  
  private func setupUI() {
    arSCNView = ARSCNView()
    arSCNView.delegate = self
    
    // Might want to adjust names
    let mustacheSelector = UISegmentedControl(items: ["Mustache_A", "Mustache_B", "Mustache_C", "Mustache_D"])
    mustacheSelector.addTarget(self, action: #selector(handleMustacheChange(_:)), for: .valueChanged)
    
    startRecordingButton = UIButton()
    startRecordingButton.backgroundColor = .systemGreen
    startRecordingButton.setTitle("Start Recording".uppercased(), for: .normal)
    startRecordingButton.addTarget(self, action: #selector(startRecording), for: .touchUpInside)
    startRecordingButton.layer.cornerRadius = 25
    
    stopRecordingButton = UIButton()
    stopRecordingButton.backgroundColor = .systemRed
    stopRecordingButton.setTitle("Stop Recording".uppercased(), for: .normal)
    stopRecordingButton.addTarget(self, action: #selector(stopRecording), for: .touchUpInside)
    stopRecordingButton.layer.cornerRadius = 25
    
    view.addSubview(arSCNView)
    view.addSubview(mustacheSelector)
    view.addSubview(startRecordingButton)
    view.addSubview(stopRecordingButton)
    
    arSCNView.translatesAutoresizingMaskIntoConstraints = false
    mustacheSelector.translatesAutoresizingMaskIntoConstraints = false
    startRecordingButton.translatesAutoresizingMaskIntoConstraints = false
    stopRecordingButton.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      arSCNView.topAnchor.constraint(equalTo: view.topAnchor),
      arSCNView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      arSCNView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      arSCNView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      mustacheSelector.bottomAnchor.constraint(equalTo: startRecordingButton.topAnchor, constant: -padding),
      mustacheSelector.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
      mustacheSelector.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
      
      startRecordingButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
      startRecordingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
      startRecordingButton.heightAnchor.constraint(equalToConstant: 50),
      startRecordingButton.bottomAnchor.constraint(equalTo: stopRecordingButton.topAnchor, constant: -20),
      
      stopRecordingButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
      stopRecordingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
      stopRecordingButton.heightAnchor.constraint(equalToConstant: 50),
      stopRecordingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30)
    ])
  }
  
  //MARK: - Setup AR session method
  
  private func setupARSession() {
    // Exit if the device doesn't support AR face tracking
    guard ARFaceTrackingConfiguration.isSupported else {
      print("AR Face Tracking is not supported on this device.")
      return
    }
    
    let configuration = ARFaceTrackingConfiguration()
    // Reset face tracking and any existing anchors when session starts
    arSCNView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
  }
  
  //MARK: - Mustache creation methods
  
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    guard let faceAnchor = anchor as? ARFaceAnchor else { return }
    
    DispatchQueue.main.async {
      self.currentFaceNode = node
      self.addMustache(to: node, style: "Mustache_A")
    }
  }
  
  private func addMustache(to node: SCNNode, style: String) {
    let mustacheNames: [String]
    
    // Use switch statement on mustache style for simplicity and in case more mustaches are added
    switch style {
    case "Mustache_A":
      mustacheNames = ["Moustache_A_Left", "Moustache_A_Right"]
    case "Mustache_B":
      mustacheNames = ["Moustache_B_Left", "Moustache_B_Right"]
    case "Mustache_C":
      mustacheNames = ["Moustache_C_Left", "Moustache_C_Right"]
    case "Mustache_D":
      mustacheNames = ["Moustache_D_Left", "Moustache_D_Right"]
    default:
      mustacheNames = []
      print("No valid mustache style selected. Provided style: \(style)")
    }
    
    for name in mustacheNames {
      if let mustacheNode = createMustacheNode(named: name) {
        // Each node is only 1/2 of mustache
        mustacheNode.position = SCNVector3(x: (name.contains("Left") ? -1 : 1) * 0.0215, y: -0.0275, z: 0.07)
        mustacheNode.scale = SCNVector3(x: 0.05, y: 0.2, z: 0.2)
        mustacheNode.name = "Mustache"
        node.addChildNode(mustacheNode)
      }
    }
  }
  
  // Responsible for loading mustache from .scn file
  private func createMustacheNode(named nodeName: String) -> SCNNode? {
    guard let mustacheScene = SCNScene(named: "mustache.scn"),
          let mustacheNode = mustacheScene.rootNode.childNode(withName: nodeName, recursively: true) else {
      NSLog("Failed to load the node: \(nodeName) from mustache.scn")
      return nil
    }
    return mustacheNode
  }
  
  //MARK: - Select mustache methods
  
  @objc private func handleMustacheChange(_ sender: UISegmentedControl) {
    let selectedIndex = sender.selectedSegmentIndex
    let mustacheStyle = sender.titleForSegment(at: selectedIndex) ?? "Mustache_A"
    
    updateMustache(style: mustacheStyle)
  }
  
  private func updateMustache(style: String) {
    guard let faceNode = currentFaceNode else { return }
    
    // Remove existing mustache nodes
    faceNode.enumerateChildNodes { (node, stop) in
      if node.name?.contains("Mustache") ?? false {
        node.removeFromParentNode()
      }
    }
    
    addMustache(to: faceNode, style: style)
  }
  
  //MARK: - Video recording methods
  
  @objc private func startRecording() {
    // Start recording AR session
  }
  
  @objc private func stopRecording() {
    // Stop recording AR session
  }
}
