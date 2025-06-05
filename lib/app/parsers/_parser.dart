part of 'parser.dart';

class _Parser implements Parser {
  _Parser(this.type);

  final CodeType type;

  @override
  List<ParseData> parse(CompilationUnit unit) {
    final parser = switch (type) {
      CodeType.normal => NormalParser(),
      CodeType.freezed => FreezedParser(),
      CodeType.jsonSerializable => JsonSerializableParser(),
      CodeType.hive => HiveParser(),
      CodeType.objectbox => ObjectBoxParser(),
      CodeType.floor => FloorParser(),
    };

    return parser.parse(unit);
  }
}
