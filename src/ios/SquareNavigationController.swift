import UIKit

class SquareNavigationController : UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarHidden(true, animated: false)
    }
}

extension SquareNavigationController: HalfSheetPresentationControllerHeightProtocol {
    var halfsheetHeight: CGFloat {
        return ((viewControllers.last as? HalfSheetPresentationControllerHeightProtocol)?.halfsheetHeight ?? 0.0) + navigationBar.bounds.height
    }
}
