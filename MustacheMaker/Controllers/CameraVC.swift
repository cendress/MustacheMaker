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
      cameraPreviewView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150),
      
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
  
  //MARK: - Start and stop recording methods
  
  @objc private func startRecording() {
    
  }
  
  @objc private func stopRecording() {
    
  }
  
  //MARK: - Camera session method
  
  private func setupCameraSession() {
    captureSession = AVCaptureSession()
    captureSession.beginConfiguration()
    
    // Setup camera inputs:
    
    // Exit if the device's camera can't be accessed or can't initialize video input from the camera
    guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
    guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else { return }
    
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
    previewLayer.frame = cameraPreviewView.bounds
    previewLayer.videoGravity = .resizeAspectFill
    cameraPreviewView.layer.addSublayer(previewLayer)
    
    captureSession.commitConfiguration()
    captureSession.startRunning()
  }
}

