//
//  ViewController.swift
//  calculator-Stanford
//
//  Created by Eduardo Tolmasquim on 26/01/17.
//  Copyright © 2017 Nighter. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {

    @IBAction func Clear() {
        brain.clear()
        displayValue = 0
    }
    
    @IBOutlet private weak var display: UILabel!
    
    private var isUserInTheMiddleOfTyping = false
    
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    @IBOutlet private weak var historyDisplay: UILabel!
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if digit == "." && digit.range(of: ".") != nil{ return }
        if isUserInTheMiddleOfTyping && displayValue != 0 {
            display.text = display.text! + digit
        } else {
            display.text = digit
        }
        
        isUserInTheMiddleOfTyping = true
    }
    
    var brain = CalculatorBrain()
    
    @IBAction private func performOperation(_ sender: UIButton) {
        if isUserInTheMiddleOfTyping {
            brain.setOperand(operand: displayValue)
            isUserInTheMiddleOfTyping = false
        }
        guard let mathematicalSymbol = sender.currentTitle else { return }
        brain.performOperation(symbol: mathematicalSymbol)
        displayValue = brain.result
        historyDisplay.text = brain.description
        if brain.isPartialResult {
            historyDisplay.text! +=  brain.lastBinaryOperationSymbol + "..."
        } else {
            historyDisplay.text! += "="
        }
    }
}

