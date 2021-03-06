//
//  ViewController.swift
//  CalculatorBrain
//
//  Created by Eduardo Tolmasquim on 07/02/17.
//  Copyright © 2017 Eduardo. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    @IBAction func Clear() {
        brain.clearMemory()
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
    
    private func updateDisplayAndHistory() {
        displayValue = brain.result
        historyDisplay.text = brain.description
        if brain.isPartialResult {
            historyDisplay.text! +=  brain.lastBinaryOperationSymbol + "..."
        } else {
            historyDisplay.text! += "="
        }
    }
    
    @IBAction private func performOperation(_ sender: UIButton) {
        if isUserInTheMiddleOfTyping {
            brain.setOperand(operand: displayValue)
            isUserInTheMiddleOfTyping = false
        }
        guard let mathematicalSymbol = sender.currentTitle else { return }
        brain.performOperation(symbol: mathematicalSymbol)
        updateDisplayAndHistory()
    }
    
    @IBAction func setMemory() {
        brain.variableValues["M"] = displayValue
        let storedProgram = brain.program
        brain.program = storedProgram
        updateDisplayAndHistory()
        isUserInTheMiddleOfTyping = false
    }
    
    @IBAction func getMemory() {
        brain.setOperand(variableName: "M")
    }
}


