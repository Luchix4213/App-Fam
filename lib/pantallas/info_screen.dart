import 'package:flutter/material.dart';
import 'package:fam_intento1/widgets/gradient_scaffold.dart';
import 'package:fam_intento1/core/colors.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.info_outline, size: 80, color: appColores.primaryBlue),
            SizedBox(height: 20),
            Text("Información Institucional", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: appColores.primaryBlue)),
            SizedBox(height: 10),
            Text("Próximamente...", style: TextStyle(color: appColores.greyText)),
          ],
        ),
      ),
    );
  }
}
