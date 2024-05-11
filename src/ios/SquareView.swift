import UIKit

class SquareView : UIView {
     override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
     required init?(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
         commonInit()
     }
    
    private func commonInit() {
        backgroundColor = UIColor.clear
    }
}
