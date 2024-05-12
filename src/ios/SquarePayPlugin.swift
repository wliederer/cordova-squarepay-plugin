import PromiseKit


@objc(SquarePayPlugin) class SquarePayPlugin : CDVPlugin {
  @objc(echo:)
  func echo(command: CDVInvokedUrlCommand) {
    var pluginResult = CDVPluginResult(
      status: CDVCommandStatus_ERROR
    )

    let msg = command.arguments[0] as? String ?? ""

    if msg.characters.count > 0 {
      let toastController: UIAlertController =
        UIAlertController(
          title: "",
          message: msg,
          preferredStyle: .alert
        )

      self.viewController?.present(
        toastController,
        animated: true,
        completion: nil
      )

      DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        toastController.dismiss(
          animated: true,
          completion: nil
        )
      }

      pluginResult = CDVPluginResult(
        status: CDVCommandStatus_OK,
        messageAs: msg
      )
    }

    self.commandDelegate!.send(
      pluginResult,
      callbackId: command.callbackId
    )
  }

  @objc(canUseApplePay:)
  func canUseApplePay(command: CDVInvokedUrlCommand){
    var pluginResult = CDVPluginResult(
      status: CDVCommandStatus_ERROR
    )
    let msg = SquarePayViewController.canUseApplePay()
    pluginResult = CDVPluginResult(
        status: CDVCommandStatus_OK,
        messageAs: msg
      )
      self.commandDelegate!.send(
      pluginResult,
      callbackId: command.callbackId
    )
  }

  @objc(requestApplePayAuthorization:)
  func requestApplePayAuthorization(command: CDVInvokedUrlCommand){
    var pluginResult = CDVPluginResult(
      status: CDVCommandStatus_ERROR
    )

    DispatchQueue.main.async {
             guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                 return
             }
             guard let window = appDelegate.window else {
                 return
             }
    let squarePayViewController = SquarePayViewController()
    let nc = SquareNavigationController(rootViewController:squarePayViewController)
    nc.modalPresentationStyle = .custom
    nc.transitioningDelegate = squarePayViewController.self
    window.rootViewController?.present(nc,animated:true,completion:nil)

    let options = command.arguments[0] as! NSDictionary
    // Call requestApplePayAuthorization
    firstly {
      squarePayViewController.requestApplePayAuthorization(options: options)
    }.done { (cardDetails) in
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: cardDetails)
        self.commandDelegate?.send(pluginResult, callbackId: command.callbackId)
    }.catch { (error) in
    print(error)
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Apple Pay authorization failed")
        self.commandDelegate?.send(pluginResult, callbackId: command.callbackId)
    }
    
    }
}
}

