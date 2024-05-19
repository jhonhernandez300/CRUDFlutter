import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;
import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'producto.dart';

void main() {
  sqflite_ffi.sqfliteFfiInit();
  var databaseFactoryFfi = sqflite_ffi.databaseFactoryFfi;
  sqflite_ffi.databaseFactory = databaseFactoryFfi;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter CRUD with Sqflite',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ProductoList(),
    );
  }
}

class ProductoList extends StatefulWidget {
  const ProductoList({super.key});

  @override
  _ProductoListState createState() => _ProductoListState();
}

class _ProductoListState extends State<ProductoList> {
  final DBHelper _dbHelper = DBHelper();
  List<Producto> _productos = [];

  @override
  void initState() {
    super.initState();
    _refreshProductoList();
  }

  void _refreshProductoList() async {
    List<Map<String, dynamic>> productosMaps = await _dbHelper.getProductos();
    setState(() {
      _productos = productosMaps.map((productoMap) {
        return Producto(
          id: productoMap['id'],
          producto: productoMap['producto'],
          valor: productoMap['valor'],
          cliente: productoMap['cliente'],
          metodoDePago: productoMap['metodoDePago'],
          fecha: productoMap['fecha'],
        );
      }).toList();
    });
  }

  void _showForm([Producto? producto]) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String productoName = producto?.producto ?? '';
    double valor = producto?.valor ?? 0.0;
    String cliente = producto?.cliente ?? '';
    String metodoDePago = producto?.metodoDePago ?? 'Efectivo';
    String fecha = producto?.fecha ?? '';

    // Controlador de texto para la fecha
    final TextEditingController fechaController =
        TextEditingController(text: fecha);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title:
                  Text(producto == null ? 'Nuevo Producto' : 'Editar Producto'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      initialValue: productoName,
                      decoration: const InputDecoration(labelText: 'Producto'),
                      onSaved: (value) {
                        productoName = value!;
                      },
                    ),
                    TextFormField(
                      initialValue: valor.toString(),
                      decoration: const InputDecoration(labelText: 'Valor'),
                      keyboardType: TextInputType.number,
                      onSaved: (value) {
                        valor = double.parse(value!);
                      },
                    ),
                    TextFormField(
                      initialValue: cliente,
                      decoration: const InputDecoration(labelText: 'Cliente'),
                      onSaved: (value) {
                        cliente = value!;
                      },
                    ),
                    Column(
                      children: <Widget>[
                        ListTile(
                          title: const Text('Efectivo'),
                          leading: Radio<String>(
                            value: 'Efectivo',
                            groupValue: metodoDePago,
                            onChanged: (String? value) {
                              setState(() {
                                metodoDePago = value!;
                              });
                            },
                          ),
                        ),
                        ListTile(
                          title: const Text('Tarjeta de Crédito'),
                          leading: Radio<String>(
                            value: 'Tarjeta de Crédito',
                            groupValue: metodoDePago,
                            onChanged: (String? value) {
                              setState(() {
                                metodoDePago = value!;
                              });
                            },
                          ),
                        ),
                        ListTile(
                          title: const Text('Tarjeta de Débito'),
                          leading: Radio<String>(
                            value: 'Tarjeta de Débito',
                            groupValue: metodoDePago,
                            onChanged: (String? value) {
                              setState(() {
                                metodoDePago = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: fechaController,
                      decoration: const InputDecoration(labelText: 'Fecha'),
                      readOnly: true,
                      onTap: () async {
                        FocusScope.of(context).requestFocus(FocusNode());
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          setState(() {
                            fecha = "${picked.toLocal()}".split(' ')[0];
                            fechaController.text = fecha;
                          });
                        }
                      },
                      onSaved: (value) {
                        fecha = value!;
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Guardar'),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();

                      if (producto == null) {
                        await _dbHelper.insertProducto({
                          'producto': productoName,
                          'valor': valor,
                          'cliente': cliente,
                          'metodoDePago': metodoDePago,
                          'fecha': fecha,
                        });
                      } else {
                        await _dbHelper.updateProducto({
                          'id': producto.id,
                          'producto': productoName,
                          'valor': valor,
                          'cliente': cliente,
                          'metodoDePago': metodoDePago,
                          'fecha': fecha,
                        });
                      }

                      _refreshProductoList();
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteProducto(int id) async {
    await _dbHelper.deleteProducto(id);
    _refreshProductoList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Productos'),
      ),
      body: ListView.builder(
        itemCount: _productos.length,
        itemBuilder: (context, index) {
          final producto = _productos[index];
          return ListTile(
            title: Text(producto.producto),
            subtitle: Text(
                'Cliente: ${producto.cliente} - Valor: \$${producto.valor.toString()}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _showForm(producto);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _deleteProducto(producto.id!);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showForm();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
