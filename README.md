# WhatsWeb

WhatsWeb es un proyecto Flutter que proporciona una interfaz personalizada para acceder a WhatsApp Web desde una aplicación móvil. La aplicación permite a los usuarios navegar por WhatsApp Web con funciones adicionales, como la gestión de temas (oscuro y claro), manejo de descargas y navegación dentro de la propia aplicación.

## Características

- **Navegador Web Integrado:** Accede a la versión web de WhatsApp directamente desde la aplicación usando `flutter_inappwebview`.
- **Gestión de Temas:** Cambia entre los temas oscuro y claro, con la opción de guardar la preferencia del tema usando `SharedPreferences`.
- **Manejo de Descargas:** Descarga archivos desde WhatsApp Web utilizando `FlutterDownloader`.
- **Menú de Opciones:** Incluye un menú lateral para cambiar de tema, recargar la página o cerrar la aplicación.
- **Permisos Gestionados:** Solicita permisos esenciales, como el uso del micrófono, para mejorar la experiencia de WhatsApp Web.

## Paquetes Utilizados

- `flutter_downloader`: Para gestionar descargas desde la web.
- `flutter_inappwebview`: Para integrar un navegador web dentro de la aplicación.
- `path_provider`: Para obtener rutas de almacenamiento en el dispositivo.
- `permission_handler`: Para manejar permisos del dispositivo.
- `shared_preferences`: Para guardar preferencias de usuario, como el estado del tema.


