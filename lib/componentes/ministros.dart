import 'package:fam_intento1/core/colors.dart';
import 'package:fam_intento1/core/text.dart';
import 'package:flutter/material.dart';

class Ministros extends StatelessWidget {
  final Map<String, dynamic> datos;

  const Ministros({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: appColores.color3, width: 2),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 📷 Imagen a la izquierda
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                "assets/images/${datos['imagen']}",
                width: 100,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),

            // 📝 Datos en una sola columna
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Dato(label: "MUNICIPIO:", valor: datos['municipio']),
                  _Dato(
                    label: "NOMBRE Y APELLIDO:",
                    valor:
                        "${datos['nombre']} ${datos['paterno']} ${datos['materno']}",
                  ),
                  _Dato(
                      label: "TELÉFONO CELULAR:",
                      valor: datos['telefono_celular']),
                  _Dato(label: "SIGLA:", valor: datos['sigla']),
                  _Dato(
                      label: "TELÉFONO FAX:", valor: datos['telefono_fax']),
                  _Dato(label: "CORREO ELECTRÓNICO:", valor: datos['correo']),
                  _Dato(
                      label: "DIRECCIÓN G.A.M.:",
                      valor: datos['direccion_gam']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// 🔹 Widget reutilizable para cada fila de datos
class _Dato extends StatelessWidget {
  final String label;
  final String valor;

  const _Dato({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Etiqueta
          Text(label, style: TextStyles.contenedorleft),

          const SizedBox(width: 6),

          // Valor (ocupa lo que resta del espacio)
          Expanded(
            child: Text(
              valor,
              style: TextStyles.contenedorrigth,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
