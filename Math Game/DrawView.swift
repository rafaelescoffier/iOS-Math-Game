//
//  DrawView.swift
//  Math Game
//
//  Created by Rafael d'Escoffier on 10/11/17.
//  Copyright © 2017 Rafael d'Escoffier. All rights reserved.
//

import UIKit

protocol DrawViewDelegate: class {
    func lineDrawed(lines: [Line])
    func clear()
}

class DrawView: UIView {
    
    var linewidth = CGFloat(15)
    var color = UIColor.white
    var lines: [Line] = []
    var lastPoint: CGPoint!
    
    weak var delegate: DrawViewDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastPoint = touches.first!.location(in: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let newPoint = touches.first!.location(in: self)
        // keep all lines drawn by user as touch in record so we can draw them in view
        lines.append(Line(start: lastPoint, end: newPoint))
        lastPoint = newPoint
        // make a draw call
        setNeedsDisplay()
        
        delegate?.lineDrawed(lines: lines)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lines = []
        setNeedsDisplay()
        
        delegate?.clear()
    }
    
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
}


class Line {
    var start, end: CGPoint
    
    init(start: CGPoint, end: CGPoint) {
        self.start = start
        self.end   = end
    }
    
    func transforming(translation: CGFloat, scale: CGFloat) -> Line {
        let transform = CGAffineTransform(translationX: translation, y: 0).concatenating(CGAffineTransform(scaleX: scale, y: scale))
        
        return Line(start: start.applying(transform), end: end.applying(transform))
    }
}

