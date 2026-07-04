import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app/sprout_app.dart';

void main() {
  runApp(const ProviderScope(child: SproutApp()));
}
