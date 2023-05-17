import 'dart:convert';

void main(List<String> arguments) {
  var json =
      '{"Animals":[{"name":"Cat", "maxAge": 20, "color":"Black"}, {"name":"Dog", "maxAge": 15, "noise":"Bark"}]}';
  var jsonMap = jsonDecode(json);

  if (jsonMap is Map && jsonMap.length == 1) {
    print('Top level is a single item map');
    var key = jsonMap.keys.first;
    print('Top level object is $key');
    if (jsonMap[key] is List) {
      processList(jsonMap[key]);
    }
  }

  print('JSON to Dart class generator');
}

class VarInfo {
  Type type;
  bool optional;
  VarInfo({
    required this.type,
    required this.optional,
  });

  VarInfo copyWith({
    Type? type,
    bool? optional,
  }) {
    return VarInfo(
      type: type ?? this.type,
      optional: optional ?? this.optional,
    );
  }

  @override
  String toString() => 'VarInfo(type: $type, optional: $optional)';
}

void processList(List<dynamic> list) {
  print(list.first.runtimeType);
  var varInfos = <String, VarInfo>{};
  if (list.first is Map<String, dynamic>) {
    print('List of "Map<String,dynamic>" found');
    var firstItem = list.removeAt(0);
    for (var element in firstItem.entries) {
      varInfos[element.key] =
          VarInfo(type: element.value.runtimeType, optional: false);
    }
    print(varInfos);
    for (var item in list) {
      for (var varInfoKey in varInfos.keys) {
        if (!item.containsKey(varInfoKey)) {
          print('Making "$varInfoKey" optional');
          varInfos[varInfoKey] = varInfos[varInfoKey]!.copyWith(optional: true);
        }
      }
      for (var element in (item as Map<String, dynamic>).entries) {
        if (!varInfos.containsKey(element.key)) {
          print('New "${element.key}" optional param found');
          varInfos[element.key] =
              VarInfo(type: element.value.runtimeType, optional: true);
        }
      }
    }
    print(varInfos);
    for (var element in varInfos.entries) {
      print(
          '${element.value.type}${element.value.optional ? "?" : ""} ${element.key};');
    }
  } else if (list.first is dynamic) {
    print('List of "<dynamic>" found');
  } else {
    print('Unhadled tpye of lists');
  }
}
