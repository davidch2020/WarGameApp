//
//  Animations.swift
//  War
//
//  Created by David Cho on 12/1/20.
//  Copyright © 2020 David Cho. All rights reserved.
//

import UIKit

class Animations {
    static func scaleBounce(_ view: UIView, scale: Double) {
        UIView.animate(withDuration: 0.125, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options: [.curveEaseInOut], animations: {view.transform = CGAffineTransform(scaleX: CGFloat(scale), y: CGFloat(scale))
        })
        {(finished: Bool) -> Void in
            UIView.animate(withDuration: 0.125, animations: {
                view.transform = .identity
            })
        }
    }
    
    static func swell(view: UIView) {
        scaleBounce(view, scale: 1.75)
    }
    
    static func shrink(view: UIView) {
        scaleBounce(view, scale: 0.75)
    }

}
