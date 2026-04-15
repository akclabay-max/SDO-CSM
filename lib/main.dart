import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_death_aide/widgets/forms.dart';
import 'package:flutter_death_aide/widgets/background.dart';
import 'package:flutter_death_aide/widgets/footer.dart'; 
import 'package:flutter_death_aide/widgets/appbar.dart';
import 'package:flutter_death_aide/widgets/gradient_text.dart';
import 'package:flutter_death_aide/widgets/responsive_container.dart';
import 'package:flutter_death_aide/screens/admin/admin_login.dart';

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
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth < 480 ? 8.0 : 16.0,
                  ),
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
                      icon: const Icon(Icons.admin_panel_settings),
                      label: const Text('Admin'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 90, 156, 243),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth < 480 ? 8.0 : 16.0,
                          vertical: screenWidth < 480 ? 6.0 : 10.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          body: SimpleTiledBackground(
            pngPath: 'assets/images/bg.png',
            child: Column(
              children: [
                // Title section
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width < 480 ? 12.0 : 16.0,
                    vertical: MediaQuery.of(context).size.width < 480 ? 12.0 : 16.0,
                  ),
                  child: GradientText(
                    'CLIENT SATISFACTION MEASUREMENT',
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 90, 156, 243),
                        Color.fromARGB(255, 60, 120, 200),
                        Color.fromARGB(255, 40, 90, 160),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width < 480 
                        ? 20 
                        : MediaQuery.of(context).size.width < 768
                          ? 28
                          : 35,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Form section - IMPORTANT: This needs to be expanded
                    Expanded(
                      child: ResponsiveContainer(
                        maxWidth: 1000,
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