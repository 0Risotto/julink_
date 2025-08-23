import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:julink/core/configs/theme/app_theme.dart';
import 'package:julink/dev/test/signinpagetest.dart';
import 'package:julink/presentation/choose_mode/bloc/theme_cubit.dart';
import 'package:julink/presentation/home/pages/profile/bloc/profile_cubit.dart';
import 'package:path_provider/path_provider.dart';

// import your profile related stuff
import 'package:julink/data/repository/profile/profile_repository.dart';
import 'package:julink/data/sources/profile/profile_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final bool _testMode = true;

  @override
  Widget build(BuildContext context) {
    final profileService = ProfileService();
    final profileRepository = ProfileRepository(profileService: profileService);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(
          create: (_) => ProfileCubit(profileRepository: profileRepository),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, mode) => MaterialApp(
          theme: AppTheme.lightTheme,
          themeMode: mode,
          darkTheme: AppTheme.darkTheme,
          debugShowCheckedModeBanner: false,
          home: testingSigninPage(),
        ),
      ),
    );
  }
}
