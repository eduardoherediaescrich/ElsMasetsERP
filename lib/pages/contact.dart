import 'package:flutter/material.dart';
import 'configuration.dart';
import 'dashboard.dart';
import 'report.dart';
import 'notification.dart';
import '../services/contact_service.dart';

/// Pantalla de gestión de contactos
/// CARACTERÍSTICAS PRINCIPALES:
/// 1. Carga de datos reales desde el backend via ContactService
/// 2. Búsqueda en tiempo real por nombre — filtra localmente sobre los datos del backend
/// 3. CRUD completo: Crear, Leer, Actualizar y Eliminar contactos
/// 4. Acciones rápidas: llamar y enviar mensaje (próximamente)
/// 5. Indicador de carga mientras se obtienen los datos
/// 6. Feedback visual con SnackBars
///
/// WIDGETS DE ENTRADA UTILIZADOS:
/// - TextField (búsqueda, nombre, teléfono, email)
///
/// WIDGETS DE SALIDA UTILIZADOS:
/// - ListView.builder (lista dinámica de contactos)
/// - Card/Material (tarjetas de cada contacto)
/// - AlertDialog (formularios y confirmaciones)
/// - SnackBar (mensajes de feedback)
/// - CircularProgressIndicator (indicador de carga)
class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactosPageState();
}

class _ContactosPageState extends State<ContactPage> {
  /// Lista principal de contactos cargada desde el backend
  /// Cada elemento es un Map con los campos del ContactoDTO
  List<Map<String, dynamic>> contactos = [];

  /// Indica si los datos están siendo cargados desde el backend
  bool _cargando = true;

  /// Mensaje de error si la carga falla
  String? _error;

  /// Texto de búsqueda introducido por el usuario
  /// Filtra la lista localmente en tiempo real
  String _textoBusqueda = '';

  /// TextEditingController para el campo de búsqueda
  final TextEditingController _busquedaController = TextEditingController();

  /// TextEditingController para el campo "Nombre" del formulario
  final TextEditingController _nombreController = TextEditingController();

  /// TextEditingController para el campo "Teléfono" del formulario
  final TextEditingController _telefonoController = TextEditingController();

  /// TextEditingController para el campo "Email" del formulario
  final TextEditingController _emailController = TextEditingController();

  /// TextEditingController para el campo "Empresa" del formulario
  final TextEditingController _empresaController = TextEditingController();

  /// TextEditingController para el campo "Cargo" del formulario
  final TextEditingController _cargoController = TextEditingController();

  @override
  void initState() {
    super.initState();

    /// Carga los contactos al iniciar la pantalla
    _cargarContactos();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    _nombreController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _empresaController.dispose();
    _cargoController.dispose();
    super.dispose();
  }

