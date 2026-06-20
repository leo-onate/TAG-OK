import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'file_downloader.dart';

import 'login_screen.dart';
import 'admin_firestore_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno encriptadas en memoria
  try {
    const b64Env = "V0VCX0FQSV9LRVk9QUl6YVN5Qm1YVnZZejNsalpXRjROQ2tfMndGQ01Cc0VmTEJkZzF3DQpXRUJfQVBQX0lEPTE6MTU5MTUwNjQzNjM6d2ViOmFmZmVlNDg4NDU0YTYyZDVmYmRlNmUNCkFORFJPSURfQVBJX0tFWT1BSXphU3lEd3N5cXJpMDkyUGFhbFFzRjNDMnpueVRtTk9DaDVSSjANCkFORFJPSURfQVBQX0lEPTE6MTU5MTUwNjQzNjM6YW5kcm9pZDoyNmQ1NThmZTgyZjU5MTZjZmJkZTZlDQpJT1NfQVBJX0tFWT1BSXphU3lEcS02cGRBY0g4Z0FrT0VZT3A0SHpjWDVBQzF5cUl6eWsNCklPU19BUFBfSUQ9MToxNTkxNTA2NDM2Mzppb3M6YTg2ZDRjNGE5NTY0ZDgxM2ZiZGU2ZQ0KTUVTU0FHSU5HX1NFTkRFUl9JRD0xNTkxNTA2NDM2Mw0KUFJPSkVDVF9JRD10YWctb2sNClNUT1JBR0VfQlVDS0VUPXRhZy1vay5maXJlYmFzZXN0b3JhZ2UuYXBwDQpJT1NfQlVORExFX0lEPWNvbS5leGFtcGxlLnRhZ09rDQpNQVBCT1hfQUNDRVNTX1RPS0VOPXBrLmV5SjFJam9pYW1WemRYTmhjbUZ1WjNWcGVqSTVJaXdpWVNJNkltTnRiM0p3YlRkcU5UQTNZWGN5YzI5bGRXZDBiVGhyY1c0aWZRLkR6LTdHUFEwRlI0aGRKRjJYWHI4N0ENCkdFTUlOSV9BUElfS0VZPUFRLkFiOFJONkpDdlUxLTEyNWc3TGxJcHVGVzFDUncxdWRWbnhqRW81bEVSUmMxbDZKSnB3DQo=";
    // Decodificar Base64
    final envText = utf8.decode(base64Decode(b64Env));
    dotenv.testLoad(fileInput: envText);
  } catch (_) {
    debugPrint('TAG_OK_ADMIN: no se pudo cargar variables en memoria');
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const TagOkAdminApp());
}

class TagOkAdminApp extends StatelessWidget {
  const TagOkAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TAG OK Admin',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0EA5E9),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
      ),
       home: const AdminAuthGate(),
    );
  }
}

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  final AdminFirestoreService _service = AdminFirestoreService();
  int _selectedIndex = 0;

  static const List<String> _pages = <String>[
    'Dashboard',
    'Usuarios',
    'Pórticos',
    'Tarifas',
    'Reportes',
  ];

  @override
  Widget build(BuildContext context) {
    final Widget content = switch (_selectedIndex) {
      0 => DashboardPage(service: _service),
      1 => UsersPage(service: _service),
      2 => PorticosPage(service: _service),
      3 => TariffsPage(service: _service),
      _ => ReportsPage(service: _service),
    };

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 280,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF111827)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: _BrandBlock(),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Backoffice',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _pages.length,
                      itemBuilder: (context, index) {
                        final bool selected = _selectedIndex == index;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            selected: selected,
                            selectedTileColor: const Color(0xFF1E293B),
                            iconColor: selected ? const Color(0xFF38BDF8) : const Color(0xFFCBD5E1),
                            textColor: selected ? Colors.white : const Color(0xFFCBD5E1),
                            leading: Icon(_iconFor(index)),
                            title: Text(_pages[index]),
                            onTap: () => setState(() => _selectedIndex = index),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(color: Color(0xFF1E293B)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      iconColor: const Color(0xFFEF4444),
                      textColor: const Color(0xFFEF4444),
                      leading: const Icon(Icons.logout),
                      title: const Text('Cerrar sesión'),
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: _AdminHintCard(),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: content),
        ],
      ),
    );
  }

  IconData _iconFor(int index) {
    return switch (index) {
      0 => Icons.dashboard_outlined,
      1 => Icons.people_alt_outlined,
      2 => Icons.toll_outlined,
      3 => Icons.payments_outlined,
      _ => Icons.bar_chart_outlined,
    };
  }
}

class _BrandBlock extends StatelessWidget {
  const _BrandBlock();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LogoMark(),
        SizedBox(height: 16),
        Text(
          'TAG OK',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Panel de administración web',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF0EA5E9).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.route_outlined, color: Color(0xFF38BDF8), size: 32),
    );
  }
}

