//
//  CaptureView.swift
//  Math Game
//
//  Created by Rafael d'Escoffier on 10/11/17.
//  Copyright © 2017 Rafael d'Escoffier. All rights reserved.
//

import UIKit

class CaptureView: UIView {
    var linewidth = CGFloat(15) { didSet { setNeedsDisplay() } }
    var color = UIColor.white { didSet { setNeedsDisplay() } }
    
    fileprivate var lines: [Line] = []
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let drawPath = UIBezierPath()
        drawPath.lineCapStyle = .round
        
        for line in lines{
            drawPath.move(to: line.start)
            drawPath.addLine(to: line.end)
        }
        
        drawPath.lineWidth = linewidth
        color.set()
        drawPath.stroke()
    }
    
    func setLines(lines: [Line]) {
        self.lines = lines

        setNeedsDisplay()
    }
    
    func getPixelBuffer() -> CVPixelBuffer? {
        // our network takes in only grayscale images as input
        let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceGray()
        
        // we have 3 channels no alpha value put in the network
        let bitmapInfo = CGImageAlphaInfo.none.rawValue
        
        // this is where our view pixel data will go in once we make the render call
        guard let context = CGContext(data: nil, width: 28, height: 28, bitsPerComponent: 8, bytesPerRow: 28, space: colorSpace, bitmapInfo: bitmapInfo) else {
            return nil
        }
        
        // scale and translate so we have the full digit and in MNIST standard size 28x28
        context.translateBy(x: 0 , y: 28)
        context.scaleBy(x: 28/self.frame.size.width, y: -28/self.frame.size.height)
        
        // put view pixel data in context
        self.layer.render(in: context)
        
        guard let inputImage = context.makeImage() else {
            return nil
        }
        
        let pixelBuffer = UIImage(cgImage: inputImage).pixelBuffer()
        
        return pixelBuffer
    }
}

extension UIImage {
    func pixelBuffer() -> CVPixelBuffer? {
        let width = self.size.width
        let height = self.size.height
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(width),
                                         Int(height),
                                         kCVPixelFormatType_OneComponent8,
                                         attrs,
                                         &pixelBuffer)
        
        guard let resultPixelBuffer = pixelBuffer, status == kCVReturnSuccess else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(resultPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(resultPixelBuffer)
        
        let grayColorSpace = CGColorSpaceCreateDeviceGray()
        guard let context = CGContext(data: pixelData,
                                      width: Int(width),
                                      height: Int(height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(resultPixelBuffer),
                                      space: grayColorSpace,
                                      bitmapInfo: CGImageAlphaInfo.none.rawValue) else {
                                        return nil
        }
        
        context.translateBy(x: 0, y: height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context)
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(resultPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return resultPixelBuffer
    }
}
