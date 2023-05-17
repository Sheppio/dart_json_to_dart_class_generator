import 'dart:convert';

void main(List<String> arguments) {
  var json =
      '{"Animals":[{"name":"Cat", "maxAge": 20, "color":"Black"}, {"name":"Dog", "maxAge": 15, "noise":"Bark"}]}';
  var jsonMap = jsonDecode(json);

  if (jsonMap is Map<String, dynamic> && jsonMap.length == 1) {
    print('Top level is a single item map');
    var key = jsonMap.keys.first;
    print('Top level object is $key');
    if (jsonMap[key] is List) {
      var className =
          key.endsWith('s') ? key.substring(0, key.length - 1) : key;
      processList(className, jsonMap[key]);
    }
  }

  print('JSON to Dart class generator');
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

void processList(String className, List<dynamic> list) {
  print(list.first.runtimeType);
  var varInfos = <String, VarInfo>{};
  if (list.first is Map<String, dynamic>) {
    print('List of "Map<String,dynamic>" found');
    var firstItem = list.removeAt(0) as Map<String, dynamic>;
    for (var element in firstItem.entries) {
      if (element.value is Map<String, dynamic>) {
        var className = element.key.endsWith('s')
            ? element.key.substring(0, element.key.length - 1)
            : element.key;
        processMap(className, element.value);
      }
      varInfos[element.key] =
          VarInfo(type: element.value.runtimeType.toString(), optional: false);
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
          varInfos[element.key] = VarInfo(
              type: element.value.runtimeType.toString(), optional: true);
        }
      }
    }
    print(varInfos);
    print('');
    print("Class $className {");
    for (var element in varInfos.entries) {
      print(
          '  ${element.value.type}${element.value.optional ? "?" : ""} ${element.key};');
    }
    print('}');
    print('');
  } else if (list.first is dynamic) {
    print('List of "<dynamic>" found');
  } else {
    print('Unhadled tpye of lists');
  }
}

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
