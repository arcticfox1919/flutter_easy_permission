package xyz.bczl.flutter.easy_permission;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import pub.devrel.easypermissions.AppSettingsDialog;
import pub.devrel.easypermissions.EasyPermissions;

/**
 * FlutterEasyPermissionPlugin
 */
public class FlutterEasyPermissionPlugin implements FlutterPlugin,
        MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel mChannel;
    private Context mContext;
    private Activity mActivity;

    private MethodChannel mCallbackChannel;

    public static void registerWith(Registrar registrar) {
        final FlutterEasyPermissionPlugin instance = new FlutterEasyPermissionPlugin();
        instance.onAttachedToEngine(registrar.context(), registrar.messenger());
    }

    private void onAttachedToEngine(Context context, BinaryMessenger messenger) {
        mContext = context;
        mChannel = new MethodChannel(messenger, "xyz.bczl.flutter_easy_permission/permissions");
        mChannel.setMethodCallHandler(this);

        mCallbackChannel = new MethodChannel(messenger, "xyz.bczl.flutter_easy_permission/callback");
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        onAttachedToEngine(binding.getApplicationContext(), binding.getBinaryMessenger());
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        ArrayList<Integer> permsList = call.argument("perms");

        if (call.method.equals("hasPermissions")) {
            String[] perms = Permissions.getPermissionsArray(permsList);
            result.success(EasyPermissions.hasPermissions(mContext, perms));
        } else if (call.method.equals("requestPermissions")) {
            String rationale = call.argument("rationale");
            int requestCode = call.argument("requestCode");
            String[] perms = Permissions.getPermissionsArray(permsList);
            EasyPermissions.requestPermissions(mActivity, rationale, requestCode, perms);
            result.success(null);
        } else if (call.method.equals("showSettingsDialog")) {
            String title = call.argument("title");
            String rationale = call.argument("rationale");
            String positiveButtonText = call.argument("positiveButtonText");
            String negativeButtonText = call.argument("negativeButtonText");

          new AppSettingsDialog.Builder(mActivity)
                  .setTitle(title)
                  .setRationale(rationale)
                  .setPositiveButton(positiveButtonText)
                  .setNegativeButton(negativeButtonText)
                  .build().show();

            result.success(null);
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        mContext = null;
        mChannel.setMethodCallHandler(null);
        mChannel = null;

        mCallbackChannel = null;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        mActivity = binding.getActivity();
        FlutterActivityListener activityListener = new FlutterActivityListener();

        activityListener.setPermissionCallbacks(new MyPermissionCallback());
        binding.addActivityResultListener(activityListener);
        binding.addRequestPermissionsResultListener(activityListener);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        mActivity = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        onAttachedToActivity(binding);
    }

    @Override
    public void onDetachedFromActivity() {
        mActivity = null;
    }

    public class MyPermissionCallback implements EasyPermissions.PermissionCallbacks {

        @Override
        public void onPermissionsGranted(int requestCode, @NonNull List<String> perms) {
            if (mCallbackChannel != null) {
                HashMap<String, Object> arguments = new HashMap<>();
                arguments.put("requestCode", requestCode);
                arguments.put("perms", Permissions.getPermissionsIndex(perms));

                mCallbackChannel.invokeMethod("onGranted", arguments);
            }
        }

        @Override
        public void onPermissionsDenied(int requestCode, @NonNull List<String> perms) {
            if (mCallbackChannel != null) {
                HashMap<String, Object> arguments = new HashMap<>();
                arguments.put("requestCode", requestCode);
                arguments.put("perms", Permissions.getPermissionsIndex(perms));
                if (EasyPermissions.somePermissionPermanentlyDenied(mActivity, perms)) {
                    arguments.put("permanently", true);
                } else {
                    arguments.put("permanently", false);
                }
                mCallbackChannel.invokeMethod("onDenied", arguments);
            }
        }

        public void onAppSettingsResult() {
            Log.d("Permissions","onAppSettingsResult  ");
            if (mCallbackChannel != null) {
                mCallbackChannel.invokeMethod("onSettingsReturned", null);
            }
        }

        @Override
        public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {

        }
    }
}
