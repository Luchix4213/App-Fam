import 'package:flutter/material.dart';
import 'package:fam_intento1/services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageHelper {
  
  static ImageProvider getImageProvider({
    required String? apiPath, 
    String? name, 
    String? alias, 
    required String type, 
    String? municipio,
    String? deptoName, // For Members (ALCALDE)
    String? tipoMiembro, // For Members lookup
  }) {
    // 1. Try API Network Image
    if (apiPath != null && apiPath.isNotEmpty) {
      if (apiPath.startsWith('http')) {
        return CachedNetworkImageProvider(apiPath);
      }
      String cleanPath = apiPath;
      if (!cleanPath.startsWith('/')) cleanPath = '/$cleanPath';
      final url = "${ApiService.baseUrl.replaceAll('/api', '')}$cleanPath";
      return CachedNetworkImageProvider(url);
    }

    // 2. Try Asset Image based on Type and params
    final assetPath = _getAssetPath(name, alias, type, municipio, deptoName, tipoMiembro);
    if (assetPath != null) {
      return AssetImage(assetPath);
    }

    // 3. Fallback
    return const AssetImage('assets/images/famlogo.png');
  }

  static String? _getAssetPath(String? name, String? alias, String type, String? municipio, String? deptoName, String? tipoMiembro) {
    if (type == 'departamento' && name != null) {
      final cleanName = name.trim().toLowerCase().replaceAll(' ', '');
      if (cleanName == 'acobol' || cleanName == 'amb') {
        return 'assets/images/departamentos/$cleanName.png';
      }
      return 'assets/images/departamentos/$cleanName.jpg';
    }
    
    if (type == 'asociacion' && alias != null) {
      // Confirmed: Associations in assets/images/asociasiones are .png (e.g. AGAMDEPAZ.png)
      final cleanAlias = alias.trim().toUpperCase();
      return 'assets/images/asociasiones/$cleanAlias.png'; 
    }

    if (type == 'miembro') {
       if (tipoMiembro == null) return null;
       final t = tipoMiembro.toUpperCase();

       // 1. ACOBOL (Concejala)
       // Confirmed: assets/images/miembros/acobol are .png (e.g. acolapaz.png)
       if (t.contains('CONCEJAL') && alias != null) {
         return 'assets/images/miembros/acobol/${alias.trim().toLowerCase()}.png';
       }

       // 2. AMB (Ambes)
       // Confirmed: assets/images/miembros/amb are .jpg (e.g. AMBBN.jpg)
       if (t.contains('AMBES') && alias != null) {
         return 'assets/images/miembros/amb/${alias.trim().toUpperCase()}.jpg';
       }

       // 3. AMDES (Alcalde)
       // Confirmed: assets/images/miembros/amdes/[DEPTO] are .JPG (e.g. ACHACACHI.JPG)
       if (t.contains('ALCALDE') && municipio != null && deptoName != null) {
         final cleanDepto = deptoName.trim().toLowerCase().replaceAll(' ', '');
         final cleanMuni = municipio.trim().toUpperCase();
         return 'assets/images/miembros/amdes/$cleanDepto/$cleanMuni.JPG';
       }
    }

    return null; 
  }

  static Widget getCircleAvatar({
    required String? apiPath, 
    String? name, 
    String? alias,
    required String type, 
    double radius = 30,
    String? municipio,
    String? deptoName,
    String? tipoMiembro
  }) {
    final imageProvider = getImageProvider(
      apiPath: apiPath, 
      name: name, 
      alias: alias, 
      type: type, 
      municipio: municipio,
      deptoName: deptoName,
      tipoMiembro: tipoMiembro
    );
    
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[200],
      backgroundImage: imageProvider,
      onBackgroundImageError: (_, __) { },
      child: null, // Just show background. If fails, it shows grey.
    );
  }
}
