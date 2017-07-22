// var exec = require('cordova/exec');

// exports.pay = function (paymentInfo, successCallback, errorCallback) {   
// 		if(!paymentInfo){
// 			errorCallback && errorCallback("Please enter order information");  
// 		}else{
// 			exec(successCallback, errorCallback, "AliPay", "pay", [paymentInfo]);
// 		}
// };


var AliPay = function () { }

var exec = require('cordova/exec');
//   utils = require('cordova/utils'),
// var  cordova = require('cordova');

AliPay.prototype.isPlatformIOS = function () {
    return (device.platform === 'iPhone' ||
        device.platform === 'iPad' ||
        device.platform === 'iPod touch' ||
        device.platform === 'iOS')
}

AliPay.prototype.errorCallback = function (msg) {
    console.log('StartApp Callback Error: ' + msg)
}

AliPay.prototype.callNative = function (name, args, successCallback, errorCallback) {
    if (errorCallback) {
        cordova.exec(successCallback, errorCallback, 'AliPay', name, args)
    } else {
        cordova.exec(successCallback, this.errorCallback, 'AliPay', name, args)
    }
}

AliPay.prototype.auth = function (authInfo, successCallback, errorCallback) {
    console.log("authInfo->" + authInfo);
    this.callNative('auth', [authInfo], successCallback,errorCallback)
}

AliPay.prototype.pay = function (paymentInfo, successCallback, errorCallback) {
    console.log("paymentInfo->" + paymentInfo);
    this.callNative('pay', [paymentInfo], successCallback,errorCallback)
}

// exports.coolMethod = function(arg0, success, error) {
//     exec(success, error, "AliPay", "coolMethod", [arg0]);
// };


if (!window.plugins) {
  window.plugins = {}
}

if (!window.plugins.aliPay) {
  window.plugins.aliPay = new AliPay()
}

module.exports = new AliPay()

