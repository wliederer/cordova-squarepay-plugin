import PassKit
import SquareInAppPaymentsSDK
import UIKit
import PromiseKit


enum Result<T> {
    case success
    case failure(T)
    case canceled
}

class SquarePayViewController: UIViewController {
    var applePayAuthorizationResolver: Resolver<String>?

    override func loadView() {
        let squareView = SquareView()
        self.view = squareView
    }

    static func canUseApplePay()->Bool{ 
        return SQIPInAppPaymentsSDK.canUseApplePay
    }

    private var appleMerchantIdSet: Bool {
        return Constants.ApplePay.MERCHANT_IDENTIFIER != "REPLACE_ME"
    }
     
}

enum SquarePayError: Error {
    case authorizationFailed
    case customError(message: [String])
}

extension SquarePayViewController: PKPaymentAuthorizationViewControllerDelegate {
    func requestApplePayAuthorization(options: NSDictionary) -> Promise<String> {
        return Promise<String> { [weak self] resolver in 
            guard let strongSelf = self else {
                resolver.reject(SquarePayError.authorizationFailed)
                return
            }
            strongSelf.applePayAuthorizationResolver = resolver
       
        guard SQIPInAppPaymentsSDK.canUseApplePay else {
            strongSelf.applePayAuthorizationResolver?.reject(SquarePayError.authorizationFailed)
            return
        }
      
        print(options)
        guard let totalDict = options["_total"] as? NSDictionary,
        let label = totalDict["label"] as? String else {
            strongSelf.applePayAuthorizationResolver?.reject(SquarePayError.customError(message:["Invalid walletPaymentRequest()"]))
            return
        }

        guard appleMerchantIdSet else {
            strongSelf.applePayAuthorizationResolver?.reject(SquarePayError.customError(message:["apple merchantId not set"]))
            return
        }

        let paymentRequest = PKPaymentRequest.squarePaymentRequest(
            merchantIdentifier: Constants.ApplePay.MERCHANT_IDENTIFIER,
            countryCode: Constants.ApplePay.COUNTRY_CODE,
            currencyCode: Constants.ApplePay.CURRENCY_CODE
        )
        //TODO fix amount mapping
        paymentRequest.paymentSummaryItems = [
            PKPaymentSummaryItem(label: label, amount: 5.00)
        ]

        let paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
        paymentAuthorizationViewController!.delegate = self
        present(paymentAuthorizationViewController!, animated: true, completion: nil) 
        }
    }

    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController,
                                            didAuthorizePayment payment: PKPayment,
                                            handler completion: @escaping (PKPaymentAuthorizationResult) -> Void){

        // Nonce is used to actually charge the card on the server-side 
        let nonceRequest = SQIPApplePayNonceRequest(payment: payment)
        nonceRequest.perform { [weak self] cardDetails, error in
            guard let strongSelf = self else {
                completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
                return
            }     
            guard let cardDetails = cardDetails else {
                let errors = [error].compactMap { $0 }
                strongSelf.applePayAuthorizationResolver?.reject(SquarePayError.customError(message:["errors"]))
                completion(PKPaymentAuthorizationResult(status: .failure, errors: errors))
                return
            }
           
            strongSelf.applePayAuthorizationResolver?.fulfill(cardDetails.nonce)
            completion(PKPaymentAuthorizationResult(status: .success, errors: nil))       
        }
    }
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true) {
          
        }
    
    
    }
    

}
