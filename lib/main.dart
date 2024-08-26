import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterDownloader.initialize(debug: false, ignoreSsl: true);
  await Permission.microphone.request();

  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  bool _isDarkTheme = false;

  @override
  void initState() {
    super.initState();
    _loadTheme(); // Cargar el tema almacenado
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkTheme = prefs.getBool('isDarkTheme') ?? false; // Cargar el tema, por defecto es falso (claro)
    });
  }

  Future<void> _saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkTheme', isDark); // Guardar el estado del tema
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WhatsWeb',
      theme: _isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      home: WebwhatsPage(
        isDarkTheme: _isDarkTheme,
        onThemeChanged: (bool isDark) {
          setState(() {
            _isDarkTheme = isDark;
            _saveTheme(isDark); // Guardar el cambio de tema
          });
        },
      ),
    );
  }
}

const desktopUserAgent =
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.54 Safari/537.36";
const webWhatsappUrl = "https://web.whatsapp.com/🌎/en/";

class WebwhatsPage extends StatefulWidget {
  final bool isDarkTheme;
  final Function(bool) onThemeChanged;

  const WebwhatsPage({
    Key? key,
    required this.isDarkTheme,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  _WebwhatsPageState createState() => _WebwhatsPageState();
}

class _WebwhatsPageState extends State<WebwhatsPage> {
  InAppWebViewController? _webViewController;

  @override
  Widget build(BuildContext context) {
    final settings = InAppWebViewSettings(
      userAgent: desktopUserAgent,
      allowFileAccessFromFileURLs: true,
      allowUniversalAccessFromFileURLs: true,
      useOnDownloadStart: true,
      allowsInlineMediaPlayback: true,
    );
    
    final contextMenu = ContextMenu(
      settings: ContextMenuSettings(hideDefaultSystemContextMenuItems: true), // Oculta el menú contextual predeterminado
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("WhatsWeb"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _webViewController?.reload();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Text(
                'Opciones',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.brightness_6),
              title: Text('Cambiar Tema'),
              onTap: () {
                widget.onThemeChanged(!widget.isDarkTheme);
                Navigator.of(context).pop(); // Cerrar el Drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.refresh),
              title: Text('Recargar Página'),
              onTap: () {
                _webViewController?.reload();
                Navigator.of(context).pop(); // Cerrar el Drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Salir'),
              onTap: () {
                Navigator.of(context).pop(); // Cerrar el Drawer
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(webWhatsappUrl)),
          initialSettings: settings,
          contextMenu: contextMenu,
          onWebViewCreated: (InAppWebViewController controller) {
            _webViewController = controller;
          },
          onPermissionRequest: (controller, request) async =>
              PermissionResponse(
                  resources: request.resources,
                  action: PermissionResponseAction.GRANT),
          onLoadStop: (controller, url) async {
            // Inyectar CSS para ocultar la marca de agua o elementos no deseados
            await controller.evaluateJavascript(source: """
              var style = document.createElement('style');
              style.innerHTML = '.marca-de-agua { display: none !important; }'; // Cambia '.marca-de-agua' por el selector correcto
              document.head.appendChild(style);
            """);
          },
          onDownloadStartRequest: (controller, url) async {
            await FlutterDownloader.enqueue(
              url: url.url.toString(),
              savedDir: (await getExternalStorageDirectory())!.path,
              showNotification: false,  // Ocultar la notificación de descarga
              openFileFromNotification: false, // No abrir el archivo desde la notificación
            );
          },
        ),
      ),
    );
  }

  @override
  Future<bool> onWillPop() async {
    if (_webViewController != null) {
      if (await _webViewController!.canGoBack()) {
        _webViewController!.goBack();
        return false;
      }
    }
    return true;
  }
}
