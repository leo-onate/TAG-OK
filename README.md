# Tag OK 🚗💨

**Tu copiloto inteligente para el control de gastos de TAG y navegación en tiempo real.**

> Optimiza tus rutas, gestiona tu presupuesto mensual y nunca más te sorprendas con la cuenta del TAG.

[![Flutter](https://img.shields.io/badge/Flutter-3.41.9-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.11.5-blue.svg)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Cloud%20Firestore-orange.svg)](https://firebase.google.com/)
[![Mapbox](https://img.shields.io/badge/Mapbox-GL%20Maps-000000.svg)](https://www.mapbox.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

<a name="tabla-de-contenidos"></a>
## 📋 Tabla de Contenidos

- [Descripción](#descripcion)
- [Características Principales](#caracteristicas-principales)
- [Dashboard & Visualización](#dashboard-visualizacion)
- [Gestión de Vehículos](#gestion-de-vehiculos)
- [Control de Presupuesto](#control-de-presupuesto)
- [Stack Tecnológico](#stack-tecnologico)
- [Instalación y Configuración](#instalacion-configuracion)
- [Estructura del Proyecto](#estructura-proyecto)
- [Documentación de Base de Datos](#base-de-datos)

---

<a name="descripcion"></a>
## 📝 Descripción

**Tag OK** es una aplicación móvil diseñada para el conductor moderno que transita por las autopistas urbanas concesionadas de Chile. A diferencia de un GPS convencional, Tag OK integra un motor de cálculo de tarifas actualizado al año **2026**, permitiendo conocer el costo exacto de cada viaje antes de encender el motor.

Con una interfaz **Glassmorphism** premium y notificaciones inteligentes de presupuesto, la app te ayuda a mantener tus finanzas bajo control mientras navegas con precisión.

---

<a name="caracteristicas-principales"></a>
## ✨ Características Principales

### 🛰️ Navegación Inteligente
- Cálculo de rutas óptimas utilizando la API de Mapbox.
- Detección automática de pórticos de TAG en el trayecto.
- Visualización de tarifas dinámicas: TBFP (Base), TBP (Punta) y TS (Saturación).

### 📊 Auditoría y Historial
- Registro detallado de cada viaje: hora, distancia, duración y costo exacto.
- Desglose de cada pórtico atravesado con su respectiva tarifa y hora de paso.
- Historial vinculado a la **patente específica** del vehículo utilizado.

### 🚗 Gestión de Flotas
- Registro ilimitado de vehículos (Marca, Modelo, Patente).
- Confirmación obligatoria del vehículo antes de iniciar cada navegación para asegurar la trazabilidad del gasto.
- Identificación visual de vehículos mediante badges de patentes.

---

<a name="dashboard-visualizacion"></a>
## 🖼️ Dashboard & Visualización

El nuevo **Centro de Control** utiliza un diseño de vanguardia con:
- **Glassmorphism**: Paneles flotantes con desenfoque de fondo (`BackdropFilter`) para una estética premium.
- **Widgets de Estado**: Saludo personalizado y estado de protección activa en tiempo real.
- **Monitor de Gasto**: Acceso rápido al porcentaje de presupuesto consumido directamente desde el mapa.

---

<a name="gestion-de-vehiculos"></a>
## 🚗 Gestión de Vehículos

Mantenemos un control exhaustivo de tu flota:
- Vinculación de vehículos a tu cuenta personal.
- Selección dinámica de vehículo activo para el cálculo de tarifas (Motos, Autos, Camionetas).
- Persistencia de datos en la nube para acceder desde cualquier dispositivo.

---

<a name="control-de-presupuesto"></a>
## 💰 Control de Presupuesto

Implementamos un sistema de alertas dinámicas para evitar exceder tus límites mensuales:
- **Alertas de Umbral**: Notificaciones automáticas al alcanzar el **50%**, **75%**, **90%** y **100%** del presupuesto definido.
- **Memoria de Notificaciones**: El sistema recuerda qué alertas ya has visto este mes para evitar interrupciones innecesarias en cada viaje.
- **Semaforización Visual**:
  - 🟣 **Violeta**: Gasto normal (< 50%).
  - 🟢 **Verde**: Alerta informativa (50%).
  - 🟡 **Amarillo**: Precaución (75%).
  - 🟠 **Naranja**: Crítico (90%).
  - 🔴 **Rojo**: Límite excedido (100%).

---

<a name="stack-tecnologico"></a>
## 🛠️ Stack Tecnológico

| Componente | Tecnología |
| :--- | :--- |
| **Framework** | Flutter 3.41.9 (Stable) |
| **Lenguaje** | Dart 3.11.5 |
| **Base de Datos** | Firebase Cloud Firestore |
| **Autenticación** | Firebase Auth |
| **Mapas** | Flutter Map + Mapbox API |
| **Estado** | Riverpod / StateNotifier |
| **Estilos** | Custom Glassmorphism System |

---

<a name="instalacion-configuracion"></a>
## 🚀 Instalación y Configuración

### Prerrequisitos
- Flutter SDK instalado.
- Cuenta en Mapbox para obtener un Access Token.
- Proyecto en Firebase con Firestore habilitado.

### Configuración
1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/tu-usuario/TAG-OK.git
   cd TAG-OK/Producto/tag_ok
   ```

2. **Configurar variables de entorno:**
   Crea un archivo `.env` en la raíz del proyecto:
   ```env
   MAPBOX_ACCESS_TOKEN=tu_token_aqui
   ```

3. **Instalar dependencias:**
   ```bash
   flutter pub get
   ```

4. **Ejecutar:**
   ```bash
   flutter run
   ```

---

<a name="estructura-proyecto"></a>
## 📂 Estructura del Proyecto

```bash
lib/
├── data/
│   ├── models/       # Modelos de datos (Trip, Vehicle, Route)
│   ├── mock/         # Base de datos de pórticos 2026
│   └── services/     # Lógica de Firebase, Mapas y Cálculo
├── screens/          # Vistas (Home, Audit, Profile, Vehicles)
├── widgets/          # Componentes reutilizables
└── main.dart         # Punto de entrada y configuración de Firebase
```

---

<a name="base-de-datos"></a>
## 🗄️ Documentación de Base de Datos

Para una revisión técnica profunda del esquema de datos y la arquitectura NoSQL, consulta los siguientes recursos:

- 📄 [Informe de Arquitectura de Datos](Producto/Base%20de%20datos/DOCUMENTACION_BASE_DE_DATOS.md)
- 📂 [Exportación Completa (JSON)](Producto/Base%20de%20datos/EXPORTACION_BASE_DE_DATOS.json)

---
*Desarrollado con ❤️ para el ecosistema vial chileno.*
