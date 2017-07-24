## cordova-plugin-alipay ##

Makes your Cordova application enable to use the [Alipay SDK](https://doc.open.alipay.com/docs/doc.htm?spm=a219a.7629140.0.0.hT44dE&treeId=54&articleId=104509&docType=1)
for mobile payment with Alipay App or Mobile Web. Requires cordova-android 4.0 or greater.

### ChangeLogs
  本cordova插件是基于支付宝App支付SDK的Demo实现，主要优化授权登录功能，APP支付功能暂没优化
 - 升级支付宝SDK版本到20170710；
 - 修改了一些bug;
 - 支持Android和iOS Alipay SDK
###主要功能

 - 主要功能是：服务器把订单信息签名后，调用该插件调用支付宝sdk进行支付，支付完成后如支付成功，如果是9000状态，还要去服务端去验证是否真正支付

### Install 安装

The following directions are for cordova-cli (most people).  

* Open an existing cordova project, with cordova-android 4.0.0+, and using the latest CLI. TBS X5  variables can be configured as an option when installing the plugin
* Add this plugin

  ```sh
  cordova plugin add https://github.com/smartecloud/cordova-plugin-alipay --variable PARTNER_ID=[你的商户PID可以在账户中查询]
  ```
  （对于android，可以不传PARTNER_ID）

   offline：下载后再进行安装 `cordova plugin add  YOUR_DIR`

### 支持平台

		Android IOS
		
    配置ios端：

	1.启动IDE（如Xcode），plugin下 libs的库，并导入到项目工程中。
	  AlipaySDK.bundle
	  AlipaySDK.framework
	  //libcrypto.a
	  //libssl.a

	2.将alipayUtil 文件夹放到plugin目录下，并在xcode中添加，记得选中group。即在xcode中显示为黄色文件夹

	3.点击项目名称，点击“Build Settings”选项卡，在搜索框中，以关键字“search”搜索，
	  对“Header Search Paths”增加头文件路径：$(SRCROOT)/项目名称，后面选择recursive 。
	  如果头文件信息已增加，可不必再增加。 （如果不添加，会报头文件找不到错误）

	4.点击项目名称，点击“Build Phases”选项卡，在“Link Binary with    Librarles”选项中，新增“AlipaySDK.framework”，“SystemConfiguration.framework”，    security.framework 系统库文件。
	  如果项目中已有这几个库文件，可不必再增加。(如果不添加，会报link arm64 等错误)

	5.配置url Scheme（点击项目名称，点击“Info”选项卡，在“URL Types”选项中，点击“+”，在“URL  Schemes”中输入“XXXXXX”。“XXXXXX”来自于文件Keys.h） （用于支付结束后的回调），需于代码中的Keys.h 中 urlSceheme一样
		
	6.appdelegate中添加  openURL方法里面
		if ([url.host isEqualToString:@"safepay"]) {
			
			[[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
				NSLog(@"result = %@",resultDic);
			}];
		}
		
	7.修改程序中
		PARTNER（合作身份者id）、
		SELLER（收款支付宝账号）、  
		RSA_PRIVATE（商户私钥）**如何生成商户私钥请自行查看支付宝官方文档。**
		
配置Android端：

	添加插件 cordova plugin add 插件目录路径
	修改Keys 中的PARTNER  SELLER  RSA_PRIVATE
	
	
最后：调用方法请参看插件目录下www/index.js 中的testAlipay方法

如果想删除插件，Android端的只需要运行cordova命令就可以了，ios端的除了运行cordova命令，还需要按照安装时的步奏，手动删除库、文件以及代码
	

### Android API

* js调用插件方法

```js

    //第一步：订单在服务端签名生成订单信息，具体请参考官网进行签名处理
    var payInfo  = "xxxx";

    //第二步：调用支付插件        	
    cordova.plugins.AliPay.pay(payInfo,function success(e){},function error(e){});

	 //e.resultStatus  状态代码  e.result  本次操作返回的结果数据 e.memo 提示信息
	 //e.resultStatus  9000  订单支付成功 ;8000 正在处理中  调用function success
	 //e.resultStatus  4000  订单支付失败 ;6001  用户中途取消 ;6002 网络连接出错  调用function error
	 //当e.resultStatus为9000时，请去服务端验证支付结果
	 			/**
				 * 同步返回的结果必须放置到服务端进行验证（验证的规则请看https://doc.open.alipay.com/doc2/
				 * detail.htm?spm=0.0.0.0.xdvAU6&treeId=59&articleId=103665&
				 * docType=1) 建议商户依赖异步通知
				 */

```
