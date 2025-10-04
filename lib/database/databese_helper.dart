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
      version: 9, // 👈 súbelo para forzar recreación
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        // Borrar la tabla vieja
        await db.execute("DROP TABLE IF EXISTS ministros");
        // Crear de nuevo
        await _createDB(db, newVersion);
      },
    );

  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ministros (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        departamento TEXT NOT NULL,
        municipio TEXT NOT NULL,
        nombre TEXT NOT NULL,
        paterno TEXT,
        materno TEXT,
        telefono_celular TEXT,
        sigla TEXT,
        telefono_fax TEXT,
        correo TEXT,
        direccion_gam TEXT,
        imagen TEXT
      )
    ''');

    // Cargar JSON desde assets
    String data = await rootBundle.loadString('assets/ministros.json');
    List<dynamic> ministros = jsonDecode(data);

    // Insertar cada ministro
    for (var ministro in ministros) {
      await db.insert('ministros', ministro);
    }
  }

  // Insertar ministro
  Future<int> insert(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('ministros', row);
  }

  // Consultar ministros (con filtros)
  Future<List<Map<String, dynamic>>> queryMinistros({
    String? departamento,
    String? nombreCompleto,
  }) async {
    final db = await instance.database;
    String where = "1=1";
    List<dynamic> whereArgs = [];

    if (departamento != null && departamento.isNotEmpty) {
      where += " AND departamento = ?";
      whereArgs.add(departamento);
    }

    if (nombreCompleto != null && nombreCompleto.isNotEmpty) {
      where += " AND (nombre || ' ' || paterno || ' ' || materno) LIKE ?";
      whereArgs.add("%$nombreCompleto%");
    }

    return await db.query(
      "ministros",
      where: where,
      whereArgs: whereArgs,
      orderBy: "departamento ASC, municipio ASC", // 👈 ordenado
    );
  }

}
