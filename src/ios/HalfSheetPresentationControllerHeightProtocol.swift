import UIKit

protocol HalfSheetPresentationControllerHeightProtocol: AnyObject {
    var halfsheetHeight: CGFloat { get }
}

class HalfSheetPresentationController: UIPresentationController {
    private lazy var dimmingView = makeDimmingView()

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView, let sheetHeight = (presentedViewController as? HalfSheetPresentationControllerHeightProtocol)?.halfsheetHeight else {
            return super.frameOfPresentedViewInContainerView
        }

        return CGRect(x: 0,
                      y: containerView.bounds.height - sheetHeight,
                      width: containerView.bounds.width,
                      height: sheetHeight)
    }

    override func presentationTransitionWillBegin() {
        containerView?.addSubview(dimmingView)
        dimmingView.frame = containerView!.bounds

        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] (context) in
            self?.dimmingView.alpha = 1.0
        }, completion: nil)
    }

    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] (context) in
            self?.dimmingView.alpha = 0.0
        }, completion: nil)
    }

    @objc func didTapBackground() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }

    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.roundCorners(corners: [.topLeft, .topRight], radius: 12)
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
}

extension HalfSheetPresentationController {
    private func makeDimmingView() -> UIView {
        let view = UIView()
        // view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        view.alpha = 0.0

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        view.addGestureRecognizer(tapGesture)

        return view
    }

}