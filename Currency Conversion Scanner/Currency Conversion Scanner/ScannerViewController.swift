//
//  ScannerViewController.swift
//  Currency Conversion Scanner
//
//  Created by Jimmy Low on 14/5/20.
//  Copyright © 2020 Jimmy Low. All rights reserved.
//
//  Key idea of the imlementation is to separate the concerns of Video camera capturing set
//  up responsibilities with the concerns of Vision framework set up responsibilities.
//  This allows cleaner code, less bulky controllers (Because Implementing includes Core
//  Graphic library as well, which can be heavy), and makes maintaining code quality easier.
//

import Foundation
import UIKit
import AVFoundation
import Vision

class ScannerViewController: UIViewController {
    
    @IBOutlet weak var previewView: PreviewView!
    @IBOutlet weak var noCamera: UIImageView!

    weak var locationManager: LocationManager?
    
    let constants = Constants.scanner.self
    let alertConstants = Constants.alert.self

    var maskLayer = CAShapeLayer()
    
    private let captureSession = AVCaptureSession()
    let captureSessionQueue = DispatchQueue(label: "JunHong.Currency-Conversion-Scanner.CaptureSessionQueue")
    
    var captureDevice: AVCaptureDevice?
    
    var videoDataOutput = AVCaptureVideoDataOutput()
    let videoDataOutputQueue = DispatchQueue(label: "JunHong.Currency-Conversion-Scanner.VideoDataOutputQueue")
    
    // region of video data output buffer that Vision runs on. Value gets recalculated once screen set up is done.
    var regionOfInterest = CGRect(x: 0, y: 0, width: 1, height: 1)
    // orientation of text to search for in the region of interest.
    var textOrientation = CGImagePropertyOrientation.right
    
