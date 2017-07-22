package cordova.plugin.alipay;

import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

import com.alipay.sdk.app.AuthTask;
import com.alipay.sdk.app.PayTask;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.LOG;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Map;

import cordova.plugin.alipay.utils.OrderInfoUtil2_0;

public class AliPay extends CordovaPlugin {

    private static final int SDK_PAY_FLAG = 1;
    private static final int SDK_AUTH_FLAG = 0x123;
    private static String TAG = "AliPay";
    private CallbackContext callbackContext;

    /*参数暂时写在代码中，方便调试*/
    /**
     * 支付宝支付业务：入参app_id
     */
    public static final String APPID = "";


    /**
     * 支付宝账户登录授权业务：入参pid值
     */
    public static final String PID = "";
    /**
     * 支付宝账户登录授权业务：入参target_id值
     */
    public static final String TARGET_ID = "20170723xxxx";
    public static final String RSA2_PRIVATE ="";
    public static final String RSA_PRIVATE = "";

    private Handler mHandler = new Handler() {
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case SDK_PAY_FLAG: {
                    PayResult payResult = new PayResult((String) msg.obj);
                    /**
                     * 同步返回的结果必须放置到服务端进行验证（验证的规则请看https://doc.open.alipay.com/doc2/
                     * detail.htm?spm=0.0.0.0.xdvAU6&treeId=59&articleId=103665&
                     * docType=1) 建议商户依赖异步通知
                     */
                    String resultInfo = payResult.getResult();// 同步返回需要验证的信息

                    String resultStatus = payResult.getResultStatus();
                    if (TextUtils.equals(resultStatus, "9000")) {
                        Toast.makeText(cordova.getActivity(), "支付成功",
                                Toast.LENGTH_SHORT).show();
                    } else {

                        if (TextUtils.equals(resultStatus, "8000")) {
                            Toast.makeText(cordova.getActivity(), "支付结果确认中",
                                    Toast.LENGTH_SHORT).show();
                        } else {
                            Toast.makeText(cordova.getActivity(), "支付失败",
                                    Toast.LENGTH_SHORT).show();
                        }
                    }
                    break;
                }
                case SDK_AUTH_FLAG:

                    @SuppressWarnings("unchecked")
                    AuthResult authResult = new AuthResult((Map<String, String>) msg.obj, true);
                    String resultStatus = authResult.getResultStatus();

//                    sendUpdate(callbackContext,authResult.toJson(),true,PluginResult.Status.OK);

                    // 判断resultStatus 为“9000”且result_code
                    // 为“200”则代表授权成功，具体状态码代表含义可参考授权接口文档
                    if (TextUtils.equals(resultStatus, "9000") && TextUtils.equals(authResult.getResultCode(), "200")) {
                        // 获取alipay_open_id，调支付时作为参数extern_token 的value
                        // 传入，则支付账户为该授权账户
                        // Toast.makeText(cordova.getActivity(),"授权成功\n" + String.format("authCode:%s", authResult.getAuthCode()), Toast.LENGTH_SHORT).show();
                        Toast.makeText(cordova.getActivity(),"授权成功\n", Toast.LENGTH_SHORT).show();

                    } else {
                        // 其他状态值则为授权失败
                        Toast.makeText(cordova.getActivity(),"授权失败" + String.format("authCode:%s", authResult.getAuthCode()), Toast.LENGTH_SHORT).show();
                    }
                    break;

                default:
                    break;
            }
        }
    };

    @Override
    public boolean execute(String action, JSONArray args,
                           final CallbackContext callbackContext) throws JSONException {
        PluginResult result = null;

        this.callbackContext = callbackContext;

        if ("pay".equals(action)) {

            //订单信息在服务端签名后返回
            final String payInfo = args.getString(0);

            if (payInfo == null || payInfo.equals("") || payInfo.equals("null")) {
                callbackContext.error("Please enter order information");
                return true;
            }

            cordova.getThreadPool().execute(new Runnable() {
                @Override
                public void run() {
                    Log.i(TAG, " 构造PayTask 对象 ");
                    PayTask alipay = new PayTask(cordova.getActivity());
                    Log.i(TAG, " 调用支付接口，获取支付结果 ");
                    String result = alipay.pay(payInfo, true);

                    // 更新主ui的Toast
                    Message msg = new Message();
                    msg.what = SDK_PAY_FLAG;
                    msg.obj = result;
                    mHandler.sendMessage(msg);

                    PayResult payResult = new PayResult(result);
                    if (TextUtils.equals(payResult.getResultStatus(), "9000")) {
                        Log.i(TAG, " 9000则代表支付成功，具体状态码代表含义可参考接口文档 ");
                        callbackContext.success(payResult.toJson());
                    } else {
                        Log.i(TAG, " 为非9000则代表可能支付失败 ");
                        if (TextUtils.equals(payResult.getResultStatus(),
                                "8000")) {
                            Log.i(TAG,
                                    " 8000代表支付结果因为支付渠道原因或者系统原因还在等待支付结果确认，最终交易是否成功以服务端异步通知为准（小概率状态） ");
                            callbackContext.success(payResult.toJson());
                        } else {
                            Log.i(TAG, " 其他值就可以判断为支付失败，包括用户主动取消支付，或者系统返回的错误 ");
                            callbackContext.error(payResult.toJson());
                        }
                    }
                }
            });
            return true;
        } else if ("auth".equals(action)) {
            this.auth(args, callbackContext);

            return true;
        } else {
            callbackContext.error("no such method:" + action);
            return false;
        }
    }


    public void auth(JSONArray args, final CallbackContext callbackContext) {
        LOG.i(TAG, "native call ali qrcode methold");

        if (args == null || args.length() == 0) {
            callbackContext.error("args should not be null or empty");
            return;
        }

        try {
            Object params = args.get(0);
//
//            if (params instanceof String) {

            /**
             * 这里只是为了方便直接向商户展示支付宝的整个支付流程；所以Demo中加签过程直接放在客户端完成；
             * 真实App里，privateKey等数据严禁放在客户端，加签过程务必要放在服务端完成；
             * 防止商户私密数据泄露，造成不必要的资金损失，及面临各种安全风险；
             *
             * authInfo的获取必须来自服务端；
             */
            boolean rsa2 = (RSA2_PRIVATE.length() > 0);
            Map<String, String> authInfoMap = OrderInfoUtil2_0.buildAuthInfoMap(PID, APPID, TARGET_ID, rsa2);
            String info = OrderInfoUtil2_0.buildOrderParam(authInfoMap);


            String privateKey = rsa2 ? RSA2_PRIVATE : RSA_PRIVATE;
            String sign = OrderInfoUtil2_0.getSign(authInfoMap, privateKey, rsa2);
            final String authInfo = info + "&" + sign;

            final AuthResult _authResult = null;
            Runnable authRunnable = new Runnable() {
                @Override
                public void run() {
                    // 构造AuthTask 对象
                    AuthTask authTask = new AuthTask(cordova.getActivity());
                    // 调用授权接口，获取授权结果
                    Map<String, String> result = authTask.authV2(authInfo, true);

                    Message msg = new Message();
                    msg.what = SDK_AUTH_FLAG;
                    msg.obj = result;
                    mHandler.sendMessage(msg);

                    //handle auth result send to js
                    AuthResult authResult = new AuthResult(result, true);
                    String resultStatus = authResult.getResultStatus();

                    if (TextUtils.equals(resultStatus, "9000") && TextUtils.equals(authResult.getResultCode(), "200")) {
                        Log.i(TAG, " 判断resultStatus 为“9000”且result_code" + "为“200”则代表授权成功，具体状态码代表含义可参考授权接口文档 ");

//                        callbackContext.success(authResult.toJson());
                        sendUpdate(callbackContext,authResult.toJson(),true,PluginResult.Status.OK);

                    } else {
                        // 其他状态值则为授权失败
                        Log.i(TAG,
                                "其他状态值则为授权失败");
                        callbackContext.error(authResult.toJson());
                    }
                }
            };

            // 必须异步调用
            Thread authThread = new Thread(authRunnable);
            authThread.start();

//            }
        } catch (JSONException e) {
            callbackContext.error("JSONException: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private void sendUpdate(CallbackContext context, JSONObject obj, boolean keepCallback, PluginResult.Status status) {
        if (context != null) {
            PluginResult result = new PluginResult(status, obj);
            result.setKeepCallback(keepCallback);
            context.sendPluginResult(result);
            if (!keepCallback) {
                context = null;
            }
        }
    }


}
