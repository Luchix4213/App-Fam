import 'package:fam_intento1/componentes/ministros.dart';
import 'package:fam_intento1/core/colors.dart';
import 'package:fam_intento1/core/text.dart';
import 'package:fam_intento1/database/databese_helper.dart';
import 'package:flutter/material.dart';

class Pantallabusqueda extends StatefulWidget {
  const Pantallabusqueda({super.key});

  @override
  State<Pantallabusqueda> createState() => _PantallabusquedaState();
}

class _PantallabusquedaState extends State<Pantallabusqueda> {
  final List<String> departamentos = [
    "La Paz",
    "Cochabamba",
    "Santa Cruz",
    "Pando",
    "Sucre",
    "Oruro",
    "Potosí",
    "Beni",
    "Tarija",
  ];

  String? seleccionado;
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> listaMinistros = [];

  final _formKey = GlobalKey<FormState>(); // clave del formulario

  @override
  void initState() {
    super.initState();
    _cargarTodos();
  }

  Future<void> _cargarTodos() async {
    final resultados = await DatabaseHelper.instance.queryMinistros();
    setState(() {
      listaMinistros = resultados;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buscador", style: TextStyles.appbar),
        backgroundColor: appColores.colorapp,
      ),
      backgroundColor: appColores.backgraund,
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                children: [
                  const Text(
                    "Selecciona un departamento:",
                    style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 100,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        border: const OutlineInputBorder(),
                        prefixIcon: seleccionado == null
                            ? Padding(
                                padding: const EdgeInsets.only(left: 30, right: 30),
                                child: Image.asset(
                                  "assets/images/ubicacion.png",
                                  width: 40,
                                  height: 40,
                                ),
                              )
                            : null,
                      ),
                      icon: const SizedBox.shrink(),
                      value: seleccionado,
                      items: departamentos.map((dep) {
                        return DropdownMenuItem(
                          value: dep,
                          child: Text(dep, style: const TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          seleccionado = value;
                        });
                      },
                      validator: (value) {
                        //if (value == null || value.isEmpty) {
                          //return "Selecciona un departamento";
                        //}
                        //return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: "Buscar por nombre completo...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  //if (value == null || value.isEmpty) {
                    //return "Ingresa un nombre para buscar";
                  //}
                  //return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final resultados = await DatabaseHelper.instance.queryMinistros(
                    departamento: seleccionado,
                    nombreCompleto: _controller.text,
                  );
                  setState(() {
                    listaMinistros = resultados;
                  });
                },
                child: const Icon(Icons.filter_list, color: Colors.white),
              ),
              const SizedBox(height: 20),

              // Mostrar resultados
              if (listaMinistros.isEmpty)
                const Center(
                  child: Text(
                    "No se encontraron resultados",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                )
              else
                ...listaMinistros.map((ministro) => Ministros(datos: ministro)).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
