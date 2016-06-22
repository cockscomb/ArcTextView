//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

let str = "Hello, playground"

let view = ArcTextView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
view.backgroundColor = UIColor.white()
view.attributedText = AttributedString(string: str, attributes: [
    NSForegroundColorAttributeName: UIColor.black(),
    NSFontAttributeName: UIFont.systemFont(ofSize: 24),
    ])
view.alignment = .center
view.radius = 100
view.angle = 2 * CGFloat(M_PI)

PlaygroundPage.current.liveView = view