  // CARGA DE DATOS DESDE EL BACKEND
  /// Llama al ContactService para obtener todos los contactos activos
  /// Actualiza el estado con los datos recibidos o muestra un error
  Future<void> _cargarContactos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final datos = await ContactService.obtenerActivos();
      setState(() {
        /// Convierte la lista dinámica a List<Map<String, dynamic>>
        contactos = List<Map<String, dynamic>>.from(datos);
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar los contactos. Comprueba la conexión.';
        _cargando = false;
      });
    }
  }

  /// Filtra la lista de contactos según el texto de búsqueda
  /// Compara el nombre en minúsculas para que no sea case-sensitive
  List<Map<String, dynamic>> _obtenerContactosFiltrados() {
    if (_textoBusqueda.isEmpty) return contactos;
    return contactos.where((contacto) {
      return (contacto['nombre'] ?? '').toLowerCase().contains(
        _textoBusqueda.toLowerCase(),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final contactosFiltrados = _obtenerContactosFiltrados();

    return Scaffold(
      backgroundColor: const Color(0xFFF6E9C9),

      // AppBar
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6E9C9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A3B2A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // Bottom bar
      bottomNavigationBar: _buildBottomNavigationBar(context),

      body: SafeArea(
        child: Column(
          children: [
            // Logo
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Image.asset('assets/masets_blanco.png', height: 140),
            ),
            const SizedBox(height: 20),

            // Título
            const Text(
              'CONTACTOS',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A3B2A),
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 24),

            // Fila: buscador + botón añadir
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  // Barra de búsqueda (ocupa el espacio disponible)
                  Expanded(
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      elevation: 1,
                      child: TextField(
                        controller: _busquedaController,
                        onChanged: (value) {
                          setState(() {
                            _textoBusqueda = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Buscar',
                          hintStyle: TextStyle(
                            color: const Color(
                              0xFF4A3B2A,
                            ).withValues(alpha: 0.5),
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF4A3B2A),
                          ),
                          suffixIcon: _textoBusqueda.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Color(0xFF4A3B2A),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _busquedaController.clear();
                                      _textoBusqueda = '';
                                    });
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF4A3B2A),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF4A3B2A),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF4A3B2A),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Botón añadir contacto
                  ElevatedButton.icon(
                    onPressed: _mostrarDialogoAgregar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                    label: const Text(
                      'Añadir',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Contenido principal: cargando, error o lista
            Expanded(
              child: _cargando
                  /// Indicador de carga mientras se obtienen los datos del backend
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4A3B2A),
                      ),
                    )
                  : _error != null
                  /// Mensaje de error con botón para reintentar
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _error!,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF4A3B2A),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _cargarContactos,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A3B2A),
                            ),
                            child: const Text(
                              'Reintentar',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )
                  /// Lista de contactos filtrados
                  : contactosFiltrados.isEmpty
                  ? Center(
                      child: Text(
                        _textoBusqueda.isEmpty
                            ? 'No hay contactos'
                            : 'No se encontraron resultados para "$_textoBusqueda"',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF4A3B2A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: contactosFiltrados.length,
                      itemBuilder: (context, index) {
                        final contacto = contactosFiltrados[index];
                        final indiceReal = contactos.indexOf(contacto);
                        return _buildContactoCard(indiceReal);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // TARJETA DE CONTACTO
  /// Construye una tarjeta individual para cada contacto
  /// Los datos vienen del ContactoDTO del backend:
  /// - nombre: nombre completo del contacto
  /// - cargo: cargo en la empresa
  /// - telefono: número de teléfono
  /// - email: correo electrónico
  /// - empresa: empresa a la que pertenece
  /// - tipoNombre: tipo de contacto (EMPLEADO, PROVEEDOR, CLIENTE, OTROS)
  /// Al pulsar, muestra opciones (Editar/Eliminar)
  Widget _buildContactoCard(int index) {
    final contacto = contactos[index];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        child: InkWell(
          onTap: () => _mostrarOpcionesContacto(index),
          borderRadius: BorderRadius.circular(12),
          splashColor: const Color(0xFF4A3B2A).withValues(alpha: 0.1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF4A3B2A), width: 2),
            ),
            child: Row(
              children: [
                // Icono de persona
                const Icon(
                  Icons.account_circle_outlined,
                  size: 36,
                  color: Color(0xFF4A3B2A),
                ),
                const SizedBox(width: 12),

                // Nombre y cargo/empresa del contacto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contacto['nombre'] ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4A3B2A),
                        ),
                      ),

                      /// Muestra cargo y empresa si están disponibles
                      if ((contacto['cargo'] ?? '').isNotEmpty ||
                          (contacto['empresa'] ?? '').isNotEmpty)
                        Text(
                          [
                            contacto['cargo'] ?? '',
                            contacto['empresa'] ?? '',
                          ].where((s) => s.isNotEmpty).join(' — '),
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(
                              0xFF4A3B2A,
                            ).withValues(alpha: 0.7),
                          ),
                        ),
                    ],
                  ),
                ),

                // Icono de llamada
                InkWell(
                  onTap: () {
                    final telefono = contacto['telefono'] ?? '';

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text(
                          'Teléfono de contacto',
                          style: TextStyle(
                            color: Color(0xFF4A3B2A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: SelectableText(
                          telefono,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF4A3B2A),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Cerrar',
                              style: TextStyle(color: Color(0xFF4A3B2A)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.phone_outlined,
                      size: 22,
                      color: Color(0xFF4A3B2A),
                    ),
                  ),
                ),
                const SizedBox(width: 4),

                // Icono de mensaje
                InkWell(
                  onTap: () {
                    final mensajeController = TextEditingController();
                    final destinatario = contacto['nombre'] ?? 'Desconocido';

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Enviar mensaje a $destinatario'),
                        content: TextField(
                          controller: mensajeController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: 'Escribe tu mensaje...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Mensaje enviado a $destinatario'),
                                  backgroundColor: const Color(0xFF4A3B2A),
                                ),
                              );
                            },
                            child: const Text('Enviar'),
                          ),
                        ],
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.chat_bubble_outline,
                      size: 22,
                      color: Color(0xFF4A3B2A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // DIÁLOGOS
  /// Muestra un diálogo con opciones para el contacto seleccionado:
  /// - Editar contacto
  /// - Eliminar contacto
  /// - Cancelar
  void _mostrarOpcionesContacto(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Opciones del contacto',
          style: TextStyle(
            color: Color(0xFF4A3B2A),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Editar contacto'),
              onTap: () {
                /// Cierra el diálogo de opciones antes de abrir el formulario
                Navigator.pop(context);
                _mostrarDialogoEditar(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Eliminar contacto'),
              onTap: () {
                /// Cierra el diálogo de opciones antes de mostrar confirmación
                Navigator.pop(context);
                _confirmarEliminacion(index);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              /// Cierra el diálogo sin realizar ninguna acción
              Navigator.pop(context);
            },
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF4A3B2A)),
            ),
          ),
        ],
      ),
    );
  }

  /// Muestra diálogo de confirmación antes de eliminar un contacto
  void _confirmarEliminacion(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '¿Eliminar contacto?',
          style: TextStyle(
            color: Color(0xFF4A3B2A),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este contacto?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              /// Cierra el diálogo sin eliminar
              Navigator.pop(context);
            },
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF4A3B2A)),
            ),
          ),
          TextButton(
            onPressed: () async {
              final contacto = contactos[index];
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);
              try {
                await ContactService.eliminar(contacto['id']);
                await _cargarContactos();

                if (!mounted) return;
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Contacto eliminado correctamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Error al eliminar el contacto'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Prepara y muestra el formulario para agregar un nuevo contacto
  void _mostrarDialogoAgregar() {
    _limpiarFormulario();
    _mostrarDialogoFormulario('Nuevo contacto', null);
  }

  /// Prepara y muestra el formulario para editar un contacto existente
  /// Prellena los campos con los datos actuales del contacto
  void _mostrarDialogoEditar(int index) {
    final contacto = contactos[index];
    _nombreController.text = contacto['nombre'] ?? '';
    _telefonoController.text = contacto['telefono'] ?? '';
    _emailController.text = contacto['email'] ?? '';
    _empresaController.text = contacto['empresa'] ?? '';
    _cargoController.text = contacto['cargo'] ?? '';
    _mostrarDialogoFormulario('Editar contacto', index);
  }

  /// Muestra el formulario en un AlertDialog
  void _mostrarDialogoFormulario(String titulo, int? index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          titulo,
          style: const TextStyle(
            color: Color(0xFF4A3B2A),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _campoTexto(controller: _nombreController, label: 'Nombre'),
              _campoTexto(
                controller: _telefonoController,
                label: 'Teléfono',
                esNumerico: true,
              ),
              _campoTexto(controller: _emailController, label: 'Email'),
              _campoTexto(controller: _cargoController, label: 'Cargo'),
              _campoTexto(controller: _empresaController, label: 'Empresa'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              /// Cierra el formulario sin guardar
              Navigator.pop(context);
            },
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF4A3B2A)),
            ),
          ),
          TextButton(
            onPressed: () {
              if (_validarFormulario()) {
                if (index == null) {
                  _agregarContacto();
                } else {
                  _editarContacto(index);
                }

                /// Cierra el formulario tras guardar
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Guardar',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGETS DE FORMULARIO
  /// Widget reutilizable para campos de texto del formulario
  Widget _campoTexto({
    required TextEditingController controller,
    required String label,
    bool esNumerico = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: esNumerico ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF4A3B2A)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF4A3B2A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF4A3B2A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF4A3B2A), width: 2),
          ),
        ),
      ),
    );
  }

  // LÓGICA DE DATOS
  /// Valida que los campos obligatorios estén completos
  bool _validarFormulario() {
    if (_nombreController.text.isEmpty || _telefonoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre y el teléfono son obligatorios'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  /// Agrega un nuevo contacto llamando al ContactService
  /// Envía los datos del formulario al backend y recarga la lista
  Future<void> _agregarContacto() async {
    try {
      await ContactService.crear({
        'nombre': _nombreController.text,
        'telefono': _telefonoController.text,
        'email': _emailController.text,
        'cargo': _cargoController.text,
        'empresa': _empresaController.text,
        'activo': true,

        /// Tipo por defecto: 4 = OTROS
        'tipo': {'id': 4},
      });

      /// Recarga la lista desde el backend tras crear
      await _cargarContactos();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contacto añadido correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al añadir el contacto'),
          backgroundColor: Colors.red,
        ),
      );
    }
    _limpiarFormulario();
  }

  /// Edita un contacto existente llamando al ContactService
  /// Envía los datos actualizados al backend y recarga la lista
  Future<void> _editarContacto(int index) async {
    final contacto = contactos[index];
    try {
      await ContactService.actualizar(contacto['id'], {
        'nombre': _nombreController.text,
        'telefono': _telefonoController.text,
        'email': _emailController.text,
        'cargo': _cargoController.text,
        'empresa': _empresaController.text,
        'activo': contacto['activo'],
        'tipo': {'id': contacto['tipoId'] ?? 4},
      });

      /// Recarga la lista desde el backend tras editar
      await _cargarContactos();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contacto actualizado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al actualizar el contacto'),
          backgroundColor: Colors.red,
        ),
      );
    }
    _limpiarFormulario();
  }

  /// Limpia todos los campos del formulario
  void _limpiarFormulario() {
    _nombreController.clear();
    _telefonoController.clear();
    _emailController.clear();
    _cargoController.clear();
    _empresaController.clear();
  }

  // BOTTOM NAVIGATION BAR
  /// isSelected: true en people porque estamos en Contactos
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF4A3B2A)),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.people_outline,
                isSelected: true,
                onTap: () {
                  // Ya estamos en Contactos
                },
              ),
              _buildNavItem(
                icon: Icons.bar_chart_outlined,
                isSelected: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReportPage()),
                  );
                },
              ),
              _buildNavItem(
                icon: Icons.home,
                isSelected: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DashboardPage(),
                    ),
                  );
                },
              ),
              _buildNavItem(
                icon: Icons.notifications_outlined,
                isSelected: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationPage(),
                    ),
                  );
                },
              ),
              _buildNavItem(
                icon: Icons.settings_outlined,
                isSelected: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ConfigurationPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget reutilizable para cada ítem de la bottom bar
  /// InkWell + Padding + Icon tamaño 28
  /// InkWell muestra la mano automáticamente al pasar el ratón
  /// Color beige completo si activo, semi-transparente si no
  Widget _buildNavItem({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Icon(
          icon,
          size: 28,
          color: isSelected
              ? const Color(0xFFF6E9C9)
              : const Color(0xFFF6E9C9).withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
