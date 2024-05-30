# mo_app_update

Easy App Update Checker by Moberan

## Getting Started


### Android-Self Update

1. Add `info.json` and `apks` to public domain  
    
    Check this [`info.json`](https://github.com/MoberanCompany/flutter_mo_app_update/blob/main/example/info.json) link or below.
    
    ```json
    {
        "android": {
            "2": {
                "downloadUrl": "https://some.apk",
                "versionString": "0.0.2",
                "priority": "2",
                "changelog": {
                "ko-kr": "테스트",
                "en-us": "Test"
                }
            },
            "1": {
                "downloadUrl": "...",
                "versionString": "0.0.1",
                "priority": "0",
                "changelog": {
                "ko-kr": "최초 버전",
                "en-us": "Init version"
                }
            }
        }
    }

    ```


2. Add in dependency

    ```shell
    flutter pub add mo_app_update
    ```

3. Check below for flutter code

    ```dart
    var moAppUpdatePlugin = await MoAppUpdate.initialize(
        mode: MoAppUpdateMode.self,
        selfOption: MoAppUpdateSelfOption(
            infoUrl: 'https://minio.moberan.com/moappupdate/android/info.json',
        ),
    );

    var info = await moAppUpdatePlugin.getUpdateInfo();
    if(info != null) {
        var res = await moAppUpdatePlugin.procedureUpdate(info);
    }
    ```


## Road map

* [ ] Android Store Update
* [ ] iOS Store Update
* [x] Android Self Update (APK)
* [ ] iOS Self Update (Enterprise)
