#import "AlipayPlugin.h"
#import <AlipaySDK/AlipaySDK.h>
#import "APAuthV2Info.h"
#import "RSADataSigner.h"


@implementation AlipayPlugin

-(void)pluginInitialize{
    CDVViewController *viewController = (CDVViewController *)self.viewController;
    self.partner = [viewController.settings objectForKey:@"partner"];
}

- (void) pay:(CDVInvokedUrlCommand*)command
{
    self.currentCallbackId = command.callbackId;
    //partner和seller获取失败,提示
    if ([self.partner length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少partner。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }

    //从API请求获取支付信息
    NSString *signedString = [command argumentAtIndex:0];

    if (signedString != nil) {

        [[AlipaySDK defaultService] payOrder:signedString fromScheme:[NSString stringWithFormat:@"a%@", self.partner] callback:^(NSDictionary *resultDic) {
            if ([[resultDic objectForKey:@"resultStatus"]  isEqual: @"9000"]) {
                [self successWithCallbackID:self.currentCallbackId messageAsDictionary:resultDic];
            } else {
                [self failWithCallbackID:self.currentCallbackId messageAsDictionary:resultDic];
            }
            
            NSLog(@"reslut = %@",resultDic);
        }];

    }
}




#pragma mark -
#pragma mark   ==============点击模拟授权行为==============

- (void) auth:(CDVInvokedUrlCommand*)command
{
    //重要说明
    //这里只是为了方便直接向商户展示支付宝的整个支付流程；所以Demo中加签过程直接放在客户端完成；
    //真实App里，privateKey等数据严禁放在客户端，加签过程务必要放在服务端完成；
    //防止商户私密数据泄露，造成不必要的资金损失，及面临各种安全风险；
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/

    self.currentCallbackId = command.callbackId;
    //partner和seller获取失败,提示
//    if ([self.partner length] == 0)
//    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
//                                                        message:@"缺少partner。"
//                                                       delegate:self
//                                              cancelButtonTitle:@"确定"
//                                              otherButtonTitles:nil];
//        [alert show];
//        return;
//    }

    //从API请求获取支付信息
//    NSString *signedString = [command argumentAtIndex:0];

    //    NSString *pid = @"";
    //    NSString *appID = @"";

    NSString *pid = @"2088911122813842";
    NSString *appID = @"2017032706431886";//会引擎
    //    NSString *appID = @"2017072207848552"; //销售会


    // 如下私钥，rsa2PrivateKey 或者 rsaPrivateKey 只需要填入一个
    // 如果商户两个都设置了，优先使用 rsa2PrivateKey
    // rsa2PrivateKey 可以保证商户交易在更加安全的环境下进行，建议使用 rsa2PrivateKey
    // 获取 rsa2PrivateKey，建议使用支付宝提供的公私钥生成工具生成，
    // 工具地址：https://doc.open.alipay.com/docs/doc.htm?treeId=291&articleId=106097&docType=1
    //    NSString *rsa2PrivateKey = @"";
    NSString *rsa2PrivateKey =  @"MIIEugIBADANBgkqhkiG9w0BAQEFAASCBKQwggSgAgEAAoIBAQCyO/SYt3rCt9JEOnuavxaNc5vJOvCS+f8BBeGR/DNy5lrx1Ueg1TFTjYXJXsmB6sy5vhzMFckXYMwxL7E4CUkUjXPWHKgUQMFJtM7BI9BZrr+x2yQsbwCaxSpBxCGscRsJBKYsBaZkocnkZSfrYNwtbCjYdY+YI7TpLwz4z9BFkO9WkOTxTg8BLkTqbJLsbSxCOv8lD3GOeLfWgqd+nM5tXv9WKS4NGSuiMsQe0Jpdh7BATcKuNKbuFKjGYS533HD4JJls8XEtkelgLWwtzzjMNCVE0cfuh+sP9xwbkhQd8Van175pzItDFYRS2pR0ry8b9gkfmGt3eKB91Q4NivsXAgMBAAECggEAQnFFUnT7p4D9OoAOufZIQvz480AslK3rWQdHOrOovkmPV52pcRRoqfwVBqd2OR89qHRtqcrpRvTHygI8b2ZOvwGoUAYoxjwJkh97/9YJApW5UmUeDA5pTEj54sBpyS305Ry9kaWdjOAfMixfgEiAa9JpO6A/oniVJWRr0okt2/B3Wfg++XR3YdQgRcikuyX+qckyI37VhkWn8FoFtD1y2e0cwVKeyzVDrLkNVCiP0cW3rGScOboZzVFrVMtazbCgsgMsnOehP/qEbR4bSQkjeBSyd/ftEm3Wy1WhEE5k1EasnnO6z/1v4fMkpGt1IQGFP6AgMwA/cDITCuzAxta8mQKBgQDdp/TvMuRZXR9VWPYAFLXZOsiZ8G1Ma1erTRSA6IBzmMraK71al7TECSb+j57VtENsMlt/MpPQCbBzPaY/9mDSJgohOTsACpbT8G/qwJObTUT6J+wSLHT8dFhdV0UJgRDFRz5d2VHaHPNwqKufAB/VciMUdRMyf9m27NocaVesywKBgQDN2ai5K7hMx43cV1RTEp5bJve2xf3Ezq5ZZX/8Cnu39ZNqPu8kJ7xJ/Fp+/rfXOb+6rijUQA39Ai3x1z+yxyZdBQJfeNDV7EELXCktplC0AFeEl5tVT3NfrfFKYgS0/xuYJSan6lRnqMSnpYep+VDNLT3JKHeYjCMzaIOzqliNZQJ/I3/CuoxsBePkIMcenuSyOxgvCHh5CMQoRkcSAZM6/0h5NHfM27VwPfU5SYu25IL6SVnHTZfMFIV4vPwipBvRZdaxyKBh0p/fiBH52p79BOJbKbU7Ga4FDmmTvV88r0j8ZpwCYQVtFoGMe36H/e8HKigddilJ6cyQEbvdMq+sWwKBgFN7G/PMiTeKDjv3ppjyCgqJaRhUfy/badWTVi4OylG2ZAxIbY9KFhAjKUgrYL8GCn1Yt/Ir8ABVa/CSDKEiJqq+p1G0m2zGHTLQM1ryAfSd1uBM44/bYrzAvAQgcCw+8R/ooR6j54sKZIZgmP4Tv/MVj+MOaEITQwtMLW0lfjgJAoGAJQUnnipAd4j6w9wN4z5T2822LpP9vZvCJkLm8IR6Jl7KcrGRkHw+z3VRBa54wyGxxhTRv50irqbcoqtf/ovL9dChoqIJTChf8RZUiz+ZZYiabuwg6M5BVC9O0JAJds1VnStU3gC6gvNpDwaAvHVJoHoxB0DNbT1dyBKT7In+5KA=";
    NSString *rsaPrivateKey = @"";
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/

    //pid和appID获取失败,提示
    if ([pid length] == 0 ||
        [appID length] == 0 ||
        ([rsa2PrivateKey length] == 0 && [rsaPrivateKey length] == 0))
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少pid或者appID或者私钥。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }

    //生成 auth info 对象
    APAuthV2Info *authInfo = [APAuthV2Info new];
    authInfo.pid = pid;
    authInfo.appID = appID;

    //auth type
    NSString *authType = [[NSUserDefaults standardUserDefaults] objectForKey:@"authType"];
    if (authType) {
        authInfo.authType = authType;
    }

    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"a2088911122813842";

    // 将授权信息拼接成字符串
    NSString *authInfoStr = [authInfo description];
    NSLog(@"authInfoStr = %@",authInfoStr);

    // 获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    NSString *signedString = nil;
    RSADataSigner* signer = [[RSADataSigner alloc] initWithPrivateKey:((rsa2PrivateKey.length > 1)?rsa2PrivateKey:rsaPrivateKey)];
    if ((rsa2PrivateKey.length > 1)) {
        signedString = [signer signString:authInfoStr withRSA2:YES];
    } else {
        signedString = [signer signString:authInfoStr withRSA2:NO];
    }

    // 将签名成功字符串格式化为订单字符串,请严格按照该格式
    if (signedString.length > 0) {
        authInfoStr = [NSString stringWithFormat:@"%@&sign=%@&sign_type=%@", authInfoStr, signedString, ((rsa2PrivateKey.length > 1)?@"RSA2":@"RSA")];
        [[AlipaySDK defaultService] auth_V2WithInfo:authInfoStr
                                         fromScheme:appScheme
                                           callback:^(NSDictionary *resultDic) {
                                               NSLog(@"result = %@",resultDic);
                                               // 解析 auth code
                                               NSString *result = resultDic[@"result"];
                                               NSString *authCode = nil;
                                               if (result.length>0) {
                                                   NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                                                   for (NSString *subResult in resultArr) {
                                                       if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                                                           authCode = [subResult substringFromIndex:10];
                                                           break;
                                                       }
                                                   }
                                               }
                                               NSLog(@"授权结果 authCode = %@", authCode?:@"");

                                               if ([[resultDic objectForKey:@"resultStatus"]  isEqual: @"9000"]) {
                                                   [self successWithCallbackID:self.currentCallbackId messageAsDictionary:resultDic];
                                               } else {
                                                   [self failWithCallbackID:self.currentCallbackId messageAsDictionary:resultDic];
                                               }
                                           }];
    }
}



- (void)handleOpenURL:(NSNotification *)notification
{
    NSURL* url = [notification object];
    
    if ([url isKindOfClass:[NSURL class]] && [url.scheme isEqualToString:[NSString stringWithFormat:@"a%@", self.partner]])
    {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            if ([[resultDic objectForKey:@"resultStatus"]  isEqual: @"9000"]) {
                [self successWithCallbackID:self.currentCallbackId messageAsDictionary:resultDic];
            } else {
                [self failWithCallbackID:self.currentCallbackId messageAsDictionary:resultDic];
            }
        }];
    }
}

- (void)successWithCallbackID:(NSString *)callbackID withMessage:(NSString *)message
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
    [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
}

- (void)failWithCallbackID:(NSString *)callbackID withMessage:(NSString *)message
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message];
    [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
}
- (void)successWithCallbackID:(NSString *)callbackID messageAsDictionary:(NSDictionary *)message
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:message];
    [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
}

- (void)failWithCallbackID:(NSString *)callbackID messageAsDictionary:(NSDictionary *)message
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:message];
    [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
}

@end
