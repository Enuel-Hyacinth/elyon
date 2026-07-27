import 'package:flutter/material.dart';
import '../core/theme/theme.dart';

import '../features/auth/presentation/auth_wrapper.dart';
import 'package:provider/provider.dart';

import '../features/dashboard/controllers/dashboard_controller.dart';

class ELyonApp extends StatelessWidget {
  const ELyonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(

  providers: [

    ChangeNotifierProvider(

      create: (_) => DashboardController()
        ..initialize(),

    ),

  ],

  child: MaterialApp(

    title: 'eLyon',

    debugShowCheckedModeBanner: false,

    theme: AppTheme.darkTheme,

    home: const AuthWrapper(),

  ),

);
  }
}