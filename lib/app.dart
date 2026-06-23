import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

class RelatorioVisitasApp extends StatelessWidget {
  const RelatorioVisitasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Relatório de Visitas',

      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      home: const HomeScreen(),
    );
  }
}