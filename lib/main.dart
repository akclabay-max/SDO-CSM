import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_csm/widgets/forms.dart';
import 'package:flutter_csm/widgets/background.dart';
import 'package:flutter_csm/widgets/footer.dart'; 
import 'package:flutter_csm/widgets/appbar.dart';
import 'package:flutter_csm/widgets/gradient_text.dart';
import 'package:flutter_csm/widgets/responsive_container.dart';
import 'package:flutter_csm/screens/admin/admin_login.dart';

    void main() async {
      WidgetsFlutterBinding.ensureInitialized();  // Required for async operations
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

      // Comment out emulator usage for now - requires Java installation
      // if (kDebugMode) {
      //   FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      // }

      runApp(const MyApp());
      
    }


    class MyApp extends StatelessWidget {
      const MyApp({super.key});

      @override
      Widget build(BuildContext context) {
        return MaterialApp(
          title: 'SDO BAGUIO - CSM',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 90, 156, 243),
            ),
            appBarTheme: const AppBarTheme(
              titleTextStyle: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: Colors.black,
                fontFamily: 'Roboto',
              ),
            ),
          ),
          home: const MyHomePage(title: 'SDO BAGUIO CITY'),
        );
      }
    }

    class MyHomePage extends StatefulWidget {
      const MyHomePage({super.key, required this.title});

      final String title;

      @override
      State<MyHomePage> createState() => _MyHomePageState();
    }

    class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive logo width
    double logoWidth;
    if (screenWidth < 480) {
      logoWidth = 80;
    } else if (screenWidth < 768) {
      logoWidth = 120;
    } else {
      logoWidth = 170;
    }
    
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'SDO BAGUIO CITY',
          backgroundColor: Colors.white,
          leading: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Image.asset(
              'assets/images/Logos.png',
              fit: BoxFit.contain,
              width: logoWidth,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, color: Colors.red);
              },
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminLoginPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.admin_panel_settings, size: 16),
                  label: const Text('Admin'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 90, 156, 243),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SimpleTiledBackground(
          pngPath: 'assets/images/bg.png',
          child: Column(
            mainAxisSize: MainAxisSize.min, // Minimize space usage
            children: [
              // Title section - MINIMAL PADDING
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0), // Very tight
                child: GradientText(
                  'CLIENT SATISFACTION MEASUREMENT',
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 90, 156, 243),
                      Color.fromARGB(255, 60, 120, 200),
                      Color.fromARGB(255, 40, 90, 160),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Form section - takes all remaining space
              Expanded(
                child: ResponsiveContainer(
                  maxWidth: 1000,
                  padding: EdgeInsets.zero,
                  child: const ServiceForm(),
                ),
              ),
              // Footer
              const CustomFooter(
                systemName: "Client Satisfaction Measurement",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
