import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mo_app_update/mo_app_update.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late MoAppUpdate _moAppUpdatePlugin;
  MoAppSelfUpdateInfoModel? updateInfoModel;
  bool get hasUpdate => updateInfoModel != null;

  Future<void> initPlatformState() async {
    _moAppUpdatePlugin = await MoAppUpdate.initialize(
      mode: MoAppUpdateMode.self,
      selfOption: MoAppUpdateSelfOption(
        infoUrl: 'https://minio.moberan.com/moappupdate/android/info.json',
      ),
    );

    updateInfoModel = await _moAppUpdatePlugin.getUpdateInfo();

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future showSimpleDialog({
    required String message,
    List<String> buttons = const ['OK'],
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Update',),
        actions: buttons.map((e) => TextButton(
          onPressed: (){
            Navigator.pop(context, e);
          },
          child: Text(e),
        )).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Update ${hasUpdate ? 'Exist' : 'Not Exist'}'),
            ElevatedButton(
              child: const Text('Check Update'),
              onPressed: () async {
                var info = await _moAppUpdatePlugin.getUpdateInfo();
                if(info == null) {
                  await showSimpleDialog(
                    message: 'No Update',
                    buttons: [
                      'OK',
                    ],
                  );
                  return;
                }

                var res = await showSimpleDialog(
                  message: 'Has Update',
                  buttons: [
                    'Ignore',
                    'Update',
                  ],
                );

                if(res != 'Update') {
                  return;
                }

                try{
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Dialog(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                  var res = await _moAppUpdatePlugin.procedureSelfUpdate(info);
                  Navigator.pop(context);
                }
                catch(e) {
                  showSimpleDialog(
                    message: e.toString(),
                    buttons: [
                      'OK',
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
