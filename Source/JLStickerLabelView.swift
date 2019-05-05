//
//  JLStickerLabelView.swift
//  stickerTextView
//
//  Created by 刘业臻 on 16/4/19.
//  Copyright © 2016年 luiyezheng. All rights reserved.
//

import UIKit

public class JLStickerLabelView: UIView {
    // MARK: -

    // MARK: Gestures

    fileprivate lazy var moveGestureRecognizer: UIPanGestureRecognizer! = {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(JLStickerLabelView.moveGesture(_:)))
        panRecognizer.delegate = self
        return panRecognizer
    }()

    fileprivate lazy var singleTapShowHide: UITapGestureRecognizer! = {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(JLStickerLabelView.contentTapped(_:)))
        tapRecognizer.delegate = self
        return tapRecognizer
    }()

    fileprivate lazy var closeTap: UITapGestureRecognizer! = {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(JLStickerLabelView.closeTap(_:)))
        tapRecognizer.delegate = self
        return tapRecognizer
    }()

    fileprivate lazy var panRotateGesture: UIPanGestureRecognizer! = {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(JLStickerLabelView.rotateViewPanGesture(_:)))
        panRecognizer.delegate = self
        return panRecognizer
    }()
    
    fileprivate lazy var pinchRotateGesture: UIPinchGestureRecognizer! = {
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(JLStickerLabelView.pinchViewPanGesture(_:)))
        pinchRecognizer.delegate = self
        return pinchRecognizer
    }()

    // MARK: -

    // MARK: properties

    fileprivate var lastTouchedView: JLStickerLabelView?

    var delegate: JLStickerLabelViewDelegate?

    fileprivate var globalInset: CGFloat = 10

    fileprivate var initialBounds: CGRect?
    fileprivate var initialDistance: CGFloat?

    fileprivate var beginningPoint: CGPoint?
    fileprivate var beginningCenter: CGPoint?

    fileprivate var touchLocation: CGPoint?

    fileprivate var deltaAngle: CGFloat?
    fileprivate var beginBounds: CGRect?

    public var border: CAShapeLayer?
    public var labelTextView: JLAttributedTextView?
    public var rotateView: UIImageView?
    public var closeView: UIImageView?
    public var imageView: UIImageView?
    public var pro = false

    var isShowingEditingHandles = true

    public var borderColor: UIColor? {
        didSet {
            border?.strokeColor = borderColor?.cgColor
        }
    }

    // MARK: -

    // MARK: Set Control Buttons

    public var enableClose: Bool = true {
        didSet {
            closeView?.isHidden = enableClose
            closeView?.isUserInteractionEnabled = enableClose
        }
    }

    public var enableRotate: Bool = true {
        didSet {
            rotateView?.isHidden = enableRotate
            rotateView?.isUserInteractionEnabled = enableRotate
        }
    }

    public var enableMoveRestriction: Bool = true {
        didSet {}
    }

    public var showsContentShadow: Bool = false {
        didSet {
            if showsContentShadow {
                layer.shadowColor = UIColor.black.cgColor
                layer.shadowOffset = CGSize(width: 0, height: 5)
                layer.shadowOpacity = 1.0
                layer.shadowRadius = 4.0
            } else {
                layer.shadowColor = UIColor.clear.cgColor
                layer.shadowOffset = CGSize.zero
                layer.shadowOpacity = 0.0
                layer.shadowRadius = 0.0
            }
        }
    }

    // MARK: -

    // MARK: didMoveToSuperView

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            showEditingHandles()
            refresh()
        }
    }

    // MARK: -

    // MARK: init

    init() {
        super.init(frame: CGRect.zero)
//        setup()
//        adjustsWidthToFillItsContens(self)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        if frame.size.width < 25 {
            bounds.size.width = 25
        }

        if frame.size.height < 25 {
            bounds.size.height = 25
        }

