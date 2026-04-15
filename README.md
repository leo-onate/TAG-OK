---

🚗 TAG OK

Un copiloto financiero para tus viajes en autopistas

TAG OK es una aplicación móvil desarrollada por el Grupo Sentte que permite a los conductores anticipar, visualizar y controlar los costos asociados al uso de autopistas con sistema TAG en la Región Metropolitana de Santiago.


---

📌 Descripción del Proyecto

Actualmente, los conductores no cuentan con herramientas que les permitan conocer el costo de un trayecto antes de realizarlo. La información se encuentra fragmentada entre distintas concesionarias y se presenta de forma posterior, lo que dificulta la toma de decisiones.

TAG OK busca resolver este problema mediante una solución que integra simulación de rutas, estimación de costos y visualización del gasto, permitiendo al usuario tomar decisiones informadas antes de viajar.


---

🎯 Objetivo

Desarrollar una aplicación móvil que permita a los usuarios anticipar y gestionar el gasto en autopistas, mejorando la planificación de sus desplazamientos.


---

⚙️ Tecnologías Utilizadas

Frontend: Flutter (Dart)

Arquitectura: MVVM

Backend: Firebase (Firestore, Auth, Cloud Messaging)

APIs externas:

TollGuru → Cálculo de peajes

Mapbox → Mapas y rutas


Networking: Dio

Gestión de estado: Riverpod



---

🧩 Funcionalidades (MVP)

Registro y gestión de vehículos

Simulación de viajes (origen/destino)

Estimación de costos de TAG

Visualización de rutas en mapa

Dashboard con gasto acumulado

Historial de viajes

Alertas básicas de presupuesto



---

📱 Alcance del Proyecto

El proyecto corresponde al desarrollo de un Producto Mínimo Viable (MVP) que permite:

Simular trayectos dentro de Santiago

Estimar costos de autopistas antes del viaje

Visualizar el gasto del usuario


⚠️ No incluye:

Integración directa con concesionarias

Pagos o recargas de TAG

Conexión con dispositivos físicos



---

🏗️ Arquitectura

El sistema sigue una arquitectura modular tipo MVVM, permitiendo escalabilidad y mantenimiento eficiente.

View: Interfaz en Flutter

ViewModel: Lógica de presentación (Riverpod)

Model: Datos provenientes de Firebase y APIs externas



---

🚀 Estado del Proyecto

🔧 En desarrollo – Fase 1 (Definición y diseño del MVP)
📅 Proyecto académico – TPY1101 Duoc UC (2026)


---

📂 Estructura del Repositorio (Inicial)

lib/
 ├── core/
 ├── data/
 ├── domain/
 ├── presentation/
 └── main.dart


---

👥 Equipo

Jesús Aránguiz

Ignacio Bravo

Leonardo Oñate



---

📊 Factibilidad

El proyecto está diseñado para operar bajo capas gratuitas, utilizando Firebase y APIs externas en sus planes free, lo que permite un desarrollo inicial con costo $0.


---

📌 Futuras mejoras

Optimización de rutas por costo

Integración con más fuentes de datos

Alertas inteligentes avanzadas

Funcionalidades B2B



---

📄 Licencia

Proyecto académico – uso educativo.