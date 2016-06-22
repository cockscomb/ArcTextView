//: Playground - noun: a place where people can play

import UIKit
import XCPlayground

let str = "Hello, playground"

let view = ArcTextView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
view.backgroundColor = UIColor.whiteColor()
view.attributedText = NSAttributedString(string: str, attributes: [
    NSForegroundColorAttributeName: UIColor.blackColor(),
    NSFontAttributeName: UIFont.systemFontOfSize(24),
])
view.alignment = .Center
view.radius = 100
view.angle = 2 * CGFloat(M_PI)

XCPlaygroundPage.currentPage.liveView = view
