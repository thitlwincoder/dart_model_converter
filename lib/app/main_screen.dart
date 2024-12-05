import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_model_converter/app/generators/generator.dart';
import 'package:dart_style/dart_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart' hide Code;
import 'package:flutter_highlight/themes/atom-one-dark-reasonable.dart';
import 'package:highlight/languages/dart.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:url_launcher/url_launcher_string.dart';

enum CodeType { freezed, jsonSerializable }

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late CodeController controller;
  late CodeController outputController;

  bool isWrap = false;
  bool showOption = false;
  CodeType type = CodeType.freezed;

  String input = '';

  @override
  void initState() {
    super.initState();
    controller = CodeController(
      language: dart,
      text: '''
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
''',
    );
    outputController = CodeController(language: dart);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        centerTitle: false,
        title: Text('Dart Model Converter'),
        titleTextStyle: Theme.of(context)
            .typography
            .dense
            .titleMedium
            ?.copyWith(color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          CupertinoButton(
            onPressed: () {
              launchUrlString(
                'https://github.com/thitlwincoder/dart_model_converter',
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  TablerIcons.brand_github,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 4),
                Text(
                  'Open on Github',
                  style: Theme.of(context)
                      .typography
                      .dense
                      .bodyMedium
                      ?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          CupertinoButton(
            onPressed: () {
              showOption = !showOption;
              setState(() {});
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  showOption ? TablerIcons.eye_off : TablerIcons.eye,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 4),
                Text(
                  'Options',
                  style: Theme.of(context)
                      .typography
                      .dense
                      .bodyMedium
                      ?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Color.fromARGB(255, 21, 54, 79),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Flex(
                  direction: constraints.maxWidth < 800
                      ? Axis.vertical
                      : Axis.horizontal,
                  children: [
                    SizedBox(
                      width: constraints.maxWidth < 800 ? null : 500,
                      height: constraints.maxWidth < 800 ? 240 : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          OutlinedButton(
                            onPressed: onFormatCode,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: Colors.white),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: Text('Format Code'),
                          ),
                          SizedBox(height: 10),
                          Expanded(
                            child: CodeTheme(
                              data: CodeThemeData(
                                styles: atomOneDarkReasonableTheme,
                              ),
                              child: CodeField(
                                wrap: isWrap,
                                onChanged: onChanged,
                                expands: true,
                                controller: controller,
                                cursorColor: Colors.orange,
                                gutterStyle: GutterStyle(
                                  margin: 0,
                                  showLineNumbers: false,
                                  showFoldingHandles: false,
                                ),
                                background:
                                    const Color.fromARGB(255, 19, 41, 59),
                                textStyle: Theme.of(context)
                                    .typography
                                    .white
                                    .bodySmall,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (constraints.maxWidth < 800)
                      SizedBox(height: 10)
                    else
                      SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        width: constraints.maxWidth < 800 ? null : 500,
                        height: constraints.maxWidth < 800 ? 240 : null,
                        child: CodeTheme(
                          data:
                              CodeThemeData(styles: atomOneDarkReasonableTheme),
                          child: CodeField(
                            wrap: isWrap,
                            expands: true,
                            readOnly: true,
                            controller: outputController,
                            gutterStyle: GutterStyle(
                              margin: 0,
                              showLineNumbers: false,
                              showFoldingHandles: false,
                            ),
                            background: const Color.fromARGB(255, 18, 36, 52),
                            textStyle:
                                Theme.of(context).typography.white.bodySmall,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!showOption)
                SizedBox()
              else
                Positioned(
                  top: 10,
                  right: 10,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: SizedBox(
                      width: 200,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DropdownButtonHideUnderline(
                              child: DropdownButtonFormField(
                                isExpanded: true,
                                value: type,
                                style: Theme.of(context)
                                    .typography
                                    .black
                                    .bodyMedium,
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.all(8),
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(),
                                ),
                                items: CodeType.values.map((e) {
                                  return DropdownMenuItem(
                                    value: e,
                                    child: Text(e.name),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  type = value!;
                                  setState(() {});

                                  convert(input);
                                },
                              ),
                            ),
                            SizedBox(height: 10),
                            OutlinedButton(
                              onPressed: onCopyCode,
                              style: OutlinedButton.styleFrom(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: Center(child: Text('Copy Code')),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void convert(String text) {
    final emitter = DartEmitter();

    final result = parseString(content: text);
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
                  ..defaultTo =
                      defaultValue == null ? null : Code(defaultValue),
              );

              if (param.isNamed) {
                optionalParameters.add(parameter);
              } else {
                requiredParameters.add(parameter);
              }
            }
          }
        }

        final obj = Generator(
          type: type,
          name: '${declaration.name}',
          optionalParameters: optionalParameters,
          requiredParameters: requiredParameters,
        ).gen();

        outputController.fullText =
            DartFormatter().format('${obj.accept(emitter)}');
        // setState(() {});
      }
    }
  }

  void onChanged(String text) {
    input = text;
    setState(() {});

    convert(text);
  }

  void onFormatCode() {
    final formatter = DartFormatter();
    final formattedCode = formatter.format(input);

    controller.text = formattedCode;
  }

  void onCopyCode() {
    Clipboard.setData(ClipboardData(text: outputController.fullText)).then((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Copied to clipboard!')),
      );
    });
  }
}
