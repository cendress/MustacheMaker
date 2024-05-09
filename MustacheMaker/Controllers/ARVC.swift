//
//  ARVC.swift
//  MustacheMaker
//
//  Created by Christopher Endress on 5/9/24.
//

import ARKit
import UIKit

class ARVC: UIViewController, ARSCNViewDelegate {
  private var arSCNView: ARSCNView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupARView()
  }
  
  //MARK: - Setup UI method
  
  private func setupARView() {
    // ARSCN view is used to perform AR related tasks
    arSCNView = ARSCNView()
    arSCNView.frame = self.view.bounds
    arSCNView.delegate = self
    self.view.addSubview(arSCNView)
    
    arSCNView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      arSCNView.topAnchor.constraint(equalTo: view.topAnchor),
      arSCNView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      arSCNView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      arSCNView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
    
    // Define the AR configuration as face tracking
    let configuration = ARFaceTrackingConfiguration()
    // Run the session while resetting face tracking and any existing anchors
    arSCNView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
  }
  
  //MARK: - ARSCN view delegate method
  
  // Called when AR anchor is being set
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    guard let faceAnchor = anchor as? ARFaceAnchor else { return }
    
    // Execute the following block on the main thread because it involves updating the UI
    DispatchQueue.main.async {
      // Check if a "mustache" node does not already exist to avoid duplicates
      if self.arSCNView.scene.rootNode.childNode(withName: "mustache", recursively: false) == nil {
        let mustacheNode = self.createMustacheNode()
        node.addChildNode(mustacheNode)
      }
    }
  }
  
  //MARK: - Setup mustache
  
  private func createMustacheNode() -> SCNNode {
    let mustacheScene = SCNScene(named: "mustache.scnassets/mustache.scn")!
    let mustacheNode = mustacheScene.rootNode.childNodes.first!
    mustacheNode.name = "mustache"
    
    // May need adjusting
    mustacheNode.position = SCNVector3(x: 0, y: 0.011, z: 0.07)
    mustacheNode.scale = SCNVector3(0.002, 0.002, 0.002)
    
    return mustacheNode
  }
}
