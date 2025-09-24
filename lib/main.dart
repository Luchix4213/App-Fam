import 'package:fam_intento1/core/colors.dart';
import 'package:fam_intento1/database/databese_helper.dart';
import 'package:fam_intento1/pantallas/Inicio.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database; // Carga y crea DB si no existe
  runApp(const MainApp());
}


class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: appColores.backgraund,
        body: PantallaInicio(),
      ),
    );
  }
}
