import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

var pairings = <Pairing>[];

void main(List<String> arguments) async {
  var json =
      '{"Animals":[{"name":"Cat", "maxAge": 20, "color":"Black"}, {"name":"Dog", "maxAge": 15, "noise":"Bark"}]}';

  // var uri = Uri.parse(
  //     'https://spark-preprod-gb.gnp.cloud.virgintvgo.virginmedia.com/eng/web/vod-service/v3/tiles-screen/scTi_c43eebf3-f148-44f2-b65c-95e068887e96~Kids~en?language=en&profileId=972338ff-e3fa-422e-a91e-df5c353f6194&maxRes=4K&excludeAdult=true&featureFlags=client_Mobile&entityVersion=1');
  var uri = Uri.parse(
      'https://spark-preprod-gb.gnp.cloud.virgintvgo.virginmedia.com/eng/web/vod-service/v3/tiles-screen/scTi_c43eebf3-f148-44f2-b65c-95e068887e96~Kids~en?language=en&maxRes=4K&excludeAdult=true&featureFlags=client_Mobile&entityVersion=1');

  var json2 = await http.read(uri);
  //print(json2);

  // Uri(
  //   scheme: 'https',
  //   host: 'spark-preprod-gb.gnp.cloud.virgintvgo.virginmedia.com',
  //   path:
  //       'eng/web/vod-service/v3/tiles-screen/scTi_c43eebf3-f148-44f2-b65c-95e068887e96~Kids~en',
  //   query:
  //       '?language=en&profileId=972338ff-e3fa-422e-a91e-df5c353f6194&maxRes=4K&excludeAdult=true&featureFlags=client_Mobile&entityVersion=1'));

  var jsonMap = jsonDecode(json2);

  processObject('Root', jsonMap);

  // if (jsonMap is Map<String, dynamic> && jsonMap.length == 1) {
  //   print('Top level is a single item map');
  //   var key = jsonMap.keys.first;
  //   print('Top level object is $key');
  //   if (jsonMap[key] is List) {
  //     var className =
  //         key.endsWith('s') ? key.substring(0, key.length - 1) : key;
  //     processList(className, jsonMap[key]);
  //   }
  // }

  print('JSON to Dart class generator');
  //print(pairings.join("\n"));
  var foundObjects = <String>{};
  for (var p in pairings) {
    var tokens = p.name.split('.');
    tokens.removeLast();
    foundObjects.add(tokens.join('.'));
  }
  print(foundObjects.join('\n'));
  print(
      '************************************************************************************************************************');
  for (var fo in foundObjects) {
    print('*******************************params for $fo');
    var foTokens = fo.split('.');
    // print(pairings
    //     .map((e) => e.name
    //         .replaceAll(fo, '')
    //         .split('')
    //         .where((element) => element == '.')
    //         .length)
    //     .join('\n'));
    var x = pairings
        .where((element) =>
            element.name.startsWith(fo) &&
            element.name
                    .replaceAll(fo, '')
                    .split('')
                    .where((element) => element == '.')
                    .length ==
                1)
        .toList();
    var y = <String, int>{};
    for (var element in x) {
      if (y.containsKey(element.name)) {
        y[element.name] = y[element.name]! + 1;
      } else {
        y[element.name] = 1;
      }
    }
    var maxCount = y.values.reduce((value, element) => max(value, element));
    for (var element in y.entries) {
      print(
          '${element.key} ${element.value == maxCount ? "required" : "optional"}');
    }
    //print(x.join('\n'));
  }
}

void processObject(String objectName, Map<String, dynamic> map) {
  for (var entry in map.entries) {
    if (entry.value is Map<String, dynamic>) {
      var name = createClassName(entry.key);
      name = name.replaceRange(0, 1, name.substring(0, 1).toUpperCase());
      var obj = '${objectName}.$name'.replaceAll(".", "");
      print('${objectName}.$name --> ${obj}');
      pairings.add(Pairing('${objectName}.$name', '${obj}'));
      processObject('${objectName}.$name', entry.value);
    } else if (entry.value is List) {
      var name = createClassName(entry.key);
      name = name.replaceRange(0, 1, name.substring(0, 1).toUpperCase());
      print('${objectName}.${entry.key} --> List<$objectName$name>');
      pairings
          .add(Pairing('${objectName}.${entry.key}', 'List<$objectName$name>'));
      processList('${objectName}.$name', entry.value);
    } else {
      print(
          '${objectName}.${entry.key} --> ${entry.value.runtimeType.toString()}');
      pairings.add(Pairing('${objectName}.${entry.key}',
          '${entry.value.runtimeType.toString()}'));
    }
  }
}

void processList(String listItemName, List<dynamic> list) {
  for (var item in list) {
    if (item is Map<String, dynamic>) {
      processObject(listItemName, item);
    } else if (item is List<dynamic>) {
      processList(listItemName, item);
    } else {
      print('$listItemName --> ${item.runtimeType.toString()}');
      pairings.add(Pairing('$listItemName', '${item.runtimeType.toString()}'));
    }
  }
}

class Pairing {
  String name;
  String what;
  Pairing(
    this.name,
    this.what,
  );

  @override
  String toString() => 'Pairing(name: $name, what: $what)';
}

class VarInfo {
  String type;
  bool optional;
  VarInfo({
    required this.type,
    required this.optional,
  });

  VarInfo copyWith({
    String? type,
    bool? optional,
  }) {
    return VarInfo(
      type: type ?? this.type,
      optional: optional ?? this.optional,
    );
  }

  @override
  String toString() => 'VarInfo(type: $type, optional: $optional)';

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'type': type});
    result.addAll({'optional': optional});

    return result;
  }

  factory VarInfo.fromMap(Map<String, dynamic> map) {
    return VarInfo(
      type: map['type'] ?? '',
      optional: map['optional'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory VarInfo.fromJson(String source) =>
      VarInfo.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VarInfo && other.type == type && other.optional == optional;
  }

  @override
  int get hashCode => type.hashCode ^ optional.hashCode;
}

// void processList(String className, List<dynamic> list) {
//   print(list.first.runtimeType);
//   var varInfos = <String, VarInfo>{};
//   if (list.first is Map<String, dynamic>) {
//     print('List of "Map<String,dynamic>" found');
//     var firstItem = list.removeAt(0) as Map<String, dynamic>;
//     for (var element in firstItem.entries) {
//       if (element.value is Map<String, dynamic>) {
//         var className = element.key.endsWith('s')
//             ? element.key.substring(0, element.key.length - 1)
//             : element.key;
//         processMap(className, element.value);
//       }
//       varInfos[element.key] =
//           VarInfo(type: element.value.runtimeType.toString(), optional: false);
//     }
//     print(varInfos);
//     for (var item in list) {
//       for (var varInfoKey in varInfos.keys) {
//         if (!item.containsKey(varInfoKey)) {
//           print('Making "$varInfoKey" optional');
//           varInfos[varInfoKey] = varInfos[varInfoKey]!.copyWith(optional: true);
//         }
//       }
//       for (var element in (item as Map<String, dynamic>).entries) {
//         if (!varInfos.containsKey(element.key)) {
//           print('New "${element.key}" optional param found');
//           varInfos[element.key] = VarInfo(
//               type: element.value.runtimeType.toString(), optional: true);
//         }
//       }
//     }
//     print(varInfos);
//     print('');
//     print("Class $className {");
//     for (var element in varInfos.entries) {
//       print(
//           '  ${element.value.type}${element.value.optional ? "?" : ""} ${element.key};');
//     }
//     print('}');
//     print('');
//   } else if (list.first is dynamic) {
//     print('List of "<dynamic>" found');
//   } else {
//     print('Unhadled tpye of lists');
//   }
// }

String createClassName(String string) {
  return string.endsWith('s') ? string.substring(0, string.length - 1) : string;
}

MapEntry<String, Map<String, VarInfo>> processMap(
    String className, Map<String, dynamic> map) {
  var params = <String, VarInfo>{};
  for (var element in map.entries) {
    if (element.value is Map<String, dynamic>) {
      var className = createClassName(element.key);
      var x = processMap(className, element.value);
      params[className] = VarInfo(type: x.key, optional: false);
    } else {
      params[element.key] =
          VarInfo(type: element.value.runtimeType.toString(), optional: false);
    }
  }
  return MapEntry(className, params);
}
