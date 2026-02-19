import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../settings/ai_prefs.dart';

final aiPrefsProvider = Provider<AiPrefs>((ref) => AiPrefs());