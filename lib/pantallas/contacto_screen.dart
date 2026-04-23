import 'package:flutter/material.dart';
import 'package:fam_intento1/core/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactoScreen extends StatelessWidget {
  const ContactoScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _openEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Info hardcoded for exactly what is expected from the mockup
    const direccion = "Av. 14 de Septiembre N° 6154 (Obrajes),\nentre calles 15 y 16";
    const telefonoStr1 = "";
    const telefonoStr2 = "(2) 2789114";
    const fax = "Fax: (591) 2 2782106";
    const correo = "contacto@fam.org.bo";
    const locationMapUrl = "https://maps.app.goo.gl/CWTLdhaCnqE8Lobc9";
    const politicaUrl = "https://fam-bolivia-politica-privacidad.netlify.app";
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco entero
      body: Column(
        children: [
          // Logo Section (Top Half)
          const SizedBox(height: 30),
          Expanded(
            flex: 3,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Image.asset(
                  "assets/images/famlogo2.png",
                  width: 220, // Foto un poco mas grande
                  height: 220,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.business, size: 120, color: appColores.dashTealStart),
                ),
              ),
            ),
          ),

          // Info Card Section (Bottom Half)
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
                    decoration: const BoxDecoration(
                      color: appColores.dashTealStart, // Azul oscuro tarjeta
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildSectionTitle("Dirección"),
                          _buildInfoText(direccion),
                          
                          const SizedBox(height: 15),
                          _buildSectionTitle("Teléfonos"),
                         // _buildInfoText(telefonoStr1),
                          _buildInfoText(telefonoStr2),
                          _buildInfoText(fax),
                          
                          const SizedBox(height: 15),
                          _buildSectionTitle("Correo"),
                          GestureDetector(
                            onTap: () => _openEmail(correo),
                            child: Text(
                              correo,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 15),
                          _buildSectionTitle("Política de Privacidad"),

                          GestureDetector(
                            onTap: () => _launchUrl(politicaUrl),
                            child: const Text(
                              "Ver política de privacidad",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          
                          const SizedBox(height: 25),
                          _buildSectionTitle("Redes Sociales"),
                          const SizedBox(height: 15),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12, // espacio horizontal
                            runSpacing: 12, // espacio vertical
                            children: [
                               _buildSocialIcon(FontAwesomeIcons.facebookF, "https://www.facebook.com/fam.org.bo"),
                               _buildSocialIcon(FontAwesomeIcons.instagram, "https://www.instagram.com/fambolivia/"),
                               _buildSocialIcon(FontAwesomeIcons.xTwitter, "https://x.com/FAM_Bolivia1"),
                               _buildSocialIcon(FontAwesomeIcons.youtube, "https://www.youtube.com/@FAMBOLIVIA"),
                               _buildSocialIcon(FontAwesomeIcons.tiktok, "https://www.tiktok.com/@fam_bolivia"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Floating Location Button (Top Right)
                  Positioned(
                    top: 25, 
                    right: 25, 
                    child: GestureDetector(
                      onTap: () => _launchUrl(locationMapUrl),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15), // Semi-transparente
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                        ),
                        child: const Icon(Icons.location_on_outlined, color: Colors.white, size: 30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: () => _launchUrl(url),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            color: Colors.white, 
            size: 24,
          ),
        ),
      ),
    );
  }
}
