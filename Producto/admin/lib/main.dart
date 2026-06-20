import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
      _ => const ReportsPage(),
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

class UsersPage extends StatelessWidget {
  const UsersPage({super.key, required this.service});

  final AdminFirestoreService service;

  @override
  Widget build(BuildContext context) {
    return _AdminPageScaffold(
      title: 'Usuarios',
      subtitle: 'Gestión de cuentas. (Por seguridad de Firebase, las contraseñas están encriptadas. Usa las acciones para resetearlas).',
      child: _FirestoreTable(
        stream: service.streamUsers(),
        emptyMessage: 'No hay usuarios aún.',
        columns: const ['Nombre', 'Correo', 'Presupuesto', 'Vehículo Principal', 'Acciones'],
        rowBuilder: (doc) {
          final Map<String, dynamic> data = doc.data();
          final String docId = doc.id;
          final String nombre = (data['nombre_mostrar'] ?? 'Sin nombre').toString();
          final String correo = (data['email'] ?? 'Sin correo').toString();
          final int presupuesto = int.tryParse(data['limite_presupuesto_mensual']?.toString() ?? '0') ?? 0;

          return [
            DataCell(Text(nombre)),
            DataCell(Text(correo)),
            DataCell(Text('\$$presupuesto')),
            DataCell(Text((data['vehiculo_principal_id'] ?? 'Ninguno').toString())),
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
          ];
        },
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
              Navigator.pop(context); // Cierra el diálogo
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              FirebaseFirestore.instance.collection('usuarios').doc(docId).delete();
              Navigator.pop(context); // Cierra el diálogo
            },
            child: const Text('Sí, Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class PorticosPage extends StatelessWidget {
  const PorticosPage({super.key, required this.service});

  final AdminFirestoreService service;

  @override
  Widget build(BuildContext context) {
    return _AdminPageScaffold(
      title: 'Pórticos',
      subtitle: 'Catálogo operativo compartido con la app final. Administra las tarifas aquí.',
      child: _FirestoreTable(
        stream: service.streamPorticos(),
        emptyMessage: 'No hay pórticos cargados.',
        columns: const ['Nombre', 'Sentido', 'Tarifa Base', 'Tarifa Punta', 'Tarifa Saturación', 'Acciones'],
        rowBuilder: (doc) {
          final Map<String, dynamic> rawData = doc.data();
          final String docId = doc.id;
          
          // Extraer información si está anidada dentro de un mapa llamado 'datos'
          final bool isNested = rawData.containsKey('datos') && rawData['datos'] is Map;
          final Map<String, dynamic> data = (rawData.containsKey('datos') && rawData['datos'] is Map)
              ? Map<String, dynamic>.from(rawData['datos'])
              : rawData;

          final String nombre = (data['nombre'] ?? data['autopista'] ?? 'Sin nombre').toString();
          final String sentido = (data['sentido'] ?? '-').toString();
          final String base = (data['tarifa_base'] ?? data['costo'] ?? data['Tarifa_Base'] ?? data['Tarifa Base'] ?? '0').toString();
          final String punta = (data['tarifa_punta'] ?? data['costoPunta'] ?? data['Tarifa_Punta'] ?? data['Tarifa Punta'] ?? '0').toString();
          final String saturacion = (data['tarifa_saturacion'] ?? data['costoSaturacion'] ?? data['Tarifa_Saturacion'] ?? data['Tarifa Saturacion'] ?? '0').toString();

          return [
            DataCell(Text(nombre)),
            DataCell(Text(sentido)),
            DataCell(Text('\$$base')),
            DataCell(Text('\$$punta')),
            DataCell(Text('\$$saturacion')),
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
          ];
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
              // Reemplazamos comas por puntos por si el administrador escribe "700,50"
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
              Navigator.pop(context); // Cierra el diálogo
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
              Navigator.pop(context); // Cierra el diálogo
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

  @override
  Widget build(BuildContext context) {
    return _AdminPageScaffold(
      title: 'Tarifas',
      subtitle: 'Vigencias, edición y publicación controlada.',
      child: _FirestoreTable(
        stream: service.streamTariffs(),
        emptyMessage: 'Todavía no existe la colección tarifas.',
        columns: const ['Nombre', 'Vigencia', 'Estado'],
        rowBuilder: (doc) {
          final Map<String, dynamic> data = doc.data();
          return [
            DataCell(Text((data['nombre'] ?? 'Tarifa').toString())),
            DataCell(Text((data['vigencia'] ?? data['fecha_actualizacion'] ?? '-').toString())),
            DataCell(Text((data['estado'] ?? 'borrador').toString())),
          ];
        },
      ),
    );
  }
}

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AdminPageScaffold(
      title: 'Reportes',
      subtitle: 'KPIs, exportación y trazabilidad operativa.',
      child: _InfoCard(
        title: 'Próxima fase',
        child: Text(
          'Aquí se conectarán gráficos, filtros por fecha y exportaciones.\n\nSiguiente paso natural: bitácora de cambios y reporte de pórticos/tarifas.',
        ),
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


class _FirestoreTable extends StatelessWidget {
  const _FirestoreTable({
    required this.stream,
    required this.emptyMessage,
    required this.columns,
    required this.rowBuilder,
  });

  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;
  final String emptyMessage;
  final List<String> columns;
  final List<DataCell> Function(QueryDocumentSnapshot<Map<String, dynamic>>) rowBuilder;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: stream,
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

            final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(emptyMessage),
                ),
              );
            }

            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: columns.map((String column) => DataColumn(label: Text(column))).toList(),
                  rows: docs.map((doc) {
                    return DataRow(cells: rowBuilder(doc));
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
