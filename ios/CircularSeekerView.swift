//
//  CircularSeekerView.swift
//  CircularSeekerLib
//
//  Created by mac 2018 on 8/20/20.
//

import Foundation

//
//  CircularSeeker.swift
//  CircularSeek
//
//  Created by Karthik Keyan on 11/21/15.
//  Copyright © 2015 Karthik Keyan. All rights reserved.
//

import UIKit

private func degreeToRadian(degree: Double) -> Double {
    return Double(degree * (Double.pi/180))
}

private func radianToDegree(radian: Double) -> Double {
    return Double(radian * (180/Double.pi))
}

protocol CircularSeekerDelegate: class {
    func circularSeeker(_ seeker: CircularSeekerView, didChangeValue value: Float)
}

class CircularSeekerView: UIControl {

    weak var delegate: CircularSeekerDelegate?

    lazy var seekerBarLayer = CAShapeLayer()
    lazy var progressLayer = CAShapeLayer()
    lazy var thumbButton = UIButton(type: .custom)
    
  
    @objc var maxVal : Int = 100
    @objc var minVal : Int = 0
  
    var progressVal : Int = 0
    var moving : Bool = true

    @objc var onUpdate: RCTDirectEventBlock?
    @objc var onComplete: RCTDirectEventBlock?
    
    @objc func sendUpdate() {
      if onUpdate != nil {
        print("onUpdate call ", progressVal)
        onUpdate!(   ["progressVal": progressVal]   )
      }else {
        print("onUpdate null")
      }
    }
  
    @objc func sendComplete() {
      if onComplete != nil {
        print("onComplete call")
        onComplete!(   ["progressVal": progressVal]    )
      }
    }
  
    @objc var startAngle: Float = 120.0 {
        didSet {
            self.setNeedsLayout()
        }
    }

    @objc var endAngle: Float = 60.0 {
        didSet {
            self.setNeedsLayout()
        }
    }

    @objc var currentAngle: Float = 120.0 {
        didSet {
            self.setNeedsLayout()
        }
    }

    @objc var seekBarColor: UIColor = .gray {
        didSet {
            seekerBarLayer.strokeColor = seekBarColor.cgColor
            self.setNeedsDisplay()
        }
    }

    @objc var thumbColor: UIColor = .yellow {
        didSet {
            thumbButton.backgroundColor = thumbColor
            progressLayer.strokeColor = thumbColor.cgColor
            self.setNeedsDisplay()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        initSubViews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        initSubViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: Private Methods -

    private func initSubViews() {
        addSeekerBar()
        addThumb()
        addProgress()
    }

    private func addSeekerBar() {
        let center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)

        let sAngle = degreeToRadian(degree: Double(startAngle))
        let eAngle = degreeToRadian(degree: Double(endAngle))

        let path = UIBezierPath(arcCenter: center, radius: (self.bounds.size.width - 18)/2, startAngle: CGFloat(sAngle), endAngle: CGFloat(eAngle), clockwise: true)

        seekerBarLayer.path = path.cgPath
        seekerBarLayer.lineWidth = 7.0
        seekerBarLayer.lineCap = CAShapeLayerLineCap.round
        seekerBarLayer.strokeColor = seekBarColor.cgColor
        seekerBarLayer.fillColor = UIColor.clear.cgColor

        if seekerBarLayer.superlayer == nil {
            self.layer.addSublayer(seekerBarLayer)
        }
    }

    private func addThumb() {
        thumbButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        thumbButton.backgroundColor = thumbColor
        thumbButton.layer.cornerRadius = thumbButton.frame.size.width/2
        thumbButton.layer.masksToBounds = true
        thumbButton.isUserInteractionEnabled = false
        self.addSubview(thumbButton)
    }

    private func addProgress() {
      print("current %f", currentAngle, thumbColor.cgColor);
        let center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)

        let sAngle = degreeToRadian(degree: Double(startAngle))
        let eAngle = degreeToRadian(degree: Double(270))

        let path = UIBezierPath(arcCenter: center, radius: (self.bounds.size.width - 18)/2, startAngle: CGFloat(sAngle), endAngle: CGFloat(eAngle), clockwise: true)

        progressLayer.path = path.cgPath
        progressLayer.lineWidth = 7.0
        progressLayer.lineCap = CAShapeLayerLineCap.round
        progressLayer.strokeColor = thumbColor.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor

        if progressLayer.superlayer == nil {
            self.layer.addSublayer(progressLayer)
        }
    }

    private func updateThumbPosition() {
        let angle = degreeToRadian(degree: Double(currentAngle))

        let x = cos(angle)
        let y = sin(angle)

        var rect = thumbButton.frame

        let radius = self.frame.size.width * 0.5
        let center = CGPoint(x: radius, y: radius)
        let thumbCenter: CGFloat = 10.0

        // x = cos(angle) * radius + CenterX;
        let finalX = (CGFloat(x) * (radius - thumbCenter)) + center.x

        // y = sin(angle) * radius + CenterY;
        let finalY = (CGFloat(y) * (radius - thumbCenter)) + center.y

        rect.origin.x = finalX - thumbCenter
        rect.origin.y = finalY - thumbCenter

        thumbButton.frame = rect
    }