    var bufferAspectRatio: Double!
    // Transform from UI orientation to buffer orientation.
    var uiRotationTransform = CGAffineTransform.identity
    // Transform bottom-left coordinates to top-left.
    var bottomToTopTransform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)
    // Transform coordinates in ROI to global coordinates (still normalized).
    var roiToGlobalTransform = CGAffineTransform.identity
    
    // Vision -> AVF coordinate transform.
    var visionToAVFTransform = CGAffineTransform.identity

    // get location
    var currentLocation = UserDefaults.standard.string(forKey: Constants.persistentKey.currentLocation) ?? ""
    var currency: CurrencyData?
    var defaultCurrency = UserDefaults.standard.string(forKey: Constants.persistentKey.defaultCurrency) ?? "AUD"
    let wsm = WebServiceManager()

    /*
     This function defines what happens when view is going to appear
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.title = constants.tabBarTitle
        
        // ensure the capture device is accessible whenever the view is about to appear
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        // if accessible, hide the no camera image
        case .authorized:
            noCamera.isHidden = true
        case .notDetermined:
            self.noCamera.isHidden = false
        case .denied:
            noCamera.isHidden = false
            return
        case .restricted:
            noCamera.isHidden = false
            return
        @unknown default:
            fatalError("Failure to determine capture device status")
        }
    }
    
    /*
     This function defines what happens when a view disappear
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // we dont need the capture session if view is not on top stack
        self.captureSession.stopRunning()
    }
    
    /*
     This function defines what happens when a view is loaded
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        locationManager = appDelegate.locationManager
        // set up preview view
        previewView.session = captureSession
        // using a mask layer to have limited area of interest
        maskLayer.backgroundColor = UIColor.clear.cgColor
        maskLayer.fillRule = .evenOdd
        
        // ensure the camera device is accessible before set up.
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            startSetUpCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.startSetUpCamera()
                } else {
                    return
                }
            }
        case .denied:
            return
        case .restricted:
            return
        @unknown default:
            fatalError("Failure to determine capture device status")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSessionQueue.async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }

    /*
     This function prepares to set up the camera using dedicated queue
     */
    func startSetUpCamera(){
        // starting the capture session is a blocking call. Perform setup using
        // a dedicated serial dispatch queue to prevent blocking the main thread.
        captureSessionQueue.async {
            self.setupCamera()
            
            DispatchQueue.main.async {
                // recalculate region of interest since camera is set up
                self.noCamera.isHidden = true
                self.calculateRegionOfInterest()
            }
        }
    }
    
    /*
     This function utilize the Core Graphic library to calculate the region of interest by scaling and transforming the affine transformation mattrix from the existing preview
     */
    func calculateRegionOfInterest() {
        let desiredHeightRatio = 0.3  //0.15
        let desiredWidthRatio = 0.6  //0.6
        let maxPortraitWidth = 0.8  //0.8

        // figure out size of ROI. important to have a max portait width to keep region of interest within normalized domain
        let size = CGSize(width: min(desiredWidthRatio * bufferAspectRatio, maxPortraitWidth), height: desiredHeightRatio / bufferAspectRatio)

        // make it centered.
        regionOfInterest.origin = CGPoint(x: (1 - size.width) / 2, y: (1 - size.height) / 2)
        regionOfInterest.size = size
        
        // ROI changed, update transform.
        // compensate for region of interest.
        let roi = regionOfInterest
        // using CGAffineTransform to scale the object in graphic context
        roiToGlobalTransform = CGAffineTransform(translationX: roi.origin.x, y: roi.origin.y).scaledBy(x: roi.width, y: roi.height)
        
        // compensate for orientation
        uiRotationTransform = CGAffineTransform(translationX: 0, y: 1).rotated(by: -CGFloat.pi / 2)
        
        // full Vision ROI to AVF transform, combining affine transforms.
        visionToAVFTransform = roiToGlobalTransform.concatenating(bottomToTopTransform).concatenating(uiRotationTransform)
    }
    
    /*
     This function sets up the configuration of the capturing device
     */
    func setupCamera() {
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) else {
            print("Could not create capture device.")
            return
        }
        self.captureDevice = captureDevice
        // limit the capture session to 1080p to reduce power consumptio
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        bufferAspectRatio = 1920.0 / 1080.0
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            print("Could not create device input.")
            return
        }
        if captureSession.canAddInput(deviceInput) {
            captureSession.addInput(deviceInput)
        }
        
        // configure video data output.
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
            // disable stabaliztion to allow drawing bounding box
            videoDataOutput.connection(with: AVMediaType.video)?.preferredVideoStabilizationMode = .off
        } else {
            print("Could not add VDO output")
            return
        }
        
        // set zoom and autofocus to help focus on very small text.
        do {
            try captureDevice.lockForConfiguration()
            captureDevice.videoZoomFactor = 2
            captureDevice.autoFocusRangeRestriction = .near
            captureDevice.unlockForConfiguration()
        } catch {
            print("Could not set zoom level due to error: \(error)")
            return
        }
        
        captureSession.startRunning()
    }
        
    /*
     This function shows the scanned result in a dedicated queue to avoid blocking main thread.
     */
    func showString(string: String) {
        // show the scanned result, to implement
        print("Got a value: \(string)\n")
        captureSessionQueue.sync {
            self.captureSession.stopRunning()
            DispatchQueue.main.async {
                self.displayAlert(value: string)
            }
        }
    }
    
    /*
     This function creates an alert and shows a string as of the message parameter.
     value: A string to be displayed as message body
     */
    func displayAlert(value: String) {
        var currentAbbre = ""
        var message = ""
        var title = ""
        // If the location is nil, try to fetch again
        if currentLocation == "" {
            if let exposeLocation = locationManager?.exposedLocation {
                locationManager?.getPlace(for: exposeLocation) { placeMark in
                    guard let placeMark = placeMark else {return}
                    UserDefaults.standard.set(placeMark.country, forKey: Constants.persistentKey.currentLocation)
                    self.currentLocation = placeMark.country!
                }
            }
        }
        
        if currentLocation != "" {
            for each in Constants.allCurrencies.ALL_CURRENCIES {
                if each.country.lowercased() == currentLocation.lowercased() {
                    currentAbbre = each.abbre
                }
            }
            let valueDouble: Double = Double(value.replacingOccurrences(of: "$", with: "")) ?? 1.0
            if currentAbbre != "" {
                fetchCurrency(abbre: currentAbbre)
                let rate = valueDouble / wsm.getRateFromCurrencyData(currency: self.currency, abbre: defaultCurrency)
                title = String(format: alertConstants.titleScannedResult, String(valueDouble) ,defaultCurrency, String(roundUpDouble(number: rate)), currentAbbre).uppercased()
                message = alertConstants.messageINF
            } else {
                title = alertConstants.titleUnableProcess
                message = alertConstants.messageNoCurrencyAbbre
            }
        } else {
            title = alertConstants.titleUnableProcess
            message = alertConstants.messageLocationDisabled
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: alertConstants.dismiss,
            style: UIAlertAction.Style.default,handler: alertCompleteHandler))
        alertController.view.tintColor = UIColor(named: "maroonPurple")
        self.present(alertController, animated: true, completion: nil)
    }
    
    /*
     This function rounds up the number to 3 decimal places
     */
    func roundUpDouble(number: Double) -> Double{
        return Double(round(1000*number)/1000)
    }
    
    /*
     This function resumes the capture session if it is not already running
     */
    func alertCompleteHandler(action: UIAlertAction){
        captureSessionQueue.async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }

    /*
     This function fetches the currency from the API and cache the data in local variable to reduce network traffic
     */
    func fetchCurrency(abbre: String){
        // fetch the currency rate from API
        let url = String(format: Constants.allCurrencies.QUERY_URL, abbre)
        let jsonURL = URL(string: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        let task = URLSession.shared.dataTask(with: jsonURL!) { (data, response, error) in
            if let error = error {
                print(error)
                return
            }
            do {
                // once fetched, decode the data and store in local variable
                let decoder = JSONDecoder()
                let currencyData = try decoder.decode(RawCurrencyData.self, from: data!)
                if let rates = currencyData.rates {
                    self.currency = rates
                }
            } catch let err {
                print(err)
            }
        }
        task.resume()
    }
}

// MARK: AVCaptureVideoDataOutputSampleBufferDelegate extension

extension ScannerViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // This is implemented in VisionViewController.
    }
}

