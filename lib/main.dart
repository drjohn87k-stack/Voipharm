import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_request_app/l10n/app_localizations.dart';

import 'core/services/locale_service.dart';
import 'core/services/license_service.dart';
import 'core/theme/app_theme.dart';
import 'features/items/presentation/bloc/items_bloc.dart';
import 'features/request/presentation/bloc/request_builder_bloc.dart';
import 'features/history/presentation/bloc/history_bloc.dart';
import 'features/home/presentation/home_shell.dart';
import 'features/license/presentation/license_activation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MedicalRequestApp());
}

class MedicalRequestApp extends StatefulWidget {
  const MedicalRequestApp({super.key});

  @override
  State<MedicalRequestApp> createState() => _MedicalRequestAppState();
}

class _MedicalRequestAppState extends State<MedicalRequestApp> {
  final LocaleService _locale = LocaleService.instance;
  final LicenseService _license = LicenseService.instance;
  bool _ready = false;
  bool _activated = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _locale.load();
    await _license.load();
    if (mounted) {
      setState(() {
        _ready = true;
        _activated = _license.isActivated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_locale]),
      builder: (context, _) {
        if (!_ready) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(),
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        return MultiBlocProvider(
          providers: [
            BlocProvider<ItemsBloc>(create: (_) => ItemsBloc()),
            BlocProvider<RequestBuilderBloc>(
                create: (_) => RequestBuilderBloc()),
            BlocProvider<HistoryBloc>(create: (_) => HistoryBloc()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Medical Request Voice App',
            theme: AppTheme.lightTheme(),
            locale: _locale.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) {
              // Apply RTL/LTR direction to the whole app.
              return Directionality(
                textDirection: _locale.textDirection,
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: _activated
                ? const HomeShell()
                : LicenseActivationScreen(
                    onActivated: () => setState(() => _activated = true),
                  ),
          ),
        );
      },
    );
  }
}
