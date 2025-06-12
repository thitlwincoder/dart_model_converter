import 'package:dart_model_converter/app/code_type.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'config_provider.g.dart';

@Riverpod(keepAlive: true)
class ConfigProvider extends _$ConfigProvider {
  @override
  Config build() => Config();

  void type(CodeType type) {
    state.type = type;
    ref.notifyListeners();
  }
}

class Config {
  Config({this.type = CodeType.realm});

  CodeType type;
}
