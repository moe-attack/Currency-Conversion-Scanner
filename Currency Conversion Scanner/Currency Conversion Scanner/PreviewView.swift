//
//  PreviewView.swift
//  Currency Conversion Scanner
//
//  Created by Jimmy Low on 7/6/20.
//  Copyright © 2020 Jimmy Low. All rights reserved.
//

import UIKit
import AVFoundation

class PreviewView: UIView {
    // This view is acting as the layer to contain the video capturing.
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("Expected `AVCaptureVideoPreviewLayer` type for layer. Check PreviewView.layerClass implementation.")
        }
        
        return layer
    }
    
    // getter and setter for the session
    var session: AVCaptureSession? {
        get {
            return videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.session = newValue
        }
    }
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}
