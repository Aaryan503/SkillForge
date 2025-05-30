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
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVrcmd6dG1iZ2x5YmN1dWt4eW9lIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYxNTAyMTEsImV4cCI6MjA2MTcyNjIxMX0.s5N50eAQAuf5rFnfbqhf5NCD5MpgZK2wf8y5m96-laQ",
    url: "https://ekrgztmbglybcuukxyoe.supabase.co");
  
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