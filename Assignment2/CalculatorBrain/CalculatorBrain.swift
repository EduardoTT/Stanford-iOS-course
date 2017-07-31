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
    
    var variableValues: Dictionary<String, Double> = [:]
    
    //MARK: private variables
    
    private var accumulator:Accumulator = .operand(0.0)
    private var internalProgram = [Any]()
    
    private var allButLastItems = " "
    private var lastItem = ""
    
    private enum Accumulator {
        case operand(Double)
        case variable(String)
        
        var name:String {
            switch self {
            case .operand(let operand):
                return toString(operand)
            case .variable(let name):
                return name
            }
        }
        
        private func toString(_ value:Double)->String {
            switch value {
            case M_E:
                return "e"
            case Double.pi:
                return "π"
            default:
                return String(value)
            }
        }
    }
    
    private var accumulatorValue: Double {
        switch accumulator {
        case .operand(let operand):
            return operand
        case .variable(let name):
            return variableValues[name] ?? 0
        }
    }

    private var operations:[String:Operation] = [
        "π"  :  Operation.Constant(Double.pi),
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
                lastItem = accumulator.name
            }
            accumulator = .operand(pending.binaryFunction(pending.firstOperand,accumulatorValue))
            self.pending = nil
            binaryCanIgnoreDescription = false
        }
    }
    
    private func clear() {
        allButLastItems = ""
        lastItem = ""
        accumulator = .operand(0.0)
        pending = nil
        internalProgram.removeAll()
    }
    
    //MARK: public functions
    
    func setOperand(operand:Double) {
        accumulator = .operand(operand)
        internalProgram.append(operand as Any)
        if !isPartialResult {
            allButLastItems = accumulator.name
            lastItem = ""
        }
    }
    
    func setOperand(variableName: String) {
        let operand = variableValues[variableName] ?? 0
        accumulator = .variable(variableName)
        internalProgram.append([variableName:operand] as Any)
        if !isPartialResult {
            allButLastItems = variableName
            lastItem = ""
        }
    }
    
    func performOperation(symbol: String) {
        internalProgram.append(symbol as AnyObject)
        if let operation = operations[symbol] {
            switch(operation) {
            case .Constant (let value):
                setOperand(operand: value)
            case .UnaryOperation(let function):
                if isPartialResult {
                    guard let pending = pending else { return }
                    allButLastItems += lastItem
                    lastItem = pending.symbol + symbol + "(" + accumulator.name + ")"
                    binaryCanIgnoreDescription = true
                } else {
                    allButLastItems = symbol + "(" + allButLastItems
                    lastItem += ")"
                }
                accumulator = .operand(function(accumulatorValue))
            case .BinaryOperation(let function):
                lastBinaryOperationSymbol = symbol
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, symbol:symbol, firstOperand: accumulatorValue)
            case .Equal:
                executePendingBinaryOperation()
            }
        }
    }
    
    typealias PropertyList = Any
    var program: PropertyList {
        get {
            return internalProgram as CalculatorBrain.PropertyList
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [Any] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand: operand)
                    } else if let operation = op as? String {
                        performOperation(symbol: operation)
                    } else if let dictionary = op as? Dictionary<String,Double>, let variableName = dictionary.first?.key {
                        setOperand(variableName: variableName)
                    }
                }
            }
        }
    }
    
    var result: Double {
        get {
            return accumulatorValue
        }
    }
    
    func clearMemory() {
        variableValues = [:]
        clear()
    }
}
