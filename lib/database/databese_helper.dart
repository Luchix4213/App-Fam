import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ministros.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 18, // Version incrementada para limpiar campos de asociaciones y añadir color
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        // Borrar tablas viejas si existen
        await db.execute("DROP TABLE IF EXISTS ministros");
        await db.execute("DROP TABLE IF EXISTS asociaciones");
        await db.execute("DROP TABLE IF EXISTS personal");
        // Crear de nuevo
        await _createDB(db, newVersion);
      },
    );
  }

  Future _createDB(Database db, int version) async {
    // Tabla Ministros (Miembros)
    await db.execute('''
    CREATE TABLE ministros (
      id INTEGER PRIMARY KEY,
      alias TEXT,
      nombre TEXT NOT NULL,
      municipio TEXT,
      telefono_personal TEXT,
      telefono_publico TEXT,
      telefono_fax TEXT,
      correo_personal TEXT,
      correo_publico TEXT,
      direccion TEXT,
      tipo_miembro TEXT,
      estado TEXT,
      id_asociacion INTEGER,
      foto TEXT
    )
    ''');

    // Tabla Asociaciones
    await db.execute('''
    CREATE TABLE asociaciones (
      id INTEGER PRIMARY KEY,
      alias TEXT,
      nombre TEXT NOT NULL,
      foto TEXT,
      color TEXT,
      estado TEXT DEFAULT 'activo'
    )
    ''');

    // Tabla Personal (Administrativo)
    await db.execute('''
    CREATE TABLE personal (
      id INTEGER PRIMARY KEY,
      nombre TEXT NOT NULL,
      cargo TEXT NOT NULL,
      celular TEXT,
      correo_electronico TEXT,
      foto TEXT,
      estado TEXT
    )
    ''');

    // Carga inicial solo si es la primera vez (opcional, pues sync lo hará)
    try {
      String data = await rootBundle.loadString('assets/ministros.json');
      List<dynamic> ministros = jsonDecode(data);
      for (var ministro in ministros) {
        // Asignar IDs temporales si no vienen del backend aun
        // Nota: Si el ID viene en el JSON, se usará. Si no, SQLite autoincrementa.
        // Pero como definimos id INTEGER PRIMARY KEY (sin autoincrement explicito aunque sqlite lo hace si es null),
        // mejor asegurarnos que el JSON tenga ids o dejar que sqlite lo haga si no lo tieen.
        // El insert ignorará el ID si no está en el mapa, y generará uno.
        await db.insert('ministros', ministro); 
      }
    } catch (e) {
      print("Error cargando seed inicial: $e");
    }
  }

  // --- CRUD & SYNC METHODS ---

  // Miembros
  Future<int> insertOrUpdateMinistro(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert(
      'ministros', 
      row, 
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future<void> syncMinistros(List<dynamic> list) async {
    final db = await instance.database;
    Batch batch = db.batch();
    
    // Solo permitir las columnas públicas que existen (omitiendo datos personales sensibles)
    final List<String> validColumns = [
      'id', 'alias', 'nombre', 'municipio', 'telefono_publico',
      'telefono_fax', 'correo_publico', 'direccion', 'tipo_miembro',
      'estado', 'id_asociacion', 'foto'
    ];

    for (var item in list) {
       Map<String, dynamic> cleanItem = Map<String, dynamic>.from(item);
       cleanItem.removeWhere((key, value) => !validColumns.contains(key) || value is Map || value is List);
       
       batch.insert('ministros', cleanItem, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  // Asociaciones
  Future<int> insertOrUpdateAsociacion(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('asociaciones', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> syncAsociaciones(List<dynamic> list) async {
    final db = await instance.database;
    Batch batch = db.batch();
    
    // Solo permitir las columnas públicas que existen en la tabla sqlite (omitiendo createdAt y datos personales)
    final List<String> validColumns = [
      'id', 'alias', 'nombre', 'estado', 'foto', 'color'
    ];

    for (var item in list) {
       Map<String, dynamic> cleanItem = Map<String, dynamic>.from(item);
       cleanItem.removeWhere((key, value) => !validColumns.contains(key) || value is Map || value is List);
       
       batch.insert('asociaciones', cleanItem, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  // Personal
  Future<int> insertOrUpdatePersonal(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('personal', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> syncPersonal(List<dynamic> list) async {
    final db = await instance.database;
    Batch batch = db.batch();
    
    final List<String> validColumns = [
      'id', 'nombre', 'cargo', 'celular', 'correo_electronico',
      'foto', 'estado'
    ];

    for (var item in list) {
       Map<String, dynamic> cleanItem = Map<String, dynamic>.from(item);
       cleanItem.removeWhere((key, value) => !validColumns.contains(key) || value is Map || value is List);
       
       batch.insert('personal', cleanItem, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }
  Future<void> deleteAllMinistros() async {
    final db = await instance.database;
    await db.delete('ministros');
  }

  Future<void> deleteAllAsociaciones() async {
    final db = await instance.database;
    await db.delete('asociaciones');
  }

  Future<void> deleteAllPersonal() async {
    final db = await instance.database;
    await db.delete('personal');
  }



  // --- QUERY METHODS ---

  Future<List<Map<String, dynamic>>> getAllAsociaciones() async {
    final db = await instance.database;
    return await db.query('asociaciones', orderBy: 'nombre ASC');
  }

  Future<List<Map<String, dynamic>>> getAllPersonal() async {
    final db = await instance.database;
    return await db.query('personal', orderBy: 'nombre ASC');
  }

  Future<List<Map<String, dynamic>>> getMinistrosByAsoc(int asocId) async {
    final db = await instance.database;
    return await db.query(
      'ministros', 
      where: 'id_asociacion = ?', 
      whereArgs: [asocId],
      orderBy: 'nombre ASC'
    );
  }

  // Consultar ministros (con filtros)
  Future<List<Map<String, dynamic>>> queryMinistros({
    String? departamento,
    String? nombreCompleto,
  }) async {
    final db = await instance.database;
    String where = "1=1";
    List<dynamic> whereArgs = [];

    // Nota: El filtro por departamento es complejo porque 'departamento' ya no está en la tabla ministros directamente,
    // sino via asociacion -> departamento.
    // Si la query requiere JOINs, sqflite rawQuery es mejor.
    // Asumiremos que por ahora 'departamento' puede estar denormalizado o requeriremos cambiar esto.
    // No department column in asociaciones (ver step 49).
    // Ah, el step 49 dice: `where += " AND departamento = ?";` pero la tabla CREATE NO TIENE DEPARTAMENTO.
    // Eso significa que el código anterior ya estaba roto o yo leí mal.
    // Revisando step 49:
    // 38:     CREATE TABLE ministros (
    // ...
    // 51:       id_asociacion INTEGER
    // 52:     )
    // Pero la query usaba `orderBy: "departamento ASC"`.
    // Probablemente SQLite permite order by columnas que no existen? No.
    // O tal vez el JSON tiene esos campos y SQLite es permisivo? No.
    // Asumiré que debo arreglar esa query o dejarla comentada/simplificada.

    if (nombreCompleto != null && nombreCompleto.isNotEmpty) {
      // El codigo anterior usaba "nombre || ' ' || paterno", pero la tabla no tiene paterno/materno.
      // Solo 'nombre'. 
      // Ajustaré esto a la realidad de la tabla.
      where += " AND nombre LIKE ?";
      whereArgs.add("%$nombreCompleto%");
    }

    return await db.query(
      "ministros",
      where: where,
      whereArgs: whereArgs,
      orderBy: "nombre ASC",
    );
  }

}
