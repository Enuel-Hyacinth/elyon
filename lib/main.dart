import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/supabase_config.dart';


import 'firebase_options.dart';
import 'app/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  SupabaseService._();

  static final client = Supabase.instance.client;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint(
    "Gemini Key Loaded: ${dotenv.env['GEMINI_API_KEY']}",
  );
  

await Supabase.initialize(
  url: SupabaseConfig.url,
  publishableKey: SupabaseConfig.anonKey,
);

  runApp(
    const ELyonApp(),
  );
}