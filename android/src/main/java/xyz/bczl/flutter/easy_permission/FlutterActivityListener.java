package xyz.bczl.flutter.easy_permission;

import android.content.Intent;
import android.util.Log;

import java.util.Arrays;

import io.flutter.plugin.common.PluginRegistry;
import pub.devrel.easypermissions.AppSettingsDialog;
import pub.devrel.easypermissions.EasyPermissions;

public class FlutterActivityListener implements PluginRegistry.ActivityResultListener, PluginRegistry.RequestPermissionsResultListener {

    private FlutterEasyPermissionPlugin.MyPermissionCallback mCallbacks;

    public void setPermissionCallbacks(FlutterEasyPermissionPlugin.MyPermissionCallback callbacks){
        mCallbacks = callbacks;
    }


    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        switch (requestCode) {
            case AppSettingsDialog.DEFAULT_SETTINGS_REQ_CODE:
                if (mCallbacks !=null) mCallbacks.onAppSettingsResult();
                return true;
            default:
                return false;
        }
    }

    @Override
    public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        EasyPermissions.onRequestPermissionsResult(requestCode, permissions, grantResults, mCallbacks);
        return true;
    }
}
