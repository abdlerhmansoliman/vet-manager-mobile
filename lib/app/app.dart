import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// Root Application Widget for VetManager Mobile Client.
class VetManagerApp extends StatefulWidget {
  final IAuthRepository? authRepository;
  final AuthBloc? authBloc;

  const VetManagerApp({
    super.key,
    this.authRepository,
    this.authBloc,
  });

  @override
  State<VetManagerApp> createState() => _VetManagerAppState();
}

class _VetManagerAppState extends State<VetManagerApp> {
  late final AuthBloc _authBloc;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authBloc = widget.authBloc ??
        AuthBloc(
          authRepository: widget.authRepository ?? AuthRepository(),
        );

    _appRouter = AppRouter(authBloc: _authBloc);
    _authBloc.add(const AuthCheckRequested());
  }

  @override
  void dispose() {
    if (widget.authBloc == null) {
      _authBloc.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>.value(
      value: _authBloc,
      child: MaterialApp.router(
        title: 'VetManager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: _appRouter.router,
      ),
    );
  }
}
