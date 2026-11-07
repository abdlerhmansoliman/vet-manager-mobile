import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import 'clinic_switcher_bottom_sheet.dart';

/// Interactive AppBar / Header pill displaying the currently active clinic practice
/// with quick one-tap access to the [ClinicSwitcherBottomSheet].
class ClinicSwitcherPill extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final AuthBloc? authBloc;

  const ClinicSwitcherPill({
    super.key,
    this.padding = EdgeInsets.zero,
    this.authBloc,
  });

  @override
  Widget build(BuildContext context) {
    AuthBloc? bloc;
    try {
      bloc = authBloc ?? context.read<AuthBloc>();
    } catch (_) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<AuthBloc, AuthState>(
      bloc: bloc,
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const SizedBox.shrink();
        }

        final tenant = state.session.tenant;

        return Padding(
          padding: padding,
          child: InkWell(
            key: const Key('clinic_switcher_appbar_pill'),
            onTap: () => ClinicSwitcherBottomSheet.show(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryEmerald.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryEmerald.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_hospital_rounded,
                    size: 13,
                    color: AppColors.primaryEmerald,
                  ),
                  const SizedBox(width: 5),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 160),
                    child: Text(
                      tenant.name,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primaryEmerald,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 15,
                    color: AppColors.primaryEmerald,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