//        self.setup()
//        adjustsWidthToFillItsContens(self)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        setup()
//        adjustsWidthToFillItsContens(self)
    }

    public override func layoutSubviews() {
        if labelTextView != nil {
            border?.path = UIBezierPath(rect: labelTextView!.bounds).cgPath
            border?.frame = labelTextView!.bounds
        } else if imageView != nil {
            border?.path = UIBezierPath(rect: imageView!.bounds).cgPath
            border?.frame = imageView!.bounds
        }
    }

    private func setup() {
        setupCloseAndRotateView()

        addGestureRecognizer(moveGestureRecognizer)
        addGestureRecognizer(singleTapShowHide)
        addGestureRecognizer(pinchRotateGesture)
        moveGestureRecognizer.require(toFail: closeTap)

        closeView!.addGestureRecognizer(closeTap)
        rotateView!.addGestureRecognizer(panRotateGesture)

        enableMoveRestriction = true
        enableClose = true
        enableRotate = true
        showsContentShadow = true

        showEditingHandles()

        adjustsWidthToFillItsContens(self)
    }

    func setupTextLabel() {

        backgroundColor = UIColor.clear
        autoresizingMask = [.flexibleHeight, .flexibleWidth]
        border?.strokeColor = UIColor(red: 33, green: 45, blue: 59, alpha: 1).cgColor

        setupLabelTextView()
        setupBorder()

        insertSubview(labelTextView!, at: 0)

        setup()

        adjustsWidthToFillItsContens(self)
    }

    func setupImageLabel() {

        backgroundColor = UIColor.clear
        autoresizingMask = [.flexibleHeight, .flexibleWidth]
        border?.strokeColor = UIColor(red: 33, green: 45, blue: 59, alpha: 1).cgColor

        setupImageView()
        setupBorder()

        insertSubview(imageView!, at: 0)

        setup()

        var viewFrame = bounds
        viewFrame.size.width = 100
        viewFrame.size.height = 100
        bounds = viewFrame
    }
}

// MARK: -

// MARK: labelTextViewDelegate

extension JLStickerLabelView: UITextViewDelegate {
    public func textViewShouldBeginEditing(_: UITextView) -> Bool {
        if isShowingEditingHandles {
            return true
        }
        return false
    }

    public func textViewDidBeginEditing(_: UITextView) {
        delegate?.labelViewDidStartEditing?(self)
    }

    public func textView(_: UITextView, shouldChangeTextIn _: NSRange, replacementText _: String) -> Bool {
        if !isShowingEditingHandles {
            showEditingHandles()
        }
        // if textView.text != "" {
        // adjustsWidthToFillItsContens(self, labelView: labelTextView)
        // }

        return true
    }

    public func textViewDidChange(_ textView: UITextView) {
        if !textView.text.isEmpty {
            if labelTextView != nil {
                adjustsWidthToFillItsContens(self)
                labelTextView!.attributedText = NSAttributedString(string: labelTextView!.text, attributes: labelTextView!.textAttributes)
            }
        }
    }
}

// MARK: -

// MARK: GestureRecognizer

