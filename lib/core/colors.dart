import 'dart:ui';
import 'package:flutter/material.dart';

class appColores{
  // FAM Bolivia Brand Colors (Modern)
  static const Color primaryBlue = Color(0xFF00ADEF); // Cyan/Blue vibrant
  static const Color primaryGreen = Color(0xFF25D366); // Green prominent (WhatsApp-like or FAM Green)
  static const Color primaryGreenDark = Color(0xFF1B5E20); // Darker green for gradients
  
  // Gradients
  static const Color gradientTop = Color(0xFFE0F7FA); // Light Cyan
  static const Color gradientBottom = Color(0xFFE8F5E9); // Light Green
  
  // Text
  static const Color textDark = Color(0xFF2C3E50); // Dark Blue-Grey
  static const Color textGrey = Color(0xFF7F8C8D);

  // Legacy mappings (to prevent breaking immediate build, but updated values)
  static const Color color1 = primaryBlue; 
  static const Color color2 = Color(0xFF0288D1);
  static const Color color3 = Color(0xFFB3E5FC);
  static const Color color4 = textDark;
  static const Color backgraund = Color(0xFFF5F5F5); // General bg
  static const Color white = Colors.white;
  static const Color greyText = textGrey;
  static const Color success = Color(0xFF4CAF50);
  static const Color danger = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFF9800);

  // Colores departamentos
  static const Color lapaz = Color(0xF4661506);
  static const Color santa = Color(0xF4075931);
  static const Color cocha = Color(0xF40B5985);
  static const Color oruro = Color(0xF4CF1313);
  static const Color potosi = Color(0xF4371111);
  static const Color pando = Color(0xF451CF5A);
  static const Color sucre = Color(0xF4FC6565);
  static const Color tarija = Color(0xF4C70E06);
  static const Color beni = Color(0xF41A7D23);

  // Variables auxiliares requeridas por codigo existente
  static const Color letrablanca = Color(0xF4FFFFFF);
  static const Color colorapp = Color(0xF43C63E4);

  static Color getColorPorDepartamento(String departamento) {
    switch (departamento.toLowerCase()) {
      case "la paz":
        return lapaz;
      case "santa cruz":
        return santa;
      case "cochabamba":
        return cocha;
      case "oruro":
        return oruro;
      case "potosí":
        return potosi;
      case "pando":
        return pando;
      case "sucre":
        return sucre;
      case "tarija":
        return tarija;
      case "beni":
        return beni;
      default:
        return color3; // color por defecto si no coincide
    }
  }

  // --- NUEVOS COLORES PARA REDISEÑO ---
  // Header: Teal a Verde (Azul verdoso a Verde) -> NOW PURE BLUES
  static const Color headerTealStart = Color(0xFF135685); // Dark Blue (Pantone P 108-7 C)
  static const Color headerTealEnd = Color(0xFF6EC6D8);   // Light Blue (Pantone P 121-5 C)
  
  // Card "Departamentos": Verde Lima Vibrante
  static const Color cardLimeStart = Color(0xFF43A047);   // Green 600
  static const Color cardLimeEnd = Color(0xFF9CCC65);     // Light Green 300
  
  // Inputs & Cards
  static const Color inputBorder = Color(0xFFE0E0E0);
  static const Color starYellow = Color(0xFFFFC107);
  
  // Badges
  static const Color badgePurple = Color(0xFF9C27B0); // Alcalde
  static const Color badgePurpleLight = Color(0xFFF3E5F5); 
  static const Color badgeBlue = Color(0xFF2196F3);   // General
  static const Color badgeBlueLight = Color(0xFFE3F2FD);
  
  // Dashboard Admin (Refined - Less 'Chillon', more Sober/Professional)
  static const Color dashTealStart = Color(0xFF135685); // Deep Blue (Pantone P 108-7 C)
  static const Color dashTealEnd = Color(0xFF6EC6D8);   // Soft Light Blue (Pantone P 121-5 C)
  
  // Drawer
  static const Color drawerActiveBg = Color(0xFF1E88E5); // Blue for active item
  static const Color drawerActiveText = Colors.white;
  static const Color drawerInactiveText = Color(0xFF546E7A); // BlueGrey

  static const Color iconOrange = Color(0xFFFF9800);
  static const Color iconBgOrange = Color(0xFFFFF3E0);
  static const Color iconGreen = Color(0xFF135685); // Changed to Blue to match the new professional theme
  static const Color iconBgGreen = Color(0xFFE3F2FD); // Light blue background

  // === NUEVOS COLORES PARA EL GRADIENTE AZUL (como en la foto) ===
  static const Color blueGradientTop    = Color(0xFF0A3D62);   // Azul oscuro superior
  static const Color blueGradientMiddle = Color(0xFF1E5A8A);   // Azul medio
  static const Color blueGradientBottom = Color(0xFF6EC1E4);   // Azul claro inferior

  // (Opcional) Color para texto blanco sobre el gradiente azul
  static const Color textWhiteOnBlue = Colors.white;

  // Gradiente azul para pantalla de Asociaciones (similar a la foto deseada)
  static const Color assocGradientTop    = Color(0xFF135685);    // Azul oscuro/celeste principal (R19, G86, B133)
  static const Color assocGradientMiddle = Color(0xFF2A6FA8);    // Azul medio para transición suave
  static const Color assocGradientBottom = Color(0xFFEDF2F7);    // Gris claro casi blanco (como fondo de la foto)
}
