//
//  ViewController.swift
//  MustacheMaker
//
//  Created by Christopher Endress on 5/9/24.
//

import AVFoundation
import UIKit

class CameraVC: UIViewController {
  // UI variables
  private var cameraPreviewView: UIView!
  private var startRecordingButton: UIButton!
  private var stopRecordingButton: UIButton!
  
  private let padding: CGFloat = 20
  
  // Camera session variables
  private var captureSession: AVCaptureSession!
  private var videoOutput: AVCaptureVideoDataOutput!
  private var previewLayer: AVCaptureVideoPreviewLayer!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupCameraSession()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    previewLayer.frame = cameraPreviewView.bounds
  }
  
  override func viewDidAppear(_ animated: Bool) {
    showARView()
  }
  
  //MARK: - Setup UI method
  
  private func setupUI() {
    cameraPreviewView = UIView()
    
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
    
    view.addSubview(cameraPreviewView)
    view.addSubview(startRecordingButton)
    view.addSubview(stopRecordingButton)
    
    cameraPreviewView.translatesAutoresizingMaskIntoConstraints = false
    startRecordingButton.translatesAutoresizingMaskIntoConstraints = false
    stopRecordingButton.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      cameraPreviewView.topAnchor.constraint(equalTo: view.topAnchor),
      cameraPreviewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      cameraPreviewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      cameraPreviewView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      startRecordingButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
      startRecordingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
      startRecordingButton.heightAnchor.constraint(equalToConstant: 50),
      startRecordingButton.bottomAnchor.constraint(equalTo: stopRecordingButton.topAnchor, constant: -20),
      
      stopRecordingButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
      stopRecordingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
      stopRecordingButton.heightAnchor.constraint(equalToConstant: 50),
      stopRecordingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60)
    ])
    
    // Gesture recognizer for double-tap
    let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
    doubleTapGesture.numberOfTapsRequired = 2
    cameraPreviewView.isUserInteractionEnabled = true
    cameraPreviewView.addGestureRecognizer(doubleTapGesture)
  }
  
  //MARK: - Video & AR methods
  
  @objc private func startRecording() {
    
  }
  
  @objc private func stopRecording() {
    
  }
  
  private func showARView() {
    let arVC = ARVC()
    self.present(arVC, animated: true, completion: nil)
  }
  
  
  //MARK: - Camera methods
  
  private func setupCameraSession() {
    captureSession = AVCaptureSession()
    captureSession.beginConfiguration()
    
    // Setup camera inputs:
    
    let initialCameraDevice = getCameraDevice(.front)
    // Exit if the device's camera can't initialize video input from the camera
    guard let videoInput = try? AVCaptureDeviceInput(device: initialCameraDevice) else { return }
    
    // If capture session can add the video input, add it
    if captureSession.canAddInput(videoInput) {
      captureSession.addInput(videoInput)
    } else {
      fatalError("Cannot add video input.")
    }
    
    // Setup camera outputs:
    
    videoOutput = AVCaptureVideoDataOutput()
    
    // If capture session can add the video output, add it
    if captureSession.canAddOutput(videoOutput) {
      captureSession.addOutput(videoOutput)
    } else {
      fatalError("Cannot add video output.")
    }
    
    // Setup preview layer:
    
    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    previewLayer.videoGravity = .resizeAspectFill
    cameraPreviewView.layer.addSublayer(previewLayer)
    
    captureSession.commitConfiguration()
    captureSession.startRunning()
  }
  
  @objc private func flipCamera() {
    guard let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput else {
      return
    }
    
    captureSession.beginConfiguration()
    captureSession.removeInput(currentInput)
    
    // Switches between front and back cameras when button is pressed
    let newCameraDevice = currentInput.device.position == .back ? getCameraDevice(.front) : getCameraDevice(.back)
    guard let newVideoInput = try? AVCaptureDeviceInput(device: newCameraDevice) else {
      captureSession.commitConfiguration()
      return
    }
    
    if captureSession.canAddInput(newVideoInput) {
      captureSession.addInput(newVideoInput)
    } else {
      captureSession.addInput(currentInput)
    }
    
    captureSession.commitConfiguration()
  }
  
  private func getCameraDevice(_ position: AVCaptureDevice.Position) -> AVCaptureDevice {
    return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) ?? AVCaptureDevice.default(for: .video)!
  }
  
  @objc private func handleDoubleTap() {
    flipCamera()
  }
}
