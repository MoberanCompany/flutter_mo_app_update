
import 'dart:convert';

class JsonUtil {

  static dynamic tryParse(dynamic str) {
    try {
      return jsonDecode(str);
    }
    catch(e) {
      return str;
    }
  }

  static Map<dynamic, dynamic> tryParseObject(dynamic str) {
    try {
      return jsonDecode(str);
    }
    catch(e) {
      return str;
    }
  }

  static List<dynamic> tryParseList(dynamic str) {
    try {
      return jsonDecode(str) as List;
    }
    catch(e) {
      return str;
    }
  }
}