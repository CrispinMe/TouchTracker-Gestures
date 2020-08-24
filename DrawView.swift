//
//  DrawView.swift
//  TouchTracker
//
//  Created by Crispin Lloyd on 01/01/2020.
//  Copyright © 2020 Big Nerd Ranch. All rights reserved.
//

import UIKit

class DrawView: UIView, UIGestureRecognizerDelegate {
    
    var currentLines = [NSValue:Line]()
    var finishedLines = [Line]()
    var selectedLineIndex: Int? {
        didSet {
            if selectedLineIndex == nil {
                let menu = UIMenuController.shared
                menu.hideMenu(from: self)
            }
        }
    }
    
    var moveRecognizer: UIPanGestureRecognizer!
    
    
    //Boolean variable to record whether line selection was conducted by long press
    var selectedLineIndexLongPress: Bool = false
    
    //Integer variable to record time taken to draw a line
    var lineDrawTime: Int = 0
    
    
    @IBInspectable var finishedLineColor: UIColor = UIColor.black {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var currentLineColor: UIColor = UIColor.red {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var lineWidth: CGFloat = 10 {
        didSet {
            setNeedsLayout()
        }
    }
    
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(DrawView.doubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.delaysTouchesBegan = true
        addGestureRecognizer(doubleTapRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(DrawView.tap(_:)))
        tapRecognizer.delaysTouchesBegan = true
        tapRecognizer.require(toFail: doubleTapRecognizer)
        addGestureRecognizer(tapRecognizer)
        
        //let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(DrawView.longPress(_:)))
        //addGestureRecognizer(longPressRecognizer)
        
        moveRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DrawView.moveLine(_:)))
        moveRecognizer.delegate = self
        moveRecognizer.cancelsTouchesInView = false
        addGestureRecognizer(moveRecognizer)
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    func stroke(_ line: Line){
        let path = UIBezierPath()
        path.lineWidth = CGFloat(integerLiteral: line.width)
        path.lineCapStyle = .round
        
        path.move(to: line.begin)
        path.addLine(to: line.end)
        path.stroke()
    }
    
    override func draw(_ rect: CGRect){
        for line in finishedLines {
            line.lineColor.setStroke()
            
            stroke(line)
            
        }
        
        currentLineColor.setStroke()
        for (_, line) in currentLines {
            stroke(line)
        }
        
        if let index = selectedLineIndex {
            UIColor.green.setStroke()
            let selectedLine = finishedLines[index]
            stroke(selectedLine)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        //Log statement to see the order of events
        print(#function)
        
        //Reset lineDrawTime
        if lineDrawTime != 0 {
            lineDrawTime = 0
        }

        
        
        for touch in touches {
            let location = touch.location(in: self)
            
            let newLine = Line(begin: location, end: location)
            
            let key = NSValue(nonretainedObject: touch)
            currentLines[key] = newLine
        
        
        setNeedsDisplay()
            
            }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?){
        //Log statement to see the order of events
        print(#function)
        
        
        for touch in touches {
            let key = NSValue(nonretainedObject: touch)
            currentLines[key]?.end = touch.location(in: self)
            
            }
        
        setNeedsDisplay()
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?){
        //Log statement to see the order of events
        print(#function)
        
        
        for touch in touches {
            let key = NSValue(nonretainedObject: touch)
            if var line = currentLines[key] {
                line.end = touch.location(in: self)
                
                print ("begin.y:", line.begin.y)
                print ("end.y:", line.end.y)
                
                //Caculate integer value for the current length of the line
                    var lineLength: Int
                    lineLength = Int(hypotf(Float(line.begin.x - line.end.x), Float(line.begin.y - line.end.y)))
                    
                    //Calculate the velocity of the pan drawing the line
                    var panVelocity: Int
                    panVelocity = lineLength / lineDrawTime
                    
                    //Assign the panVelocity value to the velocity property for the line
                    line.velocity = panVelocity
                    
                    //Print panVelocity value to console
                    print("The pan velocity for the line is: \(panVelocity)")
                
                    //Set the colour of the line based on the velocity for the line
                    switch line.velocity {
                        
                    case (10...25):
                        line.width = 30
                        line.lineColor = .green
                    case (26...50):
                        line.width = 20
                        line.lineColor = .blue
                    case (51...100):
                        line.width = 10
                        line.lineColor = .magenta
                    case (101...):
                        line.width = 5
                        line.lineColor = .red
                    default:
                        line.width = 10
                        line.lineColor = .black
                        }

                

                
                finishedLines.append(line)
                currentLines.removeValue(forKey: key)
                }
            }
        
            setNeedsDisplay()
       
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Log statement to see the order of events
        print(#function)
        
        currentLines.removeAll()
        
        setNeedsDisplay()
    }
    
    @objc func doubleTap(_ gestureRecognizer: UIGestureRecognizer) {
        print("Recognized a double tap")
        
        selectedLineIndex = nil
        currentLines.removeAll()
        finishedLines.removeAll()
        setNeedsDisplay()
    }
    
    @objc func tap(_ gestureRecognizer: UIGestureRecognizer) {
        print("Recognized a tap")
        
        let point = gestureRecognizer.location(in: self)
        selectedLineIndex = indexOfLine(at: point)
        
        //Grab the menu controller
        let menu = UIMenuController.shared
        
        if selectedLineIndex != nil {
            
            //Make DrawView the target of menu item action messages
            becomeFirstResponder()
            
            //Create a new "Delete" UIMenuItem
            let deleteItem = UIMenuItem(title: "Delete", action: #selector(DrawView.deleteLine(_:)))
            menu.menuItems = [deleteItem]
            
            //Tell the menu where it should come from and show it
            let targetRect = CGRect(x: point.x, y: point.y, width: 2, height: 2)
            menu.showMenu(from: self, rect: targetRect)
            
        } else {
            
            //Hide the menu if no line is selected
            menu.hideMenu(from: self)
        }
        
        setNeedsDisplay()
    }
    
    @objc func longPress(_ gestureRecognizer: UIGestureRecognizer) {
        print("Recognized a long press")
        
        //if gestureRecognizer.state == .began {
            //let point = gestureRecognizer.location(in: self)
            //selectedLineIndex = indexOfLine(at: point)
            
            //if selectedLineIndex != nil {
                //currentLines.removeAll()
                
                //Record line selection was conducted by long press
                //selectedLineIndexLongPress = true
                
            //}
        //} else if gestureRecognizer.state == .ended {
            //selectedLineIndex = nil
            
            //Reset selectedLineIndex to false
            //selectedLineIndexLongPress = false

        //}
        
        //setNeedsDisplay()
    }
    
    @objc func moveLine(_ gestureRecognizer: UIPanGestureRecognizer) {
        print("Recognized a pan")
        
    
    //If a line is selected...
    if let index = selectedLineIndex {
        
        if selectedLineIndexLongPress {
        
        //When the pan recognizer changes its position...
        if gestureRecognizer.state == .changed {
            //How far has the pan moved?
            let translation = gestureRecognizer.translation(in: self)
            
            //Add the translation to the current beginning and end points of the line
            //Make sure there are no copy and paste typos!
            finishedLines[index].begin.x += translation.x
            finishedLines[index].begin.y += translation.y
            finishedLines[index].end.x += translation.x
            finishedLines[index].end.y += translation.y
            
            gestureRecognizer.setTranslation(CGPoint.zero, in: self)
            
            //Redraw the screen
            setNeedsDisplay()
            }
        
            
            } else {
            //If no line is selected, do not do anything
            return
            }
        
        
        }
        
       
        //Create UITouch variable to refer to the touch object for the PanGestureRecognizer
        
         //Print velocity of the pan to the console
        lineDrawTime += 1
        print("Line draw time =  \(lineDrawTime)" )
        
        


        
        
    }
    
    func indexOfLine(at point: CGPoint)->Int? {
        //Find a line close to point
        for (index, line) in finishedLines.enumerated() {
            let begin = line.begin
            let end = line.end
                 
            //Check a few points on the line
                for t in stride(from: CGFloat(0), to: 1.0, by: 0.05) {
                    let x = begin.x + ((end.x - begin.x) * t)
                let y = begin.y + ((end.y - begin.y) * t)
                
                //If the tapped point is within 20 points, let's return this line
                if hypot(x - point.x, y - point.y) < 20.0 {
                    return index
                }
            }
        }
        
        //If nothing is close enough to the tapped point, then we did not select a line
        return nil
    }
    
     @objc func deleteLine(_ sender: UIMenuController) {
        //Remove the selected line from the list of finished lines
        if let index = selectedLineIndex {
            finishedLines.remove(at: index)
            selectedLineIndex = nil
            
            //Redraw everything
            setNeedsDisplay()
        }
    }
    
}
