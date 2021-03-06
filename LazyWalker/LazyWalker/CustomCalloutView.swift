//
//  CustomCalloutView.swift
//  LazyWalker
//
//  Created by Emmet Susslin on 2/21/17.
//  Copyright © 2017 Emmet Susslin. All rights reserved.
//

import Mapbox

class MyTapGestureRecognizer: UITapGestureRecognizer {
    var id: String?
}

class CustomCalloutView: UIView, MGLCalloutView {
    var representedObject: MGLAnnotation
    
    // Lazy initialization of optional vars for protocols causes segmentation fault: 11s in Swift 3.0. https://bugs.swift.org/browse/SR-1825
    
    var leftAccessoryView = UIView() /* unused */
    var rightAccessoryView = UIView() /* unused */
    
    weak var delegate: MGLCalloutViewDelegate?
    
    let tipHeight: CGFloat = 10.0
    let tipWidth: CGFloat = 20.0
    
    let mainBody: UIButton
    
    required init(representedObject: MGLAnnotation) {
        self.representedObject = representedObject
        self.mainBody = UIButton(type: .system)
        
        super.init(frame: .zero)
        
        backgroundColor = .clear
        
        mainBody.backgroundColor = .darkGray
        mainBody.tintColor = .white
        mainBody.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        mainBody.layer.cornerRadius = 4.0
        
        addSubview(mainBody)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - MGLCalloutView API
    func presentCallout(from rect: CGRect, in view: UIView, constrainedTo constrainedView: UIView, animated: Bool) {
        if !representedObject.responds(to: Selector("title")) {
            return
        }
        
        let num = Int(representedObject.title!!)!
        
        let sortedAscend = ascend.sorted()
        
        let index = ascend.index(of: sortedAscend[num])!
        
        let totalClimb = "Climb: " + "\(Int(sortedAscend[num]))" + " meters"
        let distance = "Distance: " + "\(Int(totalDistance[index]))" + " meters"
        
        
        
        let theindex = sortedAscend.index(of: ascend[index])!
        
        
        view.addSubview(self)
        
        mainBody.titleLabel!.lineBreakMode = .byWordWrapping
        mainBody.titleLabel!.textAlignment = .center
        mainBody.setTitle("\(totalClimb)" + "\n" + "\(distance)", for: .normal)

        mainBody.sizeToFit()
        
        if isCalloutTappable() {
            // Handle taps and eventually try to send them to the delegate (usually the map view)
            mainBody.addTarget(self, action: #selector(CustomCalloutView.calloutTapped), for: .touchUpInside)
        } else {
            // Disable tapping and highlighting
            mainBody.isUserInteractionEnabled = false
        }
        
        // Prepare our frame, adding extra space at the bottom for the tip
        let frameWidth = mainBody.bounds.size.width
        let frameHeight = mainBody.bounds.size.height + tipHeight
        let frameOriginX = rect.origin.x + (rect.size.width/2.0) - (frameWidth/2.0)
        let frameOriginY = rect.origin.y - frameHeight
        frame = CGRect(x: frameOriginX, y: frameOriginY, width: frameWidth, height: frameHeight)
        
        if animated {
            alpha = 0
            
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.alpha = 1
            }
        }
    }
    
    func dismissCallout(animated: Bool) {
        if (superview != nil) {
            if animated {
                UIView.animate(withDuration: 0.2, animations: { [weak self] in
                    self?.alpha = 0
                    }, completion: { [weak self] _ in
                        self?.removeFromSuperview()
                })
            } else {
                removeFromSuperview()
            }
        }
    }
    
    // MARK: - Callout interaction handlers
    
    func isCalloutTappable() -> Bool {
        if let delegate = delegate {
            if delegate.responds(to: #selector(MGLCalloutViewDelegate.calloutViewShouldHighlight)) {
                return delegate.calloutViewShouldHighlight!(self)
            }
        }
        return false
    }
    
    func calloutTapped() {
        if isCalloutTappable() && delegate!.responds(to: #selector(MGLCalloutViewDelegate.calloutViewTapped)) {
            delegate!.calloutViewTapped!(self)
        }
    }
    

}