class _AdminHintCard extends StatelessWidget {
  const _AdminHintCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acceso interno',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8),
          Text(
            'Este panel comparte el mismo Firestore que la app final. Usa roles para restringir edición y publicación.',
            style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.service});

  final AdminFirestoreService service;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AdminOverview>(
      future: service.fetchOverview(),
      builder: (context, snapshot) {
        final AdminOverview? overview = snapshot.data;
        return _AdminPageScaffold(
          title: 'Dashboard',
          subtitle: 'Estado general del sistema, datos vigentes y accesos rápidos.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _StatCard(label: 'Usuarios', value: overview?.users ?? 0, icon: Icons.people_alt_outlined),
                  _StatCard(label: 'Vehículos', value: overview?.vehicles ?? 0, icon: Icons.directions_car_outlined),
                  _StatCard(label: 'Pórticos', value: overview?.porticos ?? 0, icon: Icons.toll_outlined),
                  _StatCard(label: 'Tarifas', value: overview?.tariffs ?? 0, icon: Icons.payments_outlined),
                ],
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final bool isNarrow = constraints.maxWidth < 1000;
                  final Widget left = _InfoCard(
                    title: 'Alertas y actividad reciente',
                    child: const Text(
                      'Este módulo quedará conectado a bitácora, alertas y cambios publicados.\n\nPróximo paso sugerido: mostrar últimos cambios en pórticos y tarifas.',
                    ),
                  );
                  final Widget right = _InfoCard(
                    title: 'Accesos rápidos',
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: const [
                        _QuickAction(label: 'Usuarios', icon: Icons.people_alt_outlined),
                        _QuickAction(label: 'Pórticos', icon: Icons.toll_outlined),
                        _QuickAction(label: 'Tarifas', icon: Icons.payments_outlined),
                        _QuickAction(label: 'Reportes', icon: Icons.bar_chart_outlined),
                      ],
                    ),
                  );

                  if (isNarrow) {
                    return Column(
                      children: [
                        left,
                        const SizedBox(height: 16),
                        right,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: left),
                      const SizedBox(width: 16),
                      Expanded(child: right),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class UsersPage extends StatefulWidget {
  const UsersPage({super.key, required this.service});

  final AdminFirestoreService service;

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedBudgetFilter = 'Todos'; // 'Todos', '> 50.000', '< = 50.000'
  int _currentPage = 0;
  int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.toLowerCase().trim();
        _currentPage = 0;
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _matchesFilters(Map<String, dynamic> data) {
    final nombre = (data['nombre_mostrar'] ?? '').toString().toLowerCase();
    final correo = (data['email'] ?? '').toString().toLowerCase();
    if (_searchQuery.isNotEmpty && !nombre.contains(_searchQuery) && !correo.contains(_searchQuery)) {
      return false;
    }

    final int presupuesto = int.tryParse(data['limite_presupuesto_mensual']?.toString() ?? '0') ?? 0;
    if (_selectedBudgetFilter == '> 50.000' && presupuesto <= 50000) {
      return false;
    }
    if (_selectedBudgetFilter == '< = 50.000' && presupuesto > 50000) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return _AdminPageScaffold(
      title: 'Usuarios',
      subtitle: 'Gestión de cuentas. (Por seguridad de Firebase, las contraseñas están encriptadas. Usa las acciones para resetearlas).',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        isDense: true,
                        labelText: 'Buscar usuario...',
                        hintText: 'Buscar por nombre o correo',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedBudgetFilter,
                      decoration: InputDecoration(
                        isDense: true,
                        labelText: 'Presupuesto Mensual',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Todos', child: Text('Todos los presupuestos')),
                        DropdownMenuItem(value: '> 50.000', child: Text('> \$50.000')),
                        DropdownMenuItem(value: '< = 50.000', child: Text('≤ \$50.000')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedBudgetFilter = val;
                            _currentPage = 0;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: widget.service.streamUsers(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error al leer Firestore: ${snapshot.error}');
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;
                final filteredDocs = docs.where((doc) => _matchesFilters(doc.data())).toList();

                if (filteredDocs.isEmpty) {
                  return const Card(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No se encontraron usuarios con los filtros aplicados.'),
                      ),
                    ),
                  );
                }

                final int totalPages = (filteredDocs.length / _rowsPerPage).ceil();
                if (_currentPage >= totalPages && totalPages > 0) {
                  _currentPage = totalPages - 1;
                }

                final int startIndex = _currentPage * _rowsPerPage;
                final int endIndex = (startIndex + _rowsPerPage) > filteredDocs.length
                    ? filteredDocs.length
                    : (startIndex + _rowsPerPage);
                final pageDocs = filteredDocs.sublist(startIndex, endIndex);

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Usuario')),
                                  DataColumn(label: Text('Presupuesto')),
                                  DataColumn(label: Text('Vehículo Principal')),
                                  DataColumn(label: Text('Acciones')),
                                ],
                                rows: pageDocs.map((doc) {
                                  final Map<String, dynamic> data = doc.data();
                                  final String docId = doc.id;
                                  final String nombre = (data['nombre_mostrar'] ?? 'Sin nombre').toString();
                                  final String correo = (data['email'] ?? 'Sin correo').toString();
                                  final int presupuesto = int.tryParse(data['limite_presupuesto_mensual']?.toString() ?? '0') ?? 0;
                                  final String vehiculoPrincipal = (data['vehiculo_principal_id'] ?? 'Ninguno').toString();

                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CircleAvatar(
                                              radius: 18,
                                              backgroundColor: _getColorFromName(nombre),
                                              child: Text(
                                                nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U',
                                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                                Text(correo, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: presupuesto > 50000 
                                                ? const Color(0xFFEEF2FF)
                                                : const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: presupuesto > 50000 
                                                  ? const Color(0xFFC7D2FE) 
                                                  : const Color(0xFFE2E8F0),
                                            ),
                                          ),
                                          child: Text(
                                            '\$${_formatNumber(presupuesto)}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: presupuesto > 50000 
                                                  ? const Color(0xFF4F46E5) 
                                                  : const Color(0xFF475569),
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.directions_car_filled_outlined, size: 16, color: Color(0xFF64748B)),
                                            const SizedBox(width: 6),
                                            Text(
                                              vehiculoPrincipal,
                                              style: const TextStyle(color: Color(0xFF334155), fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                                              tooltip: 'Editar Presupuesto',
                                              onPressed: () {
                                                _mostrarDialogoEdicion(context, docId, nombre, presupuesto);
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.lock_reset_outlined, color: Colors.orange, size: 20),
                                              tooltip: 'Restablecer Contraseña',
                                              onPressed: () {
                                                _enviarResetPassword(context, correo);
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                              tooltip: 'Eliminar Usuario',
                                              onPressed: () {
                                                _mostrarDialogoEliminar(context, docId, nombre);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        const Divider(),
                        _TablePaginationControls(
                          currentPage: _currentPage,
                          rowsPerPage: _rowsPerPage,
                          totalItems: filteredDocs.length,
                          totalPages: totalPages,
                          startIndex: startIndex,
                          endIndex: endIndex,
                          onPageChanged: (page) => setState(() => _currentPage = page),
                          onRowsPerPageChanged: (rows) => setState(() {
                            _rowsPerPage = rows;
                            _currentPage = 0;
                          }),
                          itemLabel: 'usuarios',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoEdicion(BuildContext context, String docId, String nombreActual, int limiteActual) {
    final TextEditingController nombreCtrl = TextEditingController(text: nombreActual);
    final TextEditingController limiteCtrl = TextEditingController(text: limiteActual.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Editar Usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre a mostrar'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: limiteCtrl,
              decoration: const InputDecoration(labelText: 'Límite Mensual (\$)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0EA5E9)),
            onPressed: () {
              final nuevoLimite = int.tryParse(limiteCtrl.text) ?? limiteActual;
              FirebaseFirestore.instance.collection('usuarios').doc(docId).update({
                'nombre_mostrar': nombreCtrl.text,
                'limite_presupuesto_mensual': nuevoLimite,
              });
              Navigator.pop(context);
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _enviarResetPassword(BuildContext context, String correo) async {
    if (correo == 'Sin correo') return;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: correo);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Correo de restablecimiento enviado a $correo'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar correo: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _mostrarDialogoEliminar(BuildContext context, String docId, String nombre) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Eliminar Usuario'),
        content: Text('¿Estás seguro que deseas eliminar el registro y los datos de $nombre? Esta acción es irreversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0EA5E9)),
            onPressed: () {
              FirebaseFirestore.instance.collection('usuarios').doc(docId).delete();
              Navigator.pop(context);
            },
            child: const Text('Sí, Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class PorticosPage extends StatefulWidget {
  const PorticosPage({super.key, required this.service});

  final AdminFirestoreService service;

  @override
  State<PorticosPage> createState() => _PorticosPageState();
}

class _PorticosPageState extends State<PorticosPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedHighwayFilter = 'Todas';
  String _selectedDirectionFilter = 'Todos';
  int _currentPage = 0;
  int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.toLowerCase().trim();
        _currentPage = 0;
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _matchesFilters(Map<String, dynamic> rawData) {
    final Map<String, dynamic> data = (rawData.containsKey('datos') && rawData['datos'] is Map)
        ? Map<String, dynamic>.from(rawData['datos'])
        : rawData;

    final nombre = (data['nombre'] ?? data['autopista'] ?? '').toString().toLowerCase();
    if (_searchQuery.isNotEmpty && !nombre.contains(_searchQuery)) {
      return false;
    }

    final autopista = (data['autopista'] ?? '').toString();
    if (_selectedHighwayFilter != 'Todas' && autopista != _selectedHighwayFilter) {
      return false;
    }

    final sentido = (data['sentido'] ?? '').toString();
    if (_selectedDirectionFilter != 'Todos' && sentido != _selectedDirectionFilter) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return _AdminPageScaffold(
      title: 'Pórticos',
      subtitle: 'Catálogo operativo compartido con la app final. Administra las tarifas aquí.',
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: widget.service.streamPorticos(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error al leer Firestore: ${snapshot.error}');
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          final Set<String> highwaysSet = {};
          for (var doc in docs) {
            final rawData = doc.data();
            final data = (rawData.containsKey('datos') && rawData['datos'] is Map)
                ? Map<String, dynamic>.from(rawData['datos'])
                : rawData;
            final String h = (data['autopista'] ?? '').toString();
            if (h.isNotEmpty) {
              highwaysSet.add(h);
            }
          }
          final List<String> uniqueHighways = highwaysSet.toList()..sort();

          if (_selectedHighwayFilter != 'Todas' && !highwaysSet.contains(_selectedHighwayFilter)) {
            _selectedHighwayFilter = 'Todas';
          }

          final filteredDocs = docs.where((doc) => _matchesFilters(doc.data())).toList();

          final int totalPages = (filteredDocs.length / _rowsPerPage).ceil();
          if (_currentPage >= totalPages && totalPages > 0) {
            _currentPage = totalPages - 1;
          }

          final int startIndex = _currentPage * _rowsPerPage;
          final int endIndex = (startIndex + _rowsPerPage) > filteredDocs.length
              ? filteredDocs.length
              : (startIndex + _rowsPerPage);
          final pageDocs = filteredDocs.sublist(startIndex, endIndex);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _searchCtrl,
                          decoration: InputDecoration(
                            isDense: true,
                            labelText: 'Buscar pórtico...',
                            hintText: 'Buscar por nombre',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedHighwayFilter,
                          decoration: InputDecoration(
                            isDense: true,
                            labelText: 'Autopista',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          items: [
                            const DropdownMenuItem(value: 'Todas', child: Text('Todas las autopistas')),
                            ...uniqueHighways.map((h) => DropdownMenuItem(value: h, child: Text(h))),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedHighwayFilter = val;
                                _currentPage = 0;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedDirectionFilter,
                          decoration: InputDecoration(
                            isDense: true,
                            labelText: 'Sentido',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                            DropdownMenuItem(value: 'N-S', child: Text('N-S')),
                            DropdownMenuItem(value: 'S-N', child: Text('S-N')),
                            DropdownMenuItem(value: 'O-P', child: Text('O-P')),
                            DropdownMenuItem(value: 'P-O', child: Text('P-O')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedDirectionFilter = val;
                                _currentPage = 0;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: filteredDocs.isEmpty
                    ? const Card(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text('No se encontraron pórticos con los filtros aplicados.'),
                          ),
                        ),
                      )
                    : Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      columns: const [
                                        DataColumn(label: Text('Pórtico')),
                                        DataColumn(label: Text('Sentido')),
                                        DataColumn(label: Text('Tarifa Base')),
                                        DataColumn(label: Text('Tarifa Punta')),
                                        DataColumn(label: Text('Tarifa Saturación')),
                                        DataColumn(label: Text('Acciones')),
                                      ],
                                      rows: pageDocs.map((doc) {
                                        final Map<String, dynamic> rawData = doc.data();
                                        final String docId = doc.id;
                                        
                                        final bool isNested = rawData.containsKey('datos') && rawData['datos'] is Map;
                                        final Map<String, dynamic> data = isNested
                                            ? Map<String, dynamic>.from(rawData['datos'])
                                            : rawData;

                                        final String nombre = (data['nombre'] ?? data['autopista'] ?? 'Sin nombre').toString();
                                        final String autopista = (data['autopista'] ?? '').toString();
                                        final String sentido = (data['sentido'] ?? '-').toString();
                                        final String base = (data['tarifa_base'] ?? data['costo'] ?? data['Tarifa_Base'] ?? data['Tarifa Base'] ?? '0').toString();
                                        final String punta = (data['tarifa_punta'] ?? data['costoPunta'] ?? data['Tarifa_Punta'] ?? data['Tarifa Punta'] ?? '0').toString();
                                        final String saturacion = (data['tarifa_saturacion'] ?? data['costoSaturacion'] ?? data['Tarifa_Saturacion'] ?? data['Tarifa Saturacion'] ?? '0').toString();

                                        return DataRow(
                                          cells: [
                                            DataCell(
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                                  const SizedBox(height: 4),
                                                  _getHighwayBadge(autopista),
                                                ],
                                              ),
                                            ),
                                            DataCell(
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF1F5F9),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  sentido,
                                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569), fontSize: 12),
                                                ),
                                              ),
                                            ),
                                            DataCell(_buildTariffBadge('Base', _formatNumber(double.tryParse(base)?.round() ?? 0), const Color(0xFFEFF6FF), const Color(0xFF1D4ED8))),
                                            DataCell(_buildTariffBadge('Punta', _formatNumber(double.tryParse(punta)?.round() ?? 0), const Color(0xFFFFF7ED), const Color(0xFFC2410C))),
                                            DataCell(_buildTariffBadge('Sat.', _formatNumber(double.tryParse(saturacion)?.round() ?? 0), const Color(0xFFFFF1F2), const Color(0xFFBE123C))),
                                            DataCell(
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                                                    tooltip: 'Editar Tarifas',
                                                    onPressed: () {
                                                      _mostrarDialogoEdicion(context, docId, nombre, base, punta, saturacion, isNested);
                                                    },
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                                    tooltip: 'Eliminar Pórtico',
                                                    onPressed: () {
                                                      _mostrarDialogoEliminar(context, docId, nombre);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                              const Divider(),
                              _TablePaginationControls(
                                currentPage: _currentPage,
                                rowsPerPage: _rowsPerPage,
                                totalItems: filteredDocs.length,
                                totalPages: totalPages,
                                startIndex: startIndex,
                                endIndex: endIndex,
                                onPageChanged: (page) => setState(() => _currentPage = page),
                                onRowsPerPageChanged: (rows) => setState(() {
                                  _rowsPerPage = rows;
                                  _currentPage = 0;
                                }),
                                itemLabel: 'pórticos',
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _mostrarDialogoEdicion(BuildContext context, String docId, String nombre, String baseActual, String puntaActual, String saturacionActual, bool isNested) {
    final TextEditingController baseCtrl = TextEditingController(text: baseActual);
    final TextEditingController puntaCtrl = TextEditingController(text: puntaActual);
    final TextEditingController saturacionCtrl = TextEditingController(text: saturacionActual);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Editar Tarifas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pórtico: $nombre', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: baseCtrl,
              decoration: const InputDecoration(labelText: 'Tarifa Base (\$)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: puntaCtrl,
              decoration: const InputDecoration(labelText: 'Tarifa Punta (\$)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: saturacionCtrl,
              decoration: const InputDecoration(labelText: 'Tarifa Saturación (\$)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0EA5E9)),
            onPressed: () {
              final double? nBase = double.tryParse(baseCtrl.text.replaceAll(',', '.'));
              final double? nPunta = double.tryParse(puntaCtrl.text.replaceAll(',', '.'));
              final double? nSaturacion = double.tryParse(saturacionCtrl.text.replaceAll(',', '.'));

              final Map<String, dynamic> updates = {};
              
              if (nBase != null) {
                updates[isNested ? 'datos.tarifa_base' : 'tarifa_base'] = nBase;
              }
              if (nPunta != null) {
                updates[isNested ? 'datos.tarifa_punta' : 'tarifa_punta'] = nPunta;
              }
              if (nSaturacion != null) {
                updates[isNested ? 'datos.tarifa_saturacion' : 'tarifa_saturacion'] = nSaturacion;
              }

              if (updates.isNotEmpty) {
                FirebaseFirestore.instance.collection('porticos').doc(docId).update(updates);
              }
              Navigator.pop(context);
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoEliminar(BuildContext context, String docId, String nombre) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Eliminar Pórtico'),
        content: Text('¿Estás seguro que deseas eliminar el pórtico "$nombre"? Esta acción es irreversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              FirebaseFirestore.instance.collection('porticos').doc(docId).delete();
              Navigator.pop(context);
            },
            child: const Text('Sí, Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class TariffsPage extends StatelessWidget {
  const TariffsPage({super.key, required this.service});

  final AdminFirestoreService service;

  String _formatFecha(dynamic dateVal) {
    if (dateVal == null) return '-';
    if (dateVal is Timestamp) {
      final date = dateVal.toDate();
      final y = date.year;
      final m = date.month.toString().padLeft(2, '0');
      final d = date.day.toString().padLeft(2, '0');
      final h = date.hour.toString().padLeft(2, '0');
      final min = date.minute.toString().padLeft(2, '0');
      return '$y-$m-$d $h:$min';
    }
    final String str = dateVal.toString();
    if (str.length >= 16) {
      return str.substring(0, 16).replaceAll('T', ' ');
    }
    return str;
  }

  void _mostrarDetalleViaje(BuildContext context, Map<String, dynamic> tripData) {
    final List<dynamic> tollsList = tripData['tolls'] as List<dynamic>? ?? [];
    final String vehiculo = (tripData['vehicleName'] ?? 'Desconocido').toString();
    final String fecha = _formatFecha(tripData['date']);
    final int totalCost = int.tryParse(tripData['totalCost']?.toString() ?? '0') ?? 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.route_outlined, color: Color(0xFF0EA5E9), size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Detalle de Peajes - $vehiculo',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fecha: $fecha', style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(
                'Costo Total: \$${_formatNumber(totalCost)}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 16),
              ),
              const Divider(height: 24),
              const Text(
                'Pórticos Cruzados:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 12),
              if (tollsList.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No hay pórticos registrados en este viaje.',
                    style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF94A3B8)),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: tollsList.length,
                    itemBuilder: (context, index) {
                      final toll = tollsList[index];
                      if (toll is! Map) return const SizedBox();
                      final String name = (toll['name'] ?? 'Pórtico').toString();
                      final int cost = int.tryParse(toll['cost']?.toString() ?? '0') ?? 0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(color: Color(0xFF334155), fontWeight: FontWeight.w500),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '\$${_formatNumber(cost)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(color: Color(0xFF0EA5E9), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _AdminPageScaffold(
      title: 'Tarifas y Viajes de Usuarios',
      subtitle: 'Historial de cobros y viajes de los usuarios registrado por GPS.',
      child: _FirestoreListTable(
        stream: service.streamUserTrips(),
        emptyMessage: 'No hay viajes registrados aún.',
        itemLabel: 'viajes',
        columns: const ['Vehículo', 'Fecha', 'Distancia', 'Duración', 'Cobro Total', 'Acciones'],
        rowBuilder: (doc) {
          final Map<String, dynamic> data = doc.data();
          final String vehiculo = (data['vehicleName'] ?? 'Desconocido').toString();
          final String fecha = _formatFecha(data['date']);
          final double distance = double.tryParse(data['distanceKm']?.toString() ?? '0') ?? 0.0;
          final String duracion = (data['duration'] ?? '-').toString();
          final int totalCost = int.tryParse(data['totalCost']?.toString() ?? '0') ?? 0;

          return [
            DataCell(
              Row(
                children: [
                  const Icon(Icons.directions_car_filled_outlined, size: 18, color: Color(0xFF0EA5E9)),
                  const SizedBox(width: 8),
                  Text(
                    vehiculo,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
            ),
            DataCell(
              Text(
                fecha,
                style: const TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w500),
              ),
            ),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.linear_scale_rounded, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(
                      '${distance.toStringAsFixed(1)} km',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(duracion, style: const TextStyle(color: Color(0xFF334155))),
                ],
              ),
            ),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Text(
                  '\$${_formatNumber(totalCost)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF065F46),
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            DataCell(
              Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.info_outline_rounded, color: Color(0xFF0EA5E9)),
                    tooltip: 'Ver Detalle de Peajes',
                    onPressed: () {
                      _mostrarDetalleViaje(context, data);
                    },
                  );
                }
              ),
            ),
          ];
        },
      ),
    );
  }
}

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key, required this.service});

  final AdminFirestoreService service;

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  late Future<ReportMetrics> _metricsFuture;

  @override
  void initState() {
    super.initState();
    _metricsFuture = widget.service.fetchReportMetrics();
  }

  void _refresh() {
    setState(() {
      _metricsFuture = widget.service.fetchReportMetrics();
    });
  }

  String _formatCurrency(double val) {
    final int value = val.round();
    final String str = value.toString();
    final StringBuffer buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return '\$${buffer.toString().split('').reversed.join('')}';
  }

  Future<void> _exportToCSV(BuildContext context, ReportMetrics metrics) async {
    try {
      final StringBuffer csvBuffer = StringBuffer();
      csvBuffer.write('\uFEFF');
      
      csvBuffer.writeln('REPORTE GENERAL DE MÉTRICAS Y ESTADÍSTICAS - TAG OK');
      csvBuffer.writeln('Fecha de Generación: ${DateTime.now().toLocal()}');
      csvBuffer.writeln();
      
      csvBuffer.writeln('MÉTRICA,VALOR');
      csvBuffer.writeln('Total Usuarios,${metrics.totalUsers}');
      csvBuffer.writeln('Total Vehículos,${metrics.totalVehicles}');
      csvBuffer.writeln('Total Viajes,${metrics.totalTrips}');
      csvBuffer.writeln('Costo Total Peajes (\$),${metrics.totalTollCost.toStringAsFixed(0)}');
      csvBuffer.writeln('Costo Promedio por Viaje (\$),${metrics.averageCostPerTrip.toStringAsFixed(0)}');
      csvBuffer.writeln();
      
      csvBuffer.writeln('DISTRIBUCIÓN POR AUTOPISTA');
      csvBuffer.writeln('Autopista,Costo Total (\$),Porcentaje (%)');
      
      final double total = metrics.totalTollCost;
      metrics.costByHighway.forEach((highway, cost) {
        final double pct = total > 0 ? (cost / total) * 100 : 0.0;
        csvBuffer.writeln('$highway,${cost.toStringAsFixed(0)},${pct.toStringAsFixed(2)}%');
      });

      saveFile(csvBuffer.toString(), 'reporte_tag_ok.csv');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              kIsWeb
                  ? 'Reporte descargado exitosamente'
                  : 'Reporte exportado exitosamente a: C:/Users/igna_/Downloads/reporte_tag_ok.csv',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'CERRAR',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar CSV: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Color> _getGradientForHighway(String highway) {
    switch (highway) {
      case 'Autopista Central':
        return [const Color(0xFF0EA5E9), const Color(0xFF2563EB)];
      case 'Costanera Norte':
        return [const Color(0xFF10B981), const Color(0xFF059669)];
      case 'Vespucio Norte':
        return [const Color(0xFFF59E0B), const Color(0xFFD97706)];
      case 'Vespucio Sur':
        return [const Color(0xFFEC4899), const Color(0xFFD946EF)];
      case 'Vespucio Oriente (AVO)':
        return [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)];
      default:
        return [const Color(0xFF64748B), const Color(0xFF475569)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AdminPageScaffold(
      title: 'Reportes y Estadísticas',
      subtitle: 'Monitoreo consolidado de ingresos por peaje, uso de vías y descargas de informes.',
      child: FutureBuilder<ReportMetrics>(
        future: _metricsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Error al cargar reportes',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${snapshot.error}',
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando y consolidando métricas desde Firestore...', style: TextStyle(color: Color(0xFF64748B))),
                ],
              ),
            );
          }

          final metrics = snapshot.data;
          if (metrics == null) {
            return const Card(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No hay datos disponibles.'),
                ),
              ),
            );
          }

          final sortedHighways = metrics.costByHighway.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0EA5E9),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                      ),
                      onPressed: () => _exportToCSV(context, metrics),
                      icon: const Icon(Icons.download_rounded, size: 20),
                      label: const Text(
                        'Exportar Resumen a CSV',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Actualizar Datos',
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _ReportStatCard(
                      title: 'Usuarios',
                      value: metrics.totalUsers.toString(),
                      icon: Icons.people_outline_rounded,
                      iconColor: const Color(0xFF0EA5E9),
                      gradientColors: const [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
                    ),
                    _ReportStatCard(
                      title: 'Vehículos',
                      value: metrics.totalVehicles.toString(),
                      icon: Icons.directions_car_outlined,
                      iconColor: const Color(0xFF10B981),
                      gradientColors: const [Color(0xFF10B981), Color(0xFF34D399)],
                    ),
                    _ReportStatCard(
                      title: 'Total Viajes',
                      value: metrics.totalTrips.toString(),
                      icon: Icons.route_outlined,
                      iconColor: const Color(0xFFF59E0B),
                      gradientColors: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                    ),
                    _ReportStatCard(
                      title: 'Total Peajes',
                      value: _formatCurrency(metrics.totalTollCost),
                      icon: Icons.monetization_on_outlined,
                      iconColor: const Color(0xFF8B5CF6),
                      gradientColors: const [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                    ),
                    _ReportStatCard(
                      title: 'Promedio por Viaje',
                      value: _formatCurrency(metrics.averageCostPerTrip),
                      icon: Icons.analytics_outlined,
                      iconColor: const Color(0xFFEC4899),
                      gradientColors: const [Color(0xFFEC4899), Color(0xFFF472B6)],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isNarrow = constraints.maxWidth < 900;
                    
                    final Widget chartWidget = Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Distribución de Costos por Autopista',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 24),
                            ...sortedHighways.map((entry) {
                              final double pct = metrics.totalTollCost > 0 ? (entry.value / metrics.totalTollCost) : 0.0;
                              final List<Color> colors = _getGradientForHighway(entry.key);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          entry.key,
                                          style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                                        ),
                                        Text(
                                          '${_formatCurrency(entry.value)} (${(pct * 100).toStringAsFixed(1)}%)',
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      height: 12,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: FractionallySizedBox(
                                        widthFactor: pct,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: colors,
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                            borderRadius: BorderRadius.circular(6),
                                            boxShadow: [
                                              BoxShadow(
                                                color: colors[0].withValues(alpha: 0.2),
                                                blurRadius: 4,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );

                    final Widget tableWidget = Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Resumen Tabular de Ingresos',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 16),
                            Table(
                              columnWidths: const {
                                0: FlexColumnWidth(2),
                                1: FlexColumnWidth(1),
                                2: FlexColumnWidth(1),
                              },
                              border: const TableBorder(
                                horizontalInside: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                              ),
                              children: [
                                const TableRow(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                      child: Text('Autopista', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                      child: Text('Gasto', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                      child: Text('Porcentaje', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                    ),
                                  ],
                                ),
                                ...sortedHighways.map((entry) {
                                  final double pct = metrics.totalTollCost > 0 ? (entry.value / metrics.totalTollCost) * 100 : 0.0;
                                  return TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        child: Text(entry.key, style: const TextStyle(color: Color(0xFF334155), fontWeight: FontWeight.w500)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        child: Text(_formatCurrency(entry.value), style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        child: Text('${pct.toStringAsFixed(1)}%', style: const TextStyle(color: Color(0xFF64748B))),
                                      ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );

                    if (isNarrow) {
                      return Column(
                        children: [
                          chartWidget,
                          const SizedBox(height: 24),
                          tableWidget,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: chartWidget),
                        const SizedBox(width: 24),
                        Expanded(flex: 2, child: tableWidget),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ReportStatCard extends StatelessWidget {
  const _ReportStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.gradientColors,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 215,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      gradientColors[0].withValues(alpha: 0.15),
                      gradientColors[1].withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminPageScaffold extends StatelessWidget {
  const _AdminPageScaffold({required this.title, required this.subtitle, required this.child});

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -0.8),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
            const SizedBox(height: 24),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon});

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xFF0EA5E9)),
              const SizedBox(height: 18),
              Text(
                value.toString(),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(color: Color(0xFF64748B))),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon),
      label: Text(label),
    );
  }
} 


class _TablePaginationControls extends StatelessWidget {
  const _TablePaginationControls({
    required this.currentPage,
    required this.rowsPerPage,
    required this.totalItems,
    required this.totalPages,
    required this.startIndex,
    required this.endIndex,
    required this.onPageChanged,
    required this.onRowsPerPageChanged,
    required this.itemLabel,
  });

  final int currentPage;
  final int rowsPerPage;
  final int totalItems;
  final int totalPages;
  final int startIndex;
  final int endIndex;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onRowsPerPageChanged;
  final String itemLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Mostrando ${totalItems == 0 ? 0 : startIndex + 1} - $endIndex de $totalItems $itemLabel',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              const Text('Filas por página: ', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: rowsPerPage,
                items: [5, 10, 20, 50].map((int val) {
                  return DropdownMenuItem<int>(
                    value: val,
                    child: Text('$val', style: const TextStyle(fontSize: 13)),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    onRowsPerPageChanged(newValue);
                  }
                },
                underline: const SizedBox(),
              ),
              const SizedBox(width: 24),
              IconButton(
                icon: const Icon(Icons.first_page_rounded),
                onPressed: currentPage > 0 ? () => onPageChanged(0) : null,
                tooltip: 'Primera página',
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
                tooltip: 'Página anterior',
              ),
              const SizedBox(width: 8),
              Text(
                'Pág. ${currentPage + 1} de ${totalPages == 0 ? 1 : totalPages}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 13),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: currentPage < totalPages - 1 ? () => onPageChanged(currentPage + 1) : null,
                tooltip: 'Siguiente página',
              ),
              IconButton(
                icon: const Icon(Icons.last_page_rounded),
                onPressed: currentPage < totalPages - 1 ? () => onPageChanged(totalPages - 1) : null,
                tooltip: 'Última página',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FirestoreListTable extends StatefulWidget {
  const _FirestoreListTable({
    required this.stream,
    required this.emptyMessage,
    required this.columns,
    required this.rowBuilder,
    required this.itemLabel,
  });

  final Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> stream;
  final String emptyMessage;
  final List<String> columns;
  final List<DataCell> Function(QueryDocumentSnapshot<Map<String, dynamic>>) rowBuilder;
  final String itemLabel;

  @override
  State<_FirestoreListTable> createState() => _FirestoreListTableState();
}

class _FirestoreListTableState extends State<_FirestoreListTable> {
  int _currentPage = 0;
  int _rowsPerPage = 10;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
          stream: widget.stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error al leer Firestore: ${snapshot.error}');
            }

            if (!snapshot.hasData) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = snapshot.data!;
            if (docs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(widget.emptyMessage),
                ),
              );
            }

            final int totalPages = (docs.length / _rowsPerPage).ceil();
            if (_currentPage >= totalPages && totalPages > 0) {
              _currentPage = totalPages - 1;
            }

            final int startIndex = _currentPage * _rowsPerPage;
            final int endIndex = (startIndex + _rowsPerPage) > docs.length
                ? docs.length
                : (startIndex + _rowsPerPage);
            final pageDocs = docs.sublist(startIndex, endIndex);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: widget.columns.map((String column) => DataColumn(label: Text(column))).toList(),
                        rows: pageDocs.map((doc) {
                          return DataRow(cells: widget.rowBuilder(doc));
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const Divider(),
                _TablePaginationControls(
                  currentPage: _currentPage,
                  rowsPerPage: _rowsPerPage,
                  totalItems: docs.length,
                  totalPages: totalPages,
                  startIndex: startIndex,
                  endIndex: endIndex,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  onRowsPerPageChanged: (rows) => setState(() {
                    _rowsPerPage = rows;
                    _currentPage = 0;
                  }),
                  itemLabel: widget.itemLabel,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

String _formatNumber(int val) {
  final String str = val.toString();
  final StringBuffer buffer = StringBuffer();
  int count = 0;
  for (int i = str.length - 1; i >= 0; i--) {
    buffer.write(str[i]);
    count++;
    if (count % 3 == 0 && i != 0) {
      buffer.write('.');
    }
  }
  return buffer.toString().split('').reversed.join('');
}

Color _getColorFromName(String name) {
  final int hash = name.hashCode;
  final List<Color> colors = [
    const Color(0xFF0EA5E9),
    const Color(0xFF10B981),
    const Color(0xFF6366F1),
    const Color(0xFF8B5CF6),
    const Color(0xFFEC4899),
    const Color(0xFFF59E0B),
  ];
  return colors[hash.abs() % colors.length];
}

Widget _getHighwayBadge(String highway) {
  Color bgColor;
  Color textColor;
  switch (highway) {
    case 'Autopista Central':
      bgColor = const Color(0xFFEFF6FF);
      textColor = const Color(0xFF1D4ED8);
      break;
    case 'Costanera Norte':
      bgColor = const Color(0xFFECFDF5);
      textColor = const Color(0xFF047857);
      break;
    case 'Vespucio Norte':
      bgColor = const Color(0xFFFFFBEB);
      textColor = const Color(0xFFB45309);
      break;
    case 'Vespucio Sur':
      bgColor = const Color(0xFFFDF2F8);
      textColor = const Color(0xFFBE185D);
      break;
    case 'Vespucio Oriente (AVO)':
      bgColor = const Color(0xFFF5F3FF);
      textColor = const Color(0xFF6D28D9);
      break;
    default:
      bgColor = const Color(0xFFF8FAFC);
      textColor = const Color(0xFF475569);
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: textColor.withValues(alpha: 0.15)),
    ),
    child: Text(
      highway,
      style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 11),
    ),
  );
}

Widget _buildTariffBadge(String label, String value, Color bgColor, Color textColor) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: textColor.withValues(alpha: 0.15)),
    ),
    child: Text(
      '$label: \$$value',
      style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 11),
    ),
  );
}
