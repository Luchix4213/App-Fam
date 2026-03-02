import 'package:flutter/material.dart';
import 'package:fam_intento1/widgets/gradient_scaffold.dart';
import 'package:fam_intento1/core/colors.dart';

class ContactoScreen extends StatelessWidget {
  const ContactoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.contact_support_outlined, size: 80, color: appColores.primaryGreen),
            SizedBox(height: 20),
            Text("Contacto", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: appColores.primaryGreen)),
            SizedBox(height: 10),
            Text("Próximamente...", style: TextStyle(color: appColores.greyText)),
          ],
        ),
      ),
    );
  }
}
