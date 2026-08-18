import 'package:analyzer/dart/ast/ast.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_model_converter/app/parsers/parser.dart';

typedef FieldDefaultValueBuilder =
    String? Function(
      VariableDeclaration variable,
    );

class ParseFieldData {
  ParseFieldData({required this.name, required this.type, this.defaultValue});

  final String name;
  final String type;
  final String? defaultValue;
}

abstract class ParserBase {
  List<ParseData> parse(CompilationUnit unit);

  List<ParseData> parseClassesByDefaultConstructor(CompilationUnit unit) {
    return unit.declarations.whereType<ClassDeclaration>().map((declaration) {
      final optionalParameters = <Parameter>[];
      final requiredParameters = <Parameter>[];
      final fieldTypesByName = parseFields(declaration);

      for (final constructor
          in declaration.members.whereType<ConstructorDeclaration>()) {
        if (constructor.name != null) continue;

        for (final param in constructor.parameters.parameters) {
          final name = '${param.name}';
          final parameter = parseParameter(
            name: name,
            param: param,
            type: fieldTypesByName[name],
            defaultValue: getDefaultValue(param),
          );

          if (param.isNamed) {
            optionalParameters.add(parameter);
          } else {
            requiredParameters.add(parameter);
          }
        }
      }

      return ParseData(
        name: '${declaration.name}',
        optionalParameters: optionalParameters,
        requiredParameters: requiredParameters,
      );
    }).toList();
  }

  List<ParseData> parseClassesByFields(
    CompilationUnit unit, {
    String Function(ClassDeclaration declaration)? className,
    FieldDefaultValueBuilder? defaultValue,
  }) {
    return unit.declarations.whereType<ClassDeclaration>().map((declaration) {
      return ParseData(
        requiredParameters: [],
        name: className?.call(declaration) ?? '${declaration.name}',
        optionalParameters: parseParametersByFields(
          declaration,
          defaultValue: defaultValue,
        ),
      );
    }).toList();
  }

  String? getDefaultValue(FormalParameter param) {
    if (param is DefaultFormalParameter) {
      return param.defaultValue?.toSource();
    }

    return null;
  }

  Map<String, String> parseFields(ClassDeclaration declaration) {
    final parameters = <String, String>{};
    final fields = declaration.members.whereType<FieldDeclaration>();

    for (final member in fields) {
      for (final variable in member.fields.variables) {
        parameters['${variable.name}'] = '${member.fields.type}';
      }
    }

    return parameters;
  }

  List<Parameter> parseParametersByFields(
    ClassDeclaration declaration, {
    FieldDefaultValueBuilder? defaultValue,
  }) {
    final parameters = <Parameter>[];
    final fields = declaration.members.whereType<FieldDeclaration>();

    for (final member in fields) {
      for (final variable in member.fields.variables) {
        final name = variable.name;
        final type = member.fields.type;

        parameters.add(
          parseParameter(
            name: '$name',
            type: '$type',
            defaultValue: defaultValue?.call(variable),
          ),
        );
      }
    }

    return parameters;
  }

  Parameter parseParameter({
    required String name,
    required String? type,
    FormalParameter? param,
    String? defaultValue,
  }) => Parameter((b) {
    b
      ..name = name
      ..type = Reference(type)
      ..named = param?.isNamed ?? true;

    if (defaultValue == null) {
      b.required = param?.isRequiredNamed ?? true;
    } else {
      b.defaultTo = Code(defaultValue);
    }
  });
}
