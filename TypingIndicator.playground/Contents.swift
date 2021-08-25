//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

final class TypingIndicator: UIView {
    // size of each dot
    var dotSize: CGFloat = 8
    
    // duration of each piece of the animation
    var animationStepDuration: TimeInterval = 0.5
    
    // delay between each of the 3 dots animating
    var animationDotDelay: TimeInterval = 0.1
    
    // pause at the end before the whole animation repeats
    var animationEndDelay: TimeInterval = 0.2
    // color of the dots
    
    var dotColor: UIColor = .secondaryLabel
    
    // insets from the edges of the view
    var margins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    
    // defines the default size of the view, giving it width & height constraints will override this
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 50, height: 36)
    }
    
    override func draw(_ rect: CGRect) {
        let adjustedRect = rect.inset(by: margins)
        let leftDot = dotLayer(at: margins.left, within: adjustedRect)
        layer.addSublayer(leftDot)
        animate(dotLayer: leftDot, within: adjustedRect)
        
        let centerDot = dotLayer(at: adjustedRect.midX - dotSize/2, within: adjustedRect)
        layer.addSublayer(centerDot)
        animate(dotLayer: centerDot, within: adjustedRect, delay: animationDotDelay)

        let rightDot = dotLayer(at: adjustedRect.maxX - dotSize, within: rect)
        layer.addSublayer(rightDot)
        animate(dotLayer: rightDot, within: adjustedRect, delay: animationDotDelay * 2)
    }
    
    private func dotLayer(at x: CGFloat, within rect: CGRect) -> CAShapeLayer {
        let dot = CAShapeLayer()
        dot.fillColor = dotColor.cgColor
        dot.position = CGPoint(x: x, y: rect.maxY - dotSize)
        dot.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: dotSize, height: dotSize)).cgPath
        return dot
    }
    
    private func animate(dotLayer: CAShapeLayer, within rect: CGRect, delay: TimeInterval = 0.0) {
        let upAnimation = CABasicAnimation(keyPath: "position.y")
        upAnimation.fromValue = rect.maxY - dotSize
        upAnimation.toValue = rect.minY
        upAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        upAnimation.duration = animationStepDuration
        upAnimation.fillMode = .forwards
        
        let downAnimation = CASpringAnimation(keyPath: "position.y")
        downAnimation.fromValue = rect.minY
        downAnimation.toValue = rect.maxY - dotSize
        downAnimation.duration = animationStepDuration
        downAnimation.damping = 6
        downAnimation.mass = 0.5
        downAnimation.initialVelocity = 5
        downAnimation.fillMode = .forwards
        downAnimation.beginTime = 0.5
        
        let group = CAAnimationGroup()
        group.animations = [upAnimation, downAnimation]
        group.duration = animationStepDuration * 2 + animationEndDelay
        group.repeatCount = .greatestFiniteMagnitude
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            dotLayer.add(group, forKey: nil)
        }
    }
}

// test view controller
class MyViewController : UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .darkGray
        let typing = TypingIndicator()
        typing.translatesAutoresizingMaskIntoConstraints = false
        typing.backgroundColor = .white
        view.addSubview(typing)
        
        NSLayoutConstraint.activate([
            typing.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            typing.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        self.view = view
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
