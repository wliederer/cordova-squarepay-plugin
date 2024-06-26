var exec = require('cordova/exec');

exports.echo = function (arg0, success, error) {
    exec(success, error, 'SquarePayPlugin', 'echo', [arg0]);
};
exports.echojs = function(arg0, success, error) {
    if (arg0 && typeof(arg0) === 'string' && arg0.length > 0) {
      success(arg0);
    } else {
      error('Empty message!');
    }
  };
exports.canUseApplePay = function(success,error) {
    exec(success,error,'SquarePayPlugin','canUseApplePay',[]);
}
exports.requestApplePayAuthorization = function (options) {
    return new Promise(function (resolve, reject) {
        cordova.exec(function (successResponse){
          resolve(successResponse)
        },function (errorResponse){
          reject(errorResponse)
        }, 'SquarePayPlugin', 'requestApplePayAuthorization', [options]);
    });
};