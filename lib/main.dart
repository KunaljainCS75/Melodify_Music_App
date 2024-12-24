import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/theme/theme.dart';
import 'package:client/features/auth/view/pages/signup_page.dart';
import 'package:client/features/home/view/pages/home_page.dart';
import 'package:client/viewmodel/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:just_audio_background/just_audio_background.dart';
// import 'package:hive/hive.dart';
// import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Local Storage initialization
  await Hive.initFlutter();
  await Hive.openBox('mybox');

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  final container = ProviderContainer(); // RiverPod: to get all 'ref' linking methods at one place (done to access ref)
  await container.read(authViewmodelProvider.notifier).initSharedPreferences();
  await container.read(authViewmodelProvider.notifier).getData();
  
  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserNotifierProvider);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Melodify',
        theme: AppTheme.darkThemeMode,
        home: currentUser == null ? const SignupPage() : const HomePage());
  }
}
