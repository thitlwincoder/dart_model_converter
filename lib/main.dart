import 'package:dart_model_converter/app/main_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadcnApp(
      theme: ThemeData(colorScheme: ColorSchemes.darkZinc(), radius: 0.5),
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}
