//
//  ViewController.swift
//  MustacheMaker
//
//  Created by Christopher Endress on 5/9/24.
//

import ARKit
import UIKit

class CameraVC: UIViewController, ARSCNViewDelegate {
  // UI variables
  private var arSCNView: ARSCNView!
  private var startRecordingButton: UIButton!
  private var stopRecordingButton: UIButton!
  
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
    view.addSubview(arSCNView)
    
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
    
    view.addSubview(startRecordingButton)
    view.addSubview(stopRecordingButton)
    
    arSCNView.translatesAutoresizingMaskIntoConstraints = false
    startRecordingButton.translatesAutoresizingMaskIntoConstraints = false
    stopRecordingButton.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      arSCNView.topAnchor.constraint(equalTo: view.topAnchor),
      arSCNView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      arSCNView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      arSCNView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      startRecordingButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
      startRecordingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
      startRecordingButton.heightAnchor.constraint(equalToConstant: 50),
      startRecordingButton.bottomAnchor.constraint(equalTo: stopRecordingButton.topAnchor, constant: -20),
      
      stopRecordingButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
      stopRecordingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
      stopRecordingButton.heightAnchor.constraint(equalToConstant: 50),
      stopRecordingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60)
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
  
  @objc private func startRecording() {
    // Start recording AR session
  }
  
  @objc private func stopRecording() {
    // Stop recording AR session
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    guard anchor is ARFaceAnchor else { return }
    
    DispatchQueue.main.async {
      self.addMustache(to: node)  
    }
  }
  
  func addMustache(to node: SCNNode) {
    let mustacheNames = ["Moustache_D_Left", "Moustache_D_Right"]
    for name in mustacheNames {
      if let mustacheNode = createMustacheNode(named: name) {
        mustacheNode.position = SCNVector3(x: (name.contains("Left") ? -1 : 1) * 0.0275, y: -0.0275, z: 0.07)
        node.addChildNode(mustacheNode)
      }
    }
  }
  
  private func createMustacheNode(named nodeName: String) -> SCNNode? {
    guard let mustacheScene = SCNScene(named: "mustache.scn"),
          let mustacheNode = mustacheScene.rootNode.childNode(withName: nodeName, recursively: true) else {
      print("Failed to load the node: \(nodeName)")
      return nil
    }
    return mustacheNode
  }
}