    private func thumbMoveDidComplete() {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [ .curveEaseOut, .beginFromCurrentState ], animations: { () -> Void in
            self.thumbButton.transform = .identity
        }, completion: { [weak self] _ in
            self?.fireValueChangeEvent()
        })
    }

    private func fireValueChangeEvent() {
        delegate?.circularSeeker(self, didChangeValue: currentAngle)
    }

    private func degreeForLocation(location: CGPoint) -> Double {
        let dx = location.x - (self.frame.size.width * 0.5)
        let dy = location.y - (self.frame.size.height * 0.5)

        let angle = Double(atan2(Double(dy), Double(dx)))

        var degree = radianToDegree(radian: angle)
        if degree < 0 {
            degree = 360 + degree
        }

        return degree
    }

    private func moveToPoint(point: CGPoint) -> Bool {
        let degree = degreeForLocation(location: point)

        func moveToClosestEdge(degree: Double) {
          let startDistance = abs(Float(degree) - startAngle)
          let endDistance = abs(Float(degree) - endAngle)

            if startDistance < endDistance {
                currentAngle = startAngle
            }
            else {
                currentAngle = endAngle
            }
        }

        if startAngle > endAngle {
            if degree < Double(startAngle) && degree > Double(endAngle) {
                moveToClosestEdge(degree: degree)
                thumbMoveDidComplete()
                return false
            }
        }
        else {
            if degree > Double(endAngle) || degree < Double(startAngle) {
                moveToClosestEdge(degree: degree)
                thumbMoveDidComplete()
                return false
            }
        }

        currentAngle = Float(degree)

        return true;
    }


    // MARK: Public Methods -

    func moveToAngle(angle: Float, duration: CFTimeInterval) {
        let center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)

        let sAngle = degreeToRadian(degree: Double(startAngle))
        let eAngle = degreeToRadian(degree: Double(angle))

        let path = UIBezierPath(arcCenter: center, radius: (self.bounds.size.width - 18)/2, startAngle: CGFloat(sAngle), endAngle: CGFloat(eAngle), clockwise: true)

        CATransaction.begin()
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.duration = duration
        animation.path = path.cgPath
        thumbButton.layer.add(animation, forKey: "moveToAngle")
        CATransaction.setCompletionBlock { [weak self] in
            self?.currentAngle = angle
        }
        CATransaction.commit()
    }


    // MARK: Touch Events -

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        moving = true
        let point = touch.location(in: self)

        let rect = self.thumbButton.frame.insetBy(dx: -20, dy: -20)

        let canBegin = rect.contains(point)

        if canBegin {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [ .curveEaseIn, .beginFromCurrentState ], animations: { () -> Void in
                self.thumbButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }, completion: nil)
        }

        return canBegin
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        if #available(iOS 9, *) {
            guard let coalescedTouches = event?.coalescedTouches(for: touch) else {
                return moveToPoint(point: touch.location(in: self))
            }

            let result = true
            for cTouch in coalescedTouches {
                let result = moveToPoint(point: cTouch.location(in: self))

                if result == false { break }
            }

            return result
        }
        
        return moveToPoint(point: touch.location(in: self))
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        moving = false
        print("endTracking")
        thumbMoveDidComplete()
        sendComplete()
    }


    override func layoutSubviews() {
        super.layoutSubviews()
        if(!moving) {return}

        let center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)

        let sAngle = degreeToRadian(degree: Double(startAngle))
        let eAngle = degreeToRadian(degree: Double(endAngle))

        let path = UIBezierPath(arcCenter: center, radius: (self.bounds.size.width - 18)/2, startAngle: CGFloat(sAngle), endAngle: CGFloat(eAngle), clockwise: true)
        seekerBarLayer.path = path.cgPath

        //print("layoutSubviews", CGFloat(sAngle), CGFloat(eAngle))
        let spAngle = degreeToRadian(degree: Double(startAngle))
        let epAngle = degreeToRadian(degree: Double(currentAngle))

        let end = currentAngle < 90 ? (360+currentAngle) : currentAngle
        let endAngle1 = endAngle < 90 ? (360+endAngle) : endAngle
        //print("temp:", end , startAngle, (end - startAngle) / 10)
        
        let spaceAngle = end - startAngle
        let maxSpaceAngle = endAngle1 - startAngle
        let maxSpaceVal = maxVal - minVal
        progressVal = minVal + Int(spaceAngle) * maxSpaceVal / Int(maxSpaceAngle)
        
        print("temp:", spaceAngle, progressVal)
        //#selector(sendUpdate(_:))
        sendUpdate()
      
        let pathProgress = UIBezierPath(arcCenter: center, radius: (self.bounds.size.width - 18)/2, startAngle: CGFloat(spAngle), endAngle: CGFloat(epAngle), clockwise: true)


        progressLayer.path = pathProgress.cgPath
        updateThumbPosition()
    }
}
