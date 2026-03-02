import 'package:fam_intento1/services/api_service.dart';
import 'package:fam_intento1/database/databese_helper.dart';

class SyncService {
  
  // Sincronizar todo (Departamentos -> Asociaciones -> Miembros)
  static Future<void> syncAll() async {
    print("----------------------------------------------------------------");
    print("[SyncService] Iniciando sincronización completa...");
    
    try {
      // 1. Obtener Departamentos
      print("[SyncService] 1. Solicitando DEPARTAMENTOS a API...");
      final deptosRes = await ApiService.getDepartamentos();
      print("[SyncService] Respuesta DEPARTAMENTOS: success=${deptosRes['success']}");
      
      if (deptosRes['success'] == true) {
        final List<dynamic> departamentos = deptosRes['data'];
        print("[SyncService] Recibidos ${departamentos.length} departamentos.");
        
        // LIMPIEZA TOTAL ANTES DE INSERTAR (Para eliminar inactivos/borrados)
        await DatabaseHelper.instance.deleteAllDepartamentos();
        await DatabaseHelper.instance.deleteAllAsociaciones();
        await DatabaseHelper.instance.deleteAllMinistros();
        print("[SyncService] Tablas locales limpiadas.");

        await DatabaseHelper.instance.syncDepartamentos(departamentos);
        print("[SyncService] Departamentos guardados en SQLite.");
        
        // 2. Iterar departamentos para buscar asociaciones
        for (var depto in departamentos) {
          final int deptoId = depto['id'];
          // print("[SyncService] Solicitando ASOCIACIONES para Depto $deptoId...");
          final asocRes = await ApiService.getAsociacionesByDepartamento(deptoId);
          
          if (asocRes['success'] == true) {
            final List<dynamic> asociaciones = asocRes['data'];
             print("[SyncService] Depto $deptoId: ${asociaciones.length} asociaciones.");
            
            // SANITIZAR DATOS DE ASOCIACIONES (Aplanar mapa)
            List<Map<String, dynamic>> asociacionesClean = asociaciones.map((item) {
              // Convertir a Mapa editable
              Map<String, dynamic> map = Map<String, dynamic>.from(item);
              
              // 1. Asegurar foreign key id_departamento
              map['id_departamento'] = deptoId; 
              
              // 2. Eliminar objetos anidados que rompen SQLite (e.g. "Departamento": {...})
              map.removeWhere((key, value) => value is Map || value is List);
              
              return map;
            }).toList();

            await DatabaseHelper.instance.syncAsociaciones(asociacionesClean);
            
            // 3. Iterar asociaciones para buscar miembros
            for (var asoc in asociaciones) {
              final int asocId = asoc['id'];
              // print("[SyncService] Solicitando MIEMBROS para Asoc $asocId...");
              final miembroRes = await ApiService.getMiembrosByAsociacion(asocId);
              
              if (miembroRes['success'] == true) {
                final List<dynamic> miembros = miembroRes['data'];
                // print("[SyncService]    Asoc $asocId: ${miembros.length} miembros.");
                
                 // SANITIZAR DATOS DE MIEMBROS
                List<Map<String, dynamic>> miembrosClean = miembros.map((item) {
                  Map<String, dynamic> map = Map<String, dynamic>.from(item);
                  
                  // 1. Asegurar foreign key id_asociacion
                  map['id_asociacion'] = asocId;
                  
                  // 2. Eliminar anidados (e.g. "Asociacion": {...})
                  map.removeWhere((key, value) => value is Map || value is List);
                  
                  return map;
                }).toList();

                await DatabaseHelper.instance.syncMinistros(miembrosClean);
              } else {
                print("[SyncService] ERROR obteniendo miembros para Asoc $asocId: ${miembroRes['message']}");
              }
            }
          } else {
             print("[SyncService] ERROR obteniendo asociaciones para Depto $deptoId: ${asocRes['message']}");
          }
        }
        print("[SyncService] Sincronización completada con éxito.");
      } else {
        print("[SyncService] ERROR obteniendo departamentos: ${deptosRes['message']}");
      }
    } catch (e) {
      print("[SyncService] CRITICAL ERROR durante la sincronización: $e");
    } finally {
      print("----------------------------------------------------------------");
    }
  }
}
