//
//  Color+.swift
//  FoundationProj
//
//  Created by baedy on 2020/07/16.
//  Copyright © 2020 baedy. All rights reserved.
//

// let color = 0x123456.color
// let transparent = 0x123456.color ~ 50%
// let red = UIColor.red ~ 10%
// let float = UIColor.blue ~ 0.5 // == 50%
// let view = UIView()
// view.alpha = 30% // == 0.3

import UIKit

public typealias Color = UIColor

extension Int {
    public var color: Color {
        let red = CGFloat(self as Int >> 16 & 0xff) / 255
        let green = CGFloat(self >> 8 & 0xff) / 255
        let blue = CGFloat(self & 0xff) / 255
        return Color(red: red, green: green, blue: blue, alpha: 1)
    }

    public var cgColor: CGColor {
        let red = CGFloat(self as Int >> 16 & 0xff) / 255
        let green = CGFloat(self >> 8 & 0xff) / 255
        let blue = CGFloat(self & 0xff) / 255
        return CGColor(srgbRed: red, green: green, blue: blue, alpha: 1)
    }
}

precedencegroup AlphaPrecedence {
    associativity: left
    higherThan: RangeFormationPrecedence
    lowerThan: AdditionPrecedence
}

infix operator ~ : AlphaPrecedence

public func ~ (color: Color, alpha: Int) -> Color {
    return color ~ CGFloat(alpha)
}

public func ~ (color: Color, alpha: Float) -> Color {
    return color ~ CGFloat(alpha)
}

public func ~ (color: Color, alpha: CGFloat) -> Color {
    return color.withAlphaComponent(alpha)
}

/// e.g. `50%`
postfix operator %
public postfix func % (percent: Int) -> CGFloat {
    return CGFloat(percent)%
}

public postfix func % (percent: Float) -> CGFloat {
    return CGFloat(percent)%
}

public postfix func % (percent: CGFloat) -> CGFloat {
    return percent / 100
}
