import 'package:flutter/material.dart';
import 'package:pgphs_reunion/pages/admin_panel.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "PGPHS Reunion",
      debugShowCheckedModeBanner: false,
      home: AdminPanel(),

    );
  }
}