extension JLStickerLabelView: UIGestureRecognizerDelegate, adjustFontSizeToFillRectProtocol {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == singleTapShowHide {
            return true
        }
        return false
    }

    @objc func contentTapped(_: UITapGestureRecognizer) {
        if !isShowingEditingHandles {
            showEditingHandles()
            delegate?.labelViewDidSelected?(self)
        }
    }

    @objc func closeTap(_: UITapGestureRecognizer?) {
        removeFromSuperview()
        delegate?.labelViewDidClose?(self)
    }

    @objc func moveGesture(_ recognizer: UIPanGestureRecognizer) {
        if !isShowingEditingHandles {
            showEditingHandles()
            delegate?.labelViewDidSelected?(self)
        }
        
        labelTextView?.endEditing(true)
        
        touchLocation = recognizer.location(in: superview)

        switch recognizer.state {
        case .began:
            beginningPoint = touchLocation
            beginningCenter = center

            center = estimatedCenter()
            beginBounds = bounds
            delegate?.labelViewDidBeginEditing?(self)
            
        case .changed:
            center = estimatedCenter()
            delegate?.labelViewDidChangeEditing?(self)

        case .ended:
            center = estimatedCenter()
            delegate?.labelViewDidEndEditing?(self)

        default: break
        }
    }
    
    @objc func pinchViewPanGesture(_ recognizer: UIPinchGestureRecognizer) {
        
        let scale = recognizer.scale
        
        switch recognizer.state {
        case .began:
            initialBounds = bounds
        case .changed:
            let scaleRect = CalculateFunctions.CGRectScale(initialBounds!, wScale: CGFloat(scale), hScale: CGFloat(scale))
            debugPrint(scaleRect)
            if scaleRect.size.width >= (1 + globalInset * 4), scaleRect.size.height >= (1 + globalInset * 4), (labelTextView?.text != "" || imageView?.image != nil) {
                //  if fontSize < 100 || CGRectGetWidth(scaleRect) < CGRectGetWidth(self.bounds) {
                if labelTextView?.text != nil, scale < 1, (labelTextView?.fontSize ?? 0) <= 9 {} else {
                    if imageView?.image != nil && scaleRect.size.width < 100 {
                        bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
                        return
                    }
                    if imageView?.image != nil && scaleRect.size.width > UIScreen.main.bounds.size.width {
                        bounds = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width)
                        return
                    }
                    adjustFontSizeToFillRect(scaleRect, view: self)
                    bounds = scaleRect
                    adjustsWidthToFillItsContens(self)
                    refresh()
                }
            }
        case .ended:
            break
        @unknown default:
            break
        }
    }
    
    @objc func rotateViewPanGesture(_ recognizer: UIPanGestureRecognizer) {
        touchLocation = recognizer.location(in: superview)

        let center = CalculateFunctions.CGRectGetCenter(frame)

        switch recognizer.state {
        case .began:
            
            deltaAngle = atan2(touchLocation!.y - center.y, touchLocation!.x - center.x) - CalculateFunctions.CGAffineTrasformGetAngle(transform)
            initialBounds = bounds
            initialDistance = CalculateFunctions.CGpointGetDistance(center, point2: touchLocation!)
            delegate?.labelViewDidBeginEditing?(self)
            
        case .changed:
            
            let ang = atan2(touchLocation!.y - center.y, touchLocation!.x - center.x)

            let angleDiff = deltaAngle! - ang
            transform = CGAffineTransform(rotationAngle: -angleDiff)
            layoutIfNeeded()
            // Finding scale between current touchPoint and previous touchPoint
            let scale = sqrtf(Float(CalculateFunctions.CGpointGetDistance(center, point2: touchLocation!)) / Float(initialDistance!))
            let scaleRect = CalculateFunctions.CGRectScale(initialBounds!, wScale: CGFloat(scale), hScale: CGFloat(scale))
            
//            print("bounds\(bounds)")
//            print("ang\(ang)")
//            print("angleDiff\(angleDiff)")
//            print("scale\(scale)")
//            print("scaleRect\(scaleRect)\n")
            
            if scaleRect.size.width >= (1 + globalInset * 4), scaleRect.size.height >= (1 + globalInset * 4), (labelTextView?.text != "" || imageView?.image != nil) {
                //  if fontSize < 100 || CGRectGetWidth(scaleRect) < CGRectGetWidth(self.bounds) {
                if labelTextView?.text != nil, scale < 1, (labelTextView?.fontSize ?? 0) <= 9 {} else {
                    if imageView?.image != nil && scaleRect.size.width < 100 {
                        bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
                        return
                    }
                    if imageView?.image != nil && scaleRect.size.width > UIScreen.main.bounds.size.width {
                        bounds = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width)
                        return
                    }
                    adjustFontSizeToFillRect(scaleRect, view: self)
                    bounds = scaleRect
                    adjustsWidthToFillItsContens(self)
                    refresh()
                }
            }
            
            delegate?.labelViewDidChangeEditing?(self)
            
        case .ended:
            delegate?.labelViewDidEndEditing?(self)
            refresh()

        // self.adjustsWidthToFillItsContens(self, labelView: labelTextView)
        default: break
        }
    }
}

// MARK: -

// MARK: setup

extension JLStickerLabelView {
    private func setupLabelTextView() {
        labelTextView = JLAttributedTextView(frame: bounds.insetBy(dx: globalInset * 2 - 1, dy: globalInset * 2 - 1))
        labelTextView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        labelTextView?.clipsToBounds = true
        labelTextView?.delegate = self
        labelTextView?.backgroundColor = UIColor.clear
        labelTextView?.tintColor = .gray
        labelTextView?.isScrollEnabled = false
        labelTextView?.isSelectable = true
        labelTextView?.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    private func setupBorder() {
        border = CAShapeLayer(layer: layer)
        border?.strokeColor = borderColor?.cgColor
        border?.fillColor = nil
        border?.lineDashPattern = [10, 2]
        border?.lineWidth = 1
    }

    private func setupCloseAndRotateView() {
        closeView = UIImageView(frame: CGRect(x: globalInset, y: globalInset, width: globalInset * 2, height: globalInset * 2))
        closeView?.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
        closeView?.contentMode = .center
        closeView?.clipsToBounds = true
        closeView?.backgroundColor = UIColor.clear
        closeView?.isUserInteractionEnabled = true
        addSubview(closeView!)

        rotateView = UIImageView(frame: CGRect(x: bounds.size.width - globalInset * 3, y: bounds.size.height - globalInset * 3, width: globalInset * 2, height: globalInset * 2))
        rotateView?.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
        rotateView?.backgroundColor = UIColor.clear
        rotateView?.clipsToBounds = true
        rotateView?.contentMode = .center
        rotateView?.isUserInteractionEnabled = true
        addSubview(rotateView!)
    }

    private func setupImageView() {
        imageView = UIImageView(frame: bounds.insetBy(dx: globalInset * 2, dy: globalInset * 2))
        imageView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView?.contentMode = .scaleAspectFit
        imageView?.clipsToBounds = true
        imageView?.backgroundColor = UIColor.clear
    }
}

// MARK: -

// MARK: Help funcitons

extension JLStickerLabelView {
    fileprivate func refresh() {
        if let superView: UIView = self.superview {
            let transform: CGAffineTransform = superView.transform
            let scale = CalculateFunctions.CGAffineTransformGetScale(transform)
            let t = CGAffineTransform(scaleX: scale.width, y: scale.height)
            closeView?.transform = t.inverted()
            rotateView?.transform = t.inverted()

            if isShowingEditingHandles {
                if let border: CALayer = border {
                    labelTextView?.layer.addSublayer(border)
                    imageView?.layer.addSublayer(border)
                }
            } else {
                border?.removeFromSuperlayer()
            }
        }
    }

