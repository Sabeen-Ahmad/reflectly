import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'data/models/reflection_model.dart';
import 'data/repositories/reflection_repository.dart';
import 'shared/theme/app_theme.dart';
import 'shared/widgets/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ReflectionModelAdapter());
  await ReflectionRepository.init(); 
  runApp(const ProviderScope(child: ArvyaXApp()));
}

class ArvyaXApp extends StatelessWidget {
  const ArvyaXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reflectly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const MainShell(),
    );
  }
}
