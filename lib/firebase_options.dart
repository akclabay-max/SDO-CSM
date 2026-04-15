import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // For Android
    return const FirebaseOptions(
      apiKey: 'AIzaSyDZ1VhOno8fgfpceZVj7kFtjK7hQwPTOM4',
      appId: '1:902923024616:web:52df9e2bbb4eb15659f15d',
      messagingSenderId: '902923024616',
      projectId: 'sdo-csm-baguio',
      storageBucket: "sdo-csm-baguio.firebasestorage.app",
    );
  }
}