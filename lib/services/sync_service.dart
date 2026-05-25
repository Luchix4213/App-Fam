import 'package:flutter/foundation.dart'; // Para ValueNotifier
import 'package:fam_intento1/services/api_service.dart';
import 'package:fam_intento1/database/databese_helper.dart';

class SyncService {
  // Timbre global para notificar a la UI cuando hay nuevos datos
  static final ValueNotifier<int> onDataUpdated = ValueNotifier(0);
  
  
  // Sincronizar todo (Asociaciones -> Miembros)
  static Future<bool> syncAll() async {
    print("----------------------------------------------------------------");
    print("[SyncService] Iniciando sincronización completa (Sin Departamentos)...");
    
    bool connectionSuccess = false;
    try {
      // 1. OBTENER ASOCIACIONES
      print("[SyncService] Solicitando ASOCIACIONES a API...");
      final asocRes = await ApiService.getAllAsociaciones();
      
      if (asocRes['success'] == true) {
        connectionSuccess = true;
        final List<dynamic> asociaciones = asocRes['data'];
        print("[SyncService] Recibidas \${asociaciones.length} asociaciones.");
        
        // Sanitizar
        List<Map<String, dynamic>> asocClean = asociaciones.map((item) {
          Map<String, dynamic> map = Map<String, dynamic>.from(item);
          map.removeWhere((key, value) => value is Map || value is List);
          return map;
        }).toList();
        
        // REGLA CLAVE: Solo borrar la base de datos si logramos traer datos nuevos (Hay Internet)
        await DatabaseHelper.instance.deleteAllAsociaciones();
        await DatabaseHelper.instance.syncAsociaciones(asocClean);
        print("[SyncService] Asociaciones locales actualizadas exitosamente.");
      } else {
         print("[SyncService] FALLO en asociaciones (Posible Offline): \${asocRes['message']}. Conservando SQLite local intacto.");
      }

      // 2. OBTENER MIEMBROS
      print("[SyncService] Solicitando MIEMBROS a API...");
      final miembroRes = await ApiService.getAllMiembros();

      if (miembroRes['success'] == true) {
        final List<dynamic> miembros = miembroRes['data'];
        print("[SyncService] Recibidos \${miembros.length} miembros.");

        // Sanitizar
        List<Map<String, dynamic>> miembrosClean = miembros.map((item) {
          Map<String, dynamic> map = Map<String, dynamic>.from(item);
          map.removeWhere((key, value) => value is Map || value is List);
          return map;
        }).toList();

        // REGLA CLAVE: Solo borrar si hay conexión exitosa
        await DatabaseHelper.instance.deleteAllMinistros();
        await DatabaseHelper.instance.syncMinistros(miembrosClean);
        print("[SyncService] Miembros locales actualizados exitosamente.");
      } else {
        print("[SyncService] FALLO en miembros (Posible Offline): \${miembroRes['message']}. Conservando SQLite local intacto.");
      }
      
      // 3. OBTENER PERSONAL
      print("[SyncService] Solicitando PERSONAL a API...");
      final personalRes = await ApiService.getAllPersonal();

      if (personalRes['success'] == true) {
        final List<dynamic> personalData = personalRes['data'];
        print("[SyncService] Recibidos ${personalData.length} registros de personal.");

        // Sanitizar
        List<Map<String, dynamic>> perClean = personalData.map((item) {
          Map<String, dynamic> map = Map<String, dynamic>.from(item);
          map.removeWhere((key, value) => value is Map || value is List);
          return map;
        }).toList();

        // REGLA CLAVE: Solo borrar si hay conexión exitosa
        await DatabaseHelper.instance.deleteAllPersonal();
        await DatabaseHelper.instance.syncPersonal(perClean);
        print("[SyncService] Personal local actualizado exitosamente.");
      } else {
        print("[SyncService] FALLO en personal (Posible Offline): ${personalRes['message']}. Conservando SQLite local intacto.");
      }

      print("[SyncService] Proceso de sincronización finalizado.");
      
      // Tocar la campana para que todas las pantallas se refresquen
      onDataUpdated.value++;
      return connectionSuccess;
      
    } catch (e) {
      print("[SyncService] CRITICAL ERROR / NETWORK EXCEPTION durante la sincronización: \$e");
      print("[SyncService] La limpieza total fue abortada para proteger el caché Offline.");
      return false;
    } finally {
      print("----------------------------------------------------------------");
    }
  }
}
