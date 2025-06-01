import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_model_converter/app/generators/generator.dart';
import 'package:dart_model_converter/app/providers/config_provider.dart';
import 'package:dart_style/dart_style.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/dart.dart';
import 'package:re_highlight/styles/atom-one-dark.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';
import 'package:url_launcher/url_launcher_string.dart';

enum CodeType { freezed, jsonSerializable }

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  late CodeLineEditingController inputController;
  late CodeLineEditingController outputController;

  CodeEditorStyle style = CodeEditorStyle(
    fontSize: 16,
    codeTheme: CodeHighlightTheme(
      theme: atomOneDarkTheme,
      languages: {'dart': CodeHighlightThemeMode(mode: langDart)},
    ),
  );

  @override
  void initState() {
    super.initState();

    const input = '''
class Welcome {
    final String greeting;
    final List<String> instructions;

    Welcome({
        required this.greeting,
        required this.instructions,
    });

    factory Welcome.fromJson(Map<String, dynamic> json) => Welcome(
        greeting: json["greeting"],
        instructions: List<String>.from(json["instructions"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "greeting": greeting,
        "instructions": List<dynamic>.from(instructions.map((x) => x)),
    };
}
''';

    inputController = CodeLineEditingController.fromText(input);
    outputController = CodeLineEditingController.fromText(input);

    convert();
  }

  @override
  void dispose() {
    inputController.dispose();
    outputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(configProviderProvider, (previous, next) => convert());

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;
        final minSize =
            (isMobile ? constraints.maxHeight : constraints.maxWidth) / 2.5;

        return Scaffold(
          backgroundColor: Color(0xFF282C34),
          headers: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dart Model Converter',
                    style: isMobile
                        ? context.theme.typography.semiBold
                        : context.theme.typography.h4,
                  ),
                  Row(
                    spacing: isMobile ? 2 : 20,
                    children: [
                      GhostButton(
                        onPressed: onFormatCodeTap,
                        density: ButtonDensity.dense,
                        leading: isMobile
                            ? null
                            : Icon(RadixIcons.textAlignCenter),
                        child: Text('Format Code'),
                      ),
                      GhostButton(
                        onPressed: onOpenOnGithubTap,
                        density: ButtonDensity.dense,
                        leading: isMobile ? null : Icon(BootstrapIcons.github),
                        child: Text('Open on Github'),
                      ),
                      Builder(
                        builder: (context) {
                          return GhostButton(
                            density: ButtonDensity.dense,
                            onPressed: () => onOptionTap(context),
                            leading: isMobile
                                ? null
                                : Icon(RadixIcons.hamburgerMenu),
                            child: Text('Options'),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          child: ResizablePanel(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            children: [
              ResizablePane.flex(
                minSize: minSize,
                child: CodeEditor(
                  style: style,
                  padding: EdgeInsets.all(20),
                  controller: inputController,
                  onChanged: (_) => convert(),
                ),
              ),
              ResizablePane.flex(
                minSize: minSize,
                child: CodeEditor(
                  style: style,
                  readOnly: true,
                  padding: EdgeInsets.all(20),
                  showCursorWhenReadOnly: false,
                  controller: outputController,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void convert() {
    final emitter = DartEmitter();

    final result = parseString(content: inputController.text.trim());
    final unit = result.unit;

    final optionalParameters = <Parameter>[];
    final requiredParameters = <Parameter>[];

    final parameters = <String, String>{};

    for (final declaration in unit.declarations) {
      if (declaration is ClassDeclaration) {
        for (final member in declaration.members) {
          if (member is FieldDeclaration) {
            for (final variable in member.fields.variables) {
              final name = variable.name;
              final type = member.fields.type;

              parameters['$name'] = '$type';
            }
          }

          if (member is ConstructorDeclaration) {
            for (final param in member.parameters.parameters) {
              final name = '${param.name}';

              if (!parameters.containsKey(name)) continue;

              String? defaultValue;

              if (param is DefaultFormalParameter) {
                defaultValue = param.defaultValue?.toSource();
              }

              final parameter = Parameter(
                (b) => b
                  ..name = name
                  ..named = param.isNamed
                  ..type = Reference(parameters[name])
                  ..required = param.isRequiredNamed
                  ..defaultTo = defaultValue == null
                      ? null
                      : Code(defaultValue),
              );

              if (param.isNamed) {
                optionalParameters.add(parameter);
              } else {
                requiredParameters.add(parameter);
              }
            }
          }
        }

        final generator = Generator(
          name: '${declaration.name}',
          optionalParameters: optionalParameters,
          requiredParameters: requiredParameters,
          type: ref.read(configProviderProvider).type,
        ).gen();

        final formatter = DartFormatter(
          languageVersion: DartFormatter.latestLanguageVersion,
        );

        outputController.text = formatter.format(
          '${generator.accept(emitter)}',
        );
        setState(() {});
      }
    }
  }

  void onFormatCodeTap() {
    final formatter = DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion,
    );
    final formattedCode = formatter.format(inputController.text.trim());
    inputController.text = formattedCode;
    setState(() {});
  }

  void onOptionTap(BuildContext context) {
    showDropdown<void>(
      context: context,
      builder: (context) {
        return DropdownMenu(
          children: [
            MenuRadioGroup(
              value: ref.read(configProviderProvider).type,
              onChanged: (context, value) {
                ref.read(configProviderProvider.notifier).type(value);
              },
              children: CodeType.values.map((e) {
                return MenuRadio(value: e, child: Text(e.name));
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  void onOpenOnGithubTap() {
    launchUrlString('https://github.com/thitlwincoder/dart_model_converter');
  }
}