    public func hideEditingHandlers() {
        lastTouchedView = nil

        isShowingEditingHandles = false

        if enableClose {
            closeView?.isHidden = true
        }
        if enableRotate {
            rotateView?.isHidden = true
        }

        labelTextView?.resignFirstResponder()

        refresh()

        delegate?.labelViewDidHideEditingHandles?(self)
        
    }

    public func showEditingHandles() {
        lastTouchedView?.hideEditingHandlers()

        isShowingEditingHandles = true

        lastTouchedView = self

        if enableClose {
            closeView?.isHidden = false
        }

        if enableRotate {
            rotateView?.isHidden = false
        }

        refresh()

        delegate?.labelViewDidShowEditingHandles?(self)
    }

    fileprivate func estimatedCenter() -> CGPoint {
        let newCenter: CGPoint!
        var newCenterX = beginningCenter!.x + (touchLocation!.x - beginningPoint!.x)
        var newCenterY = beginningCenter!.y + (touchLocation!.y - beginningPoint!.y)

        if enableMoveRestriction {
            if !(newCenterX - 0.5 * frame.width > 0 &&
                newCenterX + 0.5 * frame.width < superview!.bounds.width) {
                newCenterX = center.x
            }
            if !(newCenterY - 0.5 * frame.height > 0 &&
                newCenterY + 0.5 * frame.height < superview!.bounds.height) {
                newCenterY = center.y
            }
            newCenter = CGPoint(x: newCenterX, y: newCenterY)
        } else {
            newCenter = CGPoint(x: newCenterX, y: newCenterY)
        }
        return newCenter
    }
}

// MARK: -

// MARK: delegate

@objc public protocol JLStickerLabelViewDelegate: NSObjectProtocol {
    /**
     *  Occurs when a touch gesture event occurs on close button.
     *
     *  @param label    A label object informing the delegate about action.
     */
    @objc optional func labelViewDidClose(_ label: JLStickerLabelView) -> Void
    /**
     *  Occurs when border and control buttons was shown.
     *
     *  @param label    A label object informing the delegate about showing.
     */
    @objc optional func labelViewDidShowEditingHandles(_ label: JLStickerLabelView) -> Void
    /**
     *  Occurs when border and control buttons was hidden.
     *
     *  @param label    A label object informing the delegate about hiding.
     */
    @objc optional func labelViewDidHideEditingHandles(_ label: JLStickerLabelView) -> Void
    /**
     *  Occurs when label become first responder.
     *
     *  @param label    A label object informing the delegate about action.
     */
    @objc optional func labelViewDidStartEditing(_ label: JLStickerLabelView) -> Void
    /**
     *  Occurs when label starts move or rotate.
     *
     *  @param label    A label object informing the delegate about action.
     */
    @objc optional func labelViewDidBeginEditing(_ label: JLStickerLabelView) -> Void
    /**
     *  Occurs when label continues move or rotate.
     *
     *  @param label    A label object informing the delegate about action.
     */
    @objc optional func labelViewDidChangeEditing(_ label: JLStickerLabelView) -> Void
    /**
     *  Occurs when label ends move or rotate.
     *
     *  @param label    A label object informing the delegate about action.
     */
    @objc optional func labelViewDidEndEditing(_ label: JLStickerLabelView) -> Void

    @objc optional func labelViewDidSelected(_ label: JLStickerLabelView) -> Void
}
