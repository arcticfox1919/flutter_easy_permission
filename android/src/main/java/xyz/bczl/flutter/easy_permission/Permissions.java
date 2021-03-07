package xyz.bczl.flutter.easy_permission;

import android.Manifest;

import java.util.ArrayList;
import java.util.List;

public class Permissions {

    private static final String[] permissionArray = {
            Manifest.permission.WRITE_CONTACTS,
            Manifest.permission.GET_ACCOUNTS,
            Manifest.permission.READ_CONTACTS,
            Manifest.permission.READ_CALL_LOG,
            Manifest.permission.READ_PHONE_STATE,
            Manifest.permission.CALL_PHONE,
            Manifest.permission.WRITE_CALL_LOG,
            Manifest.permission.USE_SIP,
            Manifest.permission.PROCESS_OUTGOING_CALLS,
            Manifest.permission.ADD_VOICEMAIL,
            Manifest.permission.READ_CALENDAR,
            Manifest.permission.WRITE_CALENDAR,
            Manifest.permission.CAMERA,
            Manifest.permission.BODY_SENSORS,
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.ACCESS_COARSE_LOCATION,
            Manifest.permission.READ_EXTERNAL_STORAGE,
            Manifest.permission.WRITE_EXTERNAL_STORAGE,
            Manifest.permission.RECORD_AUDIO,
            Manifest.permission.READ_SMS,
            Manifest.permission.RECEIVE_WAP_PUSH,
            Manifest.permission.RECEIVE_MMS,
            Manifest.permission.RECEIVE_SMS,
            Manifest.permission.SEND_SMS,
    };

    public static String[] getPermissionsArray(ArrayList<Integer> perms){
        int len = perms.size();
        String[] result = new String[len];

        for (int i = 0; i < len; i++) {
            int index = perms.get(i);
            result[i] = permissionArray[index];
        }
        return result;
    }


    public static ArrayList<Integer> getPermissionsIndex(List<String> perms){
        ArrayList<Integer> result = new ArrayList<>();
        for (String val : perms){
            for (int i = 0; i < permissionArray.length; i++) {
                if (permissionArray[i].equals(val)){
                    result.add(i);
                    break;
                }
            }
        }
        return result;
    }
}
