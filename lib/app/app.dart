import '../core/localization/locale_cubit.dart';
import '../core/localization/locale_state.dart';
import '../l10n/app_localizations.dart';
import '../sync/sync_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

import '../features/clients_patients/domain/repositories/patient_repository.dart';
import '../features/clinical_cases/domain/repositories/case_repository.dart';
import '../features/staff_profile/domain/repositories/staff_repository.dart';
import '../features/media/domain/repositories/media_repository.dart';

/// Root Application Widget for VetManager Mobile Client.
class VetManagerApp extends StatefulWidget {
  final IAuthRepository? authRepository;
  final AuthBloc? authBloc;
  final LocaleCubit? localeCubit;
  final IPatientRepository? patientRepository;
  final ICaseRepository? caseRepository;
  final IStaffRepository? staffRepository;
  final IMediaRepository? mediaRepository;
  final SyncManager? syncManager;

  const VetManagerApp({
    super.key,
    this.authRepository,
    this.authBloc,
    this.localeCubit,
    this.patientRepository,
    this.caseRepository,
    this.staffRepository,
    this.mediaRepository,
    this.syncManager,
  });

  @override
  State<VetManagerApp> createState() => _VetManagerAppState();
}

class _VetManagerAppState extends State<VetManagerApp> {
  late final AuthBloc _authBloc;
  late final LocaleCubit _localeCubit;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authBloc = widget.authBloc ??
        AuthBloc(
          authRepository: widget.authRepository ?? AuthRepository(),
        );

    _localeCubit = widget.localeCubit ?? LocaleCubit();

    _appRouter = AppRouter(
      authBloc: _authBloc,
      authRepository: widget.authRepository,
      patientRepository: widget.patientRepository,
      caseRepository: widget.caseRepository,
      staffRepository: widget.staffRepository,
      mediaRepository: widget.mediaRepository,
      syncManager: widget.syncManager,
    );
    _authBloc.add(const AuthCheckRequested());
  }

  @override
  void dispose() {
    if (widget.authBloc == null) {
      _authBloc.close();
    }
    if (widget.localeCubit == null) {
      _localeCubit.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repoProviders = <RepositoryProvider<dynamic>>[
      if (widget.caseRepository != null)
        RepositoryProvider<ICaseRepository>.value(value: widget.caseRepository!),
      if (widget.patientRepository != null)
        RepositoryProvider<IPatientRepository>.value(value: widget.patientRepository!),
      if (widget.staffRepository != null)
        RepositoryProvider<IStaffRepository>.value(value: widget.staffRepository!),
      if (widget.mediaRepository != null)
        RepositoryProvider<IMediaRepository>.value(value: widget.mediaRepository!),
    ];

    final app = MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<LocaleCubit>.value(value: _localeCubit),
      ],
      child: BlocBuilder<LocaleCubit, LocaleState>(
        builder: (context, localeState) {
          return MaterialApp.router(
            title: 'VetManager',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightThemeForLocale(localeState.locale),
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            locale: localeState.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            routerConfig: _appRouter.router,
          );
        },
      ),
    );

    if (repoProviders.isEmpty) {
      return app;
    }

    return MultiRepositoryProvider(
      providers: repoProviders,
      child: app,
    );
  }
}
