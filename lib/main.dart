import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillforge/auth/auth_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme.dart';

void main() async{
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  await Supabase.initialize(
    anonKey: "Insert anon key",
    url: "Insert project URL");
  
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SkillForge',
      theme: ThemeMethod().themeData,
      home: AuthGate(),
    );
  }
}
