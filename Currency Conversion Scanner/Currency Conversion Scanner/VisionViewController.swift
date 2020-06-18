//
//  VisionViewController.swift
//  Currency Conversion Scanner
//
//  Created by Jimmy Low on 7/6/20.
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

class VisionViewController: ScannerViewController {
    var request: VNRecognizeTextRequest!
    let tracker = StringTracker()
    
    override func viewDidLoad() {
        // set up vision request before camera set up in ScannerViewController so it exists when first buffer is received
        request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        super.viewDidLoad()
    }
    
    override open var shouldAutorotate: Bool {
        return false
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    /*
     This function is the Vision recognition handler, to be called when completed a VNRecognizedTextRequest.
     */
    func recognizeTextHandler(request: VNRequest, error: Error?) {
        var numbers = [String]()
        var redBoxes = [CGRect]() // shows all recognized text lines
        var greenBoxes = [CGRect]() // shows words that matches the regex
        
        guard let results = request.results as? [VNRecognizedTextObservation] else { return }
        
        let maximumCandidates = 1
        
        // go through each vision observation result and identify them on screen
        for visionResult in results {
            guard let candidate = visionResult.topCandidates(maximumCandidates).first else { continue }
            
            var valueIsSubstring = true
            
            if let result = candidate.string.extractValue() {
                let (range, result) = result
                // value may not cover full visionResult, extract boundingbox of substring
                if let box = try? candidate.boundingBox(for: range)?.boundingBox {
                    numbers.append(result)
                    // draw greenbox around detected result
                    greenBoxes.append(box)
                    // check if value is substring
                    valueIsSubstring = !(range.lowerBound == candidate.string.startIndex && range.upperBound == candidate.string.endIndex)
                }
            }
            
            // if value is substring, draw redbox around the full string
            if valueIsSubstring {
                redBoxes.append(visionResult.boundingBox)
            }
        }
        
        tracker.logFrame(strings: numbers)  // log the frame
        show(boxGroups: [(color: UIColor.red.cgColor, boxes: redBoxes), (color: UIColor.green.cgColor, boxes: greenBoxes)])
        
        // check if there is any valid result
        if let sureNumber = tracker.getStableString() {
            showString(string: sureNumber)
            tracker.reset(string: sureNumber)
        }
    }
    
    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            // configuring vision requet
            // fast recgonition is more suitable for running in real time
            request.recognitionLevel = .fast
            // we are scanning for number so turn off language correction optimises speed
            request.usesLanguageCorrection = false
            // only run on the region of interest for maximum speed.
            request.regionOfInterest = regionOfInterest
            
            let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: textOrientation, options: [:])
            do {
                try requestHandler.perform([request])
            } catch {
                print(error)
            }
        }
    }
        
    // draw a box on screen, must be called from main queue.
    var boxLayer = [CAShapeLayer]()
    /*
     This function draws a box by inserting the box layer as sublayer in the preview view
     */
    func draw(rect: CGRect, color: CGColor) {
        let layer = CAShapeLayer()
        layer.opacity = 0.5
        layer.borderColor = color
        layer.borderWidth = 1
        layer.frame = rect
        boxLayer.append(layer)
        previewView.videoPreviewLayer.insertSublayer(layer, at: 1)
    }
    
    /*
     This function removes all the drawn boxes, must be called from the main queue.
     */
    func removeBoxes() {
        for layer in boxLayer {
            layer.removeFromSuperlayer()
        }
        boxLayer.removeAll()
    }
    
    typealias ColoredBoxGroup = (color: CGColor, boxes: [CGRect])
    
    /*
     This function is creating boxes been passed as parameter in the main queue by using draw() and removeBoxes() functions.
     */
    func show(boxGroups: [ColoredBoxGroup]) {
        DispatchQueue.main.async {
            let layer = self.previewView.videoPreviewLayer
            self.removeBoxes()
            for boxGroup in boxGroups {
                let color = boxGroup.color
                for box in boxGroup.boxes {
                    let rect = layer.layerRectConverted(fromMetadataOutputRect: box.applying(self.visionToAVFTransform))
                    self.draw(rect: rect, color: color)
                }
            }
        }
    }
}
