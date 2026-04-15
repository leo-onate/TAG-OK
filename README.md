TAG OK

TAG OK es una aplicación móvil que permite a los conductores anticipar y gestionar los costos asociados al uso de autopistas con sistema TAG en Santiago de Chile.

Descripción

La aplicación permite simular trayectos y estimar el costo de peajes antes de realizar un viaje, entregando mayor control sobre el gasto en transporte.

Funcionalidades principales

La aplicación actualmente contempla un conjunto de funcionalidades orientadas a la planificación y control del gasto. Entre ellas se incluye el registro de vehículos, la simulación de rutas a partir de un origen y destino, la estimación de costos de TAG y la visualización de información relevante para el usuario.

Además, se proyecta incorporar visualización de historial, alertas de presupuesto y reportes de uso en futuras iteraciones del MVP.

Tecnologías

El proyecto está desarrollado utilizando Flutter con Dart para el frontend, siguiendo una arquitectura MVVM. Como backend se utiliza Firebase para la gestión de datos, autenticación y servicios en la nube.

Para funcionalidades específicas se integran servicios externos como TollGuru para el cálculo de peajes y Mapbox para la visualización de mapas y rutas.

Instalación y ejecución

Para ejecutar el proyecto de forma local:

Clonar el repositorio
Ejecutar flutter pub get
Configurar las variables necesarias (Firebase y APIs)
Ejecutar flutter run
Estado del proyecto

El proyecto se encuentra en desarrollo como MVP en el contexto de la asignatura TPY1101 de Duoc UC (2026).

Estructura del proyecto

El código se organiza bajo una arquitectura modular basada en MVVM, separando la lógica de negocio, la capa de datos y la interfaz de usuario para facilitar el mantenimiento y la escalabilidad.

Equipo

Grupo Sentte
Jesús Aránguiz
Ignacio Bravo
Leonardo Oñate
