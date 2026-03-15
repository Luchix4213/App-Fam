import 'package:flutter/foundation.dart'; // Para ValueNotifier
import 'package:fam_intento1/services/api_service.dart';
import 'package:fam_intento1/database/databese_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncService {
  // Timbre global para notificar a la UI cuando hay nuevos datos
  static final ValueNotifier<int> onDataUpdated = ValueNotifier(0);
  
  static bool _isSyncing = false;
  
  // Sincronizar Incrementalmente (Delta Sync)
  static Future<void> syncAll() async {
    if (_isSyncing) {
      print("[SyncService] Sync ya en proceso. Ignorando llamada duplicada.");
      return;
    }

    _isSyncing = true;
    print("----------------------------------------------------------------");
    print("[SyncService] Iniciando sincronización SMART (Delta Sync)...");
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncStr = prefs.getString('lastSync');
      String? updatedAfter = lastSyncStr;

      if (lastSyncStr != null) {
        final last = DateTime.parse(lastSyncStr);
        final diff = DateTime.now().difference(last);
        if (diff.inMinutes < 5) {
          print("[SyncService] Sync omitido (menos de 5 minutos desde $last).");
          _isSyncing = false;
          return;
        }
      }

      bool hasChanges = false;

      // 1. OBTENER ASOCIACIONES
      print("[SyncService] Solicitando ASOCIACIONES (updated_after: $updatedAfter)...");
      final asocRes = await ApiService.getAllAsociaciones(updatedAfter: updatedAfter);
      
      if (asocRes['success'] == true) {
        final List<dynamic> asociaciones = asocRes['data'];
        if (asociaciones.isNotEmpty) {
          print("[SyncService] Descargadas ${asociaciones.length} asociaciones nuevas/modificadas.");
          List<Map<String, dynamic>> asocClean = asociaciones.map((item) {
            Map<String, dynamic> map = Map<String, dynamic>.from(item);
            map.removeWhere((key, value) => value is Map || value is List);
            return map;
          }).toList();
          
          await DatabaseHelper.instance.syncAsociaciones(asocClean);
          hasChanges = true;
        } else {
          print("[SyncService] Asociaciones: Sin cambios.");
        }
      } else {
         print("[SyncService] FALLO en asociaciones: ${asocRes['message']}. Conservando SQLite local intacto.");
      }

      // 2. OBTENER MIEMBROS
      print("[SyncService] Solicitando MIEMBROS (updated_after: $updatedAfter)...");
      final miembroRes = await ApiService.getAllMiembros(updatedAfter: updatedAfter);

      if (miembroRes['success'] == true) {
        final List<dynamic> miembros = miembroRes['data'];
        if (miembros.isNotEmpty) {
          print("[SyncService] Descargados ${miembros.length} miembros nuevos/modificados.");
          List<Map<String, dynamic>> miembrosClean = miembros.map((item) {
            Map<String, dynamic> map = Map<String, dynamic>.from(item);
            map.removeWhere((key, value) => value is Map || value is List);
            return map;
          }).toList();

          await DatabaseHelper.instance.syncMinistros(miembrosClean);
          hasChanges = true;
        } else {
          print("[SyncService] Miembros: Sin cambios.");
        }
      } else {
        print("[SyncService] FALLO en miembros: ${miembroRes['message']}. Conservando SQLite local intacto.");
      }
      
      // 3. OBTENER PERSONAL
      print("[SyncService] Solicitando PERSONAL (updated_after: $updatedAfter)...");
      final personalRes = await ApiService.getAllPersonal(updatedAfter: updatedAfter);

      if (personalRes['success'] == true) {
        final List<dynamic> personalData = personalRes['data'];
        if (personalData.isNotEmpty) {
          print("[SyncService] Descargados ${personalData.length} registros de personal nuevos/modificados.");
          List<Map<String, dynamic>> perClean = personalData.map((item) {
            Map<String, dynamic> map = Map<String, dynamic>.from(item);
            map.removeWhere((key, value) => value is Map || value is List);
            return map;
          }).toList();

          await DatabaseHelper.instance.syncPersonal(perClean);
          hasChanges = true;
        } else {
          print("[SyncService] Personal: Sin cambios.");
        }
      } else {
        print("[SyncService] FALLO en personal: ${personalRes['message']}. Conservando SQLite local intacto.");
      }

      print("[SyncService] Proceso de sincronización finalizado.");
      
      // Actualizar marcador de tiempo (Solo si hubo éxito general y para evitar reintentar todo al instante)
      final newSyncDate = DateTime.now().toUtc().toIso8601String();
      await prefs.setString('lastSync', newSyncDate);
      
      // Tocar la campana SOLO si realmente hubo cambios en la base de datos
      if (hasChanges) {
        onDataUpdated.value++;
        print("[SyncService] UI Notificada de los cambios incrementeales.");
      }
      
    } catch (e) {
      print("[SyncService] CRITICAL ERROR durante la sincronización: $e");
    } finally {
      _isSyncing = false;
      print("----------------------------------------------------------------");
    }
  }
}
