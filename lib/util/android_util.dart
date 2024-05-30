
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:install_plugin/install_plugin.dart';
import 'package:path_provider/path_provider.dart';

class AndroidUtil {
  static Future<String> downloadApk(String url, String? fileName) async {
    Completer<String> completer = Completer();

    var httpClient = http.Client();
    var request = http.Request('GET', Uri.parse(url));
    var response = httpClient.send(request);

    String dir = (await getTemporaryDirectory()).path;

    List<List<int>> chunks = List.empty(growable: true);

    response.asStream().listen((http.StreamedResponse r) {
      r.stream.listen((List<int> chunk) {
        chunks.add(chunk);
      },
          onError: (err, trace) {
            completer.completeError(err);
          },
          onDone: () async {
            var path = '$dir/${fileName ?? 'update'}.apk';
            File file = File(path);
            if(await file.exists()) {
              await file.delete();
            }
            final Uint8List bytes = Uint8List(r.contentLength!);
            int offset = 0;
            for (List<int> chunk in chunks) {
              bytes.setRange(offset, offset + chunk.length, chunk);
              offset += chunk.length;
            }
            await file.writeAsBytes(bytes);
            completer.complete(path);
          });
    });

    return completer.future;
  }

  static Future installApk(String path) async {
      return InstallPlugin.install(path);
  }
}