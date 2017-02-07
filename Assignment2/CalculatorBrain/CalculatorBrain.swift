//
//  CalculatorBrain.swift
//  CalculatorBrain
//
//  Created by Eduardo Tolmasquim on 07/02/17.
//  Copyright © 2017 Eduardo. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    //MARK: public variabless
    
    var description:String {
        get {
            return allButLastItems + lastItem
        }
    }
    
    var isPartialResult:Bool {
        get {
            return pending != nil
        }
    }
    
    var lastBinaryOperationSymbol = ""
    
    func setOperand(operand:Double) {
        self.accumulator = operand
        if !isPartialResult {
            allButLastItems = toString(operand)
            lastItem = ""
        }
    }
    
    //MARK: private variables
    
    private var accumulator = 0.0
    private var allButLastItems = " "
    private var lastItem = ""
    
    private var operations:[String:Operation] = [
        "π"  :  Operation.Constant(M_PI),
        "e"  :  Operation.Constant(M_E),
        "√"  :  Operation.UnaryOperation(sqrt),
        "cos":  Operation.UnaryOperation(cos),
        "sin":  Operation.UnaryOperation(sin),
        "tan":  Operation.UnaryOperation(tan),
        "1/x":  Operation.UnaryOperation({ 1/$0 }),
        "xˆ2":  Operation.UnaryOperation({ $0*$0 }),
        "±"  :  Operation.UnaryOperation({ -$0 }),
        "x^y":  Operation.BinaryOperation({ pow($0,$1) }),
        "×"  :  Operation.BinaryOperation({$0 * $1}),
        "+"  :  Operation.BinaryOperation({$0 + $1}),
        "−"  :  Operation.BinaryOperation({$0 - $1}),
        "÷"  :  Operation.BinaryOperation({$0 / $1}),
        "="  :  Operation.Equal
    ]
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double)->Double)
        case BinaryOperation((Double,Double)->Double)
        case Equal
    }
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double,Double)->Double
        var symbol: String
        var firstOperand: Double
    }
    
    private var pending:PendingBinaryOperationInfo?
    private var binaryCanIgnoreDescription = false
    
    //MARK: private functions
    
    private func executePendingBinaryOperation() {
        if let pending = pending {
            if !binaryCanIgnoreDescription {
                allButLastItems += lastItem
                allButLastItems += pending.symbol
                lastItem = toString(accumulator)
            }
            accumulator = pending.binaryFunction(pending.firstOperand,accumulator)
            self.pending = nil
            binaryCanIgnoreDescription = false
        }
    }
    
    private func toString(_ value:Double)->String {
        switch value {
        case M_E:
            return "e"
        case M_PI:
            return "π"
        default:
            return String(value)
        }
    }
    
    //MARK: public functions
    
    func performOperation(symbol: String) {
        if let operation = operations[symbol] {
            switch(operation) {
            case .Constant (let value):
                setOperand(operand: value)
            case .UnaryOperation(let function):
                if isPartialResult {
                    guard let pending = pending else { return }
                    allButLastItems += lastItem
                    lastItem = pending.symbol + symbol + "(" + toString(accumulator) + ")"
                    binaryCanIgnoreDescription = true
                } else {
                    allButLastItems = symbol + "(" + allButLastItems
                    lastItem += ")"
                }
                accumulator = function(accumulator)
            case .BinaryOperation(let function):
                lastBinaryOperationSymbol = symbol
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, symbol:symbol, firstOperand: accumulator)
            case .Equal:
                executePendingBinaryOperation()
            }
        }
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
    
    func clear() {
        allButLastItems = ""
        lastItem = ""
        accumulator = 0.0
        pending = nil
    }
}
