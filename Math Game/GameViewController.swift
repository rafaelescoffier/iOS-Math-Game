//
//  GameViewController.swift
//  Math Game
//
//  Created by Rafael d'Escoffier on 10/11/17.
//  Copyright © 2017 Rafael d'Escoffier. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    @IBOutlet weak var drawView: DrawView!
    @IBOutlet weak var captureView: CaptureView!
    @IBOutlet weak var equationLabel: UILabel!

    var gameSession = GameSession(
        equations: [
            Equation(equation: "2 + 2", result: "4"),
            Equation(equation: "2 + 5", result: "7"),
            Equation(equation: "1 + 1", result: "2"),
            Equation(equation: "3 + 3", result: "6"),
            Equation(equation: "4 + 3", result: "7"),
            Equation(equation: "3 + 2", result: "5"),
            Equation(equation: "8 + 1", result: "9"),
            Equation(equation: "1 + 3", result: "4"),
            Equation(equation: "7 - 3", result: "4"),
            Equation(equation: "8 - 5", result: "3"),
            Equation(equation: "3 - 2", result: "1"),
            Equation(equation: "7 - 2", result: "5"),
            Equation(equation: "3 - 3", result: "0"),
            Equation(equation: "6 - 0", result: "6"),
            Equation(equation: "9 - 6", result: "3"),
            ],
        current: -1)
    
    
    let model = mnistCNN()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        drawView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        nextEquation()
    }
    
    fileprivate func nextEquation() {
        let nextGameSession = gameSession.advance()
        
        guard !nextGameSession.gameOver else {
            equationLabel.alpha = 1.0
            equationLabel.text = "GAME OVER"
            return
        }
        
        equationLabel.text = nextGameSession.currentEquation.equation
        
        UIView.animate(withDuration: 0.15,
                       animations: { self.equationLabel.alpha = 1.0 },
                       completion: { _ in
                        print("Expected answer - \(nextGameSession.currentEquation.result)")
                        self.gameSession = nextGameSession
        })
    }
    
    fileprivate func predictResult(pixelBuffer: CVPixelBuffer) {
        do {
            let prediction = try model.prediction(image: pixelBuffer)
            let confidence = prediction.output[prediction.classLabel] ?? 0.0
            
            print("prediction: \(prediction.classLabel) - confidence: \(confidence)")
            
            if confidence > 0.70 {
                if gameSession.currentEquation.result == prediction.classLabel {
                    UIView.animate(withDuration: 0.15,
                                   animations: { self.equationLabel.alpha = 0.0 },
                                   completion: { _ in self.nextEquation() })
                }
            }
        } catch let error {
            print("Prediction failed with error: \(error)")
        }
    }
}

extension GameViewController: DrawViewDelegate {
    func lineDrawed(lines: [Line]) {
        let scaledLines = lines.map { $0.transforming(translation:captureView.frame.origin.x, scale: 0.3) }
        
        captureView.setLines(lines: scaledLines)
    }
    
    func clear() {
        guard let pixelBuffer = captureView.getPixelBuffer() else { return }
        
        predictResult(pixelBuffer: pixelBuffer)
        
        captureView.setLines(lines: [])
    }
}

struct Equation {
    let equation: String
    let result: String
}

struct GameSession {
    var equations: [Equation]
    var current: Int
    
    var gameOver: Bool { return current >= equations.count }
    var currentEquation: Equation { return equations[current] }
    
    func advance() -> GameSession {
        return GameSession(equations: equations, current: current + 1)
    }
}
