import 'dart:ui';

class appColores{
  static const Color color1 = Color(0xF40808DF);
  static const Color color2 = Color(0xF4D807AB);
  static const Color color3 = Color(0xF4911313);
  static const Color color4 = Color(0xF4027408);


  static const Color lapaz = Color(0xF4661506);
  static const Color santa = Color(0xF4075931);
  static const Color cocha = Color(0xF40B5985);
  static const Color oruro = Color(0xF4CF1313);
  static const Color potosi = Color(0xF4371111);
  static const Color pando = Color(0xF451CF5A);//
  static const Color sucre = Color(0xF4FC6565);
  static const Color tarija = Color(0xF4C70E06);//
  static const Color beni = Color(0xF41A7D23);


  

  //backgraund
  static const Color backgraund = Color(0xFFE9EAFF);
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

}
