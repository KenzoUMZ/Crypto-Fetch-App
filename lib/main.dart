import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import 'core/core.dart';
import 'repositories/asset_repository.dart';
import 'viewmodels/asset_view_model.dart';
import 'viewmodels/market_stream_view_model.dart';
import 'views/main_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  LocalJsonLocalization.delegate.directories = ['lib/i18n'];
  final apiKey = dotenv.env['COINCAP_API_KEY'];
  final apiClient = ApiClient(
    baseUrl: ApiEndpoints.baseUrl,
    defaultHeaders: {
      if (apiKey != null && apiKey.isNotEmpty)
        'Authorization': 'Bearer $apiKey',
    },
  );
  final assetRepository = AssetRepository(apiClient: apiClient);
  runApp(MainApp(assetRepository: assetRepository));
}

class MainApp extends StatelessWidget {
  final AssetRepository assetRepository;
  const MainApp({super.key, required this.assetRepository});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create:
              (_) =>
                  AssetViewModel(repository: assetRepository)
                    ..loadAssets(limit: 100),
        ),
        ChangeNotifierProvider(
          create: (_) => MarketStreamViewModel()..connectAndSubscribe(),
        ),
      ],
      child: MaterialApp(
        title: 'app_title'.translate(),
        supportedLocales: const [Locale('pt', 'BR')],
        localeResolutionCallback: (locale, supportedLocales) {
          if (supportedLocales.contains(locale)) {
            return locale;
          }

          return const Locale('pt', 'BR');
        },
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          LocalJsonLocalization.delegate,
        ],
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const MainView(),
      ),
    );
  }
}
