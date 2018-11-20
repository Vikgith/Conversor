//
//  Extensions.swift
//  Conversor
//
//  Created by Victor Alonso on 2018-11-19.
//  Copyright © 2018 Victor Alonso. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    /**Simply zooming out of a view: set view scale to Identity and zoom out to 0 on 'duration' time interval.
     - parameter duration: animation duration
     */
    func zoomOut(duration: TimeInterval = 0.2) {
        self.transform = CGAffineTransform.identity
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveLinear], animations: { () -> Void in
            self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        }) { (animationCompleted: Bool) -> Void in
        }
    }

    /**Zoom in any view with specified offset magnification.
     - parameter duration:     animation duration.
     - parameter easingOffset: easing offset.
     */
    func zoomInWithEasing(duration: TimeInterval = 0.2, easingOffset: CGFloat = 0.2) {
        let easeScale = 1.0 + easingOffset
        let easingDuration = TimeInterval(easingOffset) * duration / TimeInterval(easeScale)
        let scalingDuration = duration - easingDuration
        UIView.animate(withDuration: scalingDuration, delay: 0.0, options: .curveEaseIn, animations: { () -> Void in
            self.transform = CGAffineTransform(scaleX: easeScale, y: easeScale)
        }, completion: { (completed: Bool) -> Void in
            UIView.animate(withDuration: easingDuration, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
                self.transform = CGAffineTransform.identity
            }, completion: { (completed: Bool) -> Void in
            })
        })
    }

    /**Zoom out any view with specified offset magnification.
     - parameter duration:     animation duration.
     - parameter easingOffset: easing offset.
     */
    func zoomOutWithEasing(duration: TimeInterval = 0.2, easingOffset: CGFloat = 0.2) {
        let easeScale = 1.0 + easingOffset
        let easingDuration = TimeInterval(easingOffset) * duration / TimeInterval(easeScale)
        let scalingDuration = duration - easingDuration
        UIView.animate(withDuration: easingDuration, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
            self.transform = CGAffineTransform(scaleX: easeScale, y: easeScale)
        }, completion: { (completed: Bool) -> Void in
            UIView.animate(withDuration: scalingDuration, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
                self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            }, completion: { (completed: Bool) -> Void in
            })
        })
    }
}

//5 Types of animate a View: Animate, Pulsate, Flash, Shake, Zoom In
extension UIView {
    
    /** Boing the UIView */
    func boing() {
        self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)//How much it expands (0 much, 0.9 little)
        UIView.animate(withDuration: 1.5, //Duration (Normal is 2)
            delay: 0, //Time to take to start the animation
            usingSpringWithDamping: CGFloat(0.2), //How much vibration (0.1 much, 1 little)
            initialSpringVelocity: CGFloat(10),//Makes it bigger in the beggining (normal 6,big100)
            options: UIView.AnimationOptions.allowUserInteraction,
            animations: { self.transform = CGAffineTransform.identity },
            completion: { Void in()  } )
    }
    
    /** Zoom In the UIView */
    func zoomIn(duration: TimeInterval = 0.2) {
        self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveLinear], animations: { () -> Void in
            self.transform = CGAffineTransform.identity
        }) { (animationCompleted: Bool) -> Void in
        }
    }
    
    /** Animate like a pulse the UIView */
    func pulsate() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.5
        pulse.fromValue = 1
        pulse.toValue = 0.9
        pulse.autoreverses = false
        pulse.repeatCount = 0
        pulse.initialVelocity = 10
        pulse.damping = 0.05
        layer.add(pulse, forKey: "pulse")
    }

    /** Make a flash in the view */
    func flash() {
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.5
        flash.fromValue = 0.1
        flash.toValue = 1
        flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        flash.autoreverses = false
        flash.repeatCount = 0
        layer.add(flash, forKey: nil)
    }

    /** Shake the UIView, usually for show an error */
    func shake() {
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.05 //vibrating:0.005
        shake.repeatCount = 3 //Vibrating: 50
        shake.autoreverses = true

        let fromPoint = CGPoint(x: center.x - 5, y: center.y)
        let fromValue = NSValue(cgPoint: fromPoint)

        let toPoint = CGPoint(x: center.x + 5, y: center.y)
        let toValue = NSValue(cgPoint: toPoint)

        shake.fromValue = fromValue
        shake.toValue = toValue

        layer.add(shake, forKey: "position")
    }
}

extension String {
    /**Convert Date String to Date Object
     - parameter withFormat: Format of the Date
     */
    func toDate() -> Date {
        
        DateFormatter().dateFormat = "yyyy-MM-dd"
        let date = DateFormatter().date(from: self)!
        return date
        
//        guard let date = DateFormatter().date(from: self) else {
//            preconditionFailure("Take a look to your format")
//        }
    }
}

extension Double {
    /**Round a number to 1,2,3 or 4 decimals. 2 Decimal by default
     - parameter decimals:     number of decimals.
     */
    func roundWithDecimal(decimals : Int = 2) -> Double{
        
        if var priceText = Double?(self){
            if decimals == 1{
                priceText = (priceText * 10).rounded()/10
            }else if decimals == 2{
                priceText = (priceText * 100).rounded()/100
            }else if decimals == 3{
                priceText = (priceText * 1000).rounded()/1000
            }else if decimals == 4{
                priceText = (priceText * 10000).rounded()/10000
            }
            return priceText
        }else{
            return 0
        }
    }
}
