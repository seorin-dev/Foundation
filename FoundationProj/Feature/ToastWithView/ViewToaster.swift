//
//  ViewToaster.swift
//  FoundationProj
//
//  Created by baedy on 2020/08/26.
//  Copyright © 2020 baedy. All rights reserved.
//

import UIKit

/*
 1. view를 받아서 화면 정중앙에 뿌려주는 기능
 2. 뿌려줄 때 시간값 미리 정해두고? 아니면.. 시간값 입력?
*/

class ViewToaster: NSObject {
    static let `default` = ViewToaster()
    
    lazy var toastWindow = UIApplication.shared.keyWindowInConnectedScenes
    
    var currentShowingView: UIView?
    
    func animateStop(){
        currentShowingView?.removeFromSuperview()
    }
    
    func animate(withType type: VTtype, duration: TimeInterval = 1.0, completion: (() -> Void)? = nil) {
        animate(withView: type.view, duration: duration, completion: completion)
    }
    
    func animate(withView view: UIView, duration: TimeInterval = 1.0, completion: (() -> Void)? = nil) {
        
        DispatchQueue.main.async {[weak self] in
            guard let `self` = self else { return }
            self.currentShowingView = view
            view.setNeedsLayout()
            view.alpha = 0

            view.isUserInteractionEnabled = false
            
            self.toastWindow?.addSubview(view)
            view.snp.makeConstraints{
                $0.center.equalToSuperview()
            }
            
            let durate = (duration - 0.1 ) / 3
            
            UIView.animate(withDuration: durate,
                           delay: 0.1,
                           options: .beginFromCurrentState,
                           animations: { view.alpha = 1 },
                           completion: { _ in
                            UIView.animate(withDuration: durate,
                                           animations: { view.alpha = 1.0001 },
                                           completion: {_ in
                                            UIView.animate(withDuration: durate, animations: { view.alpha = 0 }, completion: { _ in view.removeFromSuperview() })
                            })
            })
        }
    }

}

enum VTtype {
    case label(Int)
    case seeker(Int)
    
    var view: UIView {
        switch self {
        case .label(let count):
            return makeShutterLabel(count)
        case .seeker(let time):
            return SeekerView(time: time)
        }
    }
    
    func makeShutterLabel(_ count: Int) -> UILabel{
        return UILabel().then{
            $0.text = "\(count)"
            $0.textAlignment = .center
            $0.font = .systemFont(ofSize: 74)
            $0.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            $0.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
            $0.layer.shadowOpacity = 0.3
            $0.layer.shadowRadius = 6
        }
    }
}

class SeekerView: UIView{
    lazy var imageView = UIImageView().then{
        $0.contentMode = .scaleToFill
    }
    
    lazy var timeLabel = UILabel().then{
        $0.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        $0.textAlignment = .center
    }
    
    init(time: Int) {
        super.init(frame: .zero)
        setupLayout()
        setupValue(time: time)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        self.isUserInteractionEnabled = false
        self.addSubviews([imageView, timeLabel])
        imageView.snp.makeConstraints{
            $0.height.width.equalTo(116)
            $0.center.equalToSuperview()
        }
        
        timeLabel.snp.makeConstraints{
            $0.centerX.equalTo(imageView.snp.centerX)
            $0.bottom.equalTo(imageView.snp.bottom).offset(-22)
        }
    }
    
    func setupValue(time: Int) {
        imageView.image = time < 0 ? #imageLiteral(resourceName: "imgPlayBack") : #imageLiteral(resourceName: "imgPlayForward")
        timeLabel.text = self.makeTimeStr(time)
        timeLabel.letterSpace = -0.4
    }
    
    func makeTimeStr(_ time: Int) -> String{
        let min = time / 60
        let second = time % 60
        
        return "\(min.timeString):\(second.timeString)"
    }
    
}

extension Int {
    /// (n == 0) -> 00, (n < 10) -> 0n , (10 > n) -> n
    var timeString: String{
        let absInt = abs(self)
        switch absInt {
        case 0:
            return "00"
        case 1 ..< 10:
            return "0\(absInt)"
        default:
            return "\(absInt)"
        }
    }
}

extension UILabel {
    
    var letterSpace: CGFloat {
        set {
            let attributedString: NSMutableAttributedString!
            if let currentAttrString = attributedText {
                attributedString = NSMutableAttributedString(attributedString: currentAttrString)
            } else {
                attributedString = NSMutableAttributedString(string: text ?? "")
                text = nil
            }

            attributedString.addAttribute(.kern,
                                           value: newValue,
                                           range: NSRange(location: 0, length: attributedString.length))

            attributedText = attributedString
        }

        get {
            if let currentLetterSpace = attributedText?.attribute(.kern, at: 0, effectiveRange: .none) as? CGFloat {
                return currentLetterSpace
            } else {
                return 0
            }
        }
    }
}
