import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_search_field.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/state/payment_cubit.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/withdrawal_flow.dart';

class PaymentToolbar extends StatelessWidget {
  const PaymentToolbar({super.key});

  static const double _searchWidth = 340;
  static const double _searchPadding = 11;
  static const double _iconSize = 16;
  static const EdgeInsets _padding = EdgeInsets.all(12);

  Widget _downloadIcon(BuildContext context) => SvgPicture.asset(
    AppImages.downloadIcon,
    width: _iconSize,
    height: _iconSize,
    colorFilter: ColorFilter.mode(
      context.colorScheme.onSurface,
      BlendMode.srcIn,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _padding,
      child: LayoutBuilder(
        builder: (context, constraints) => Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppUtils.spacingMd,
          runSpacing: AppUtils.spacingSm,
          children: [
            SizedBox(
              width: constraints.maxWidth < _searchWidth
                  ? constraints.maxWidth
                  : _searchWidth,
              child: AppSearchField(
                hint: AppStrings.searchWithdrawalsHint,
                verticalPadding: _searchPadding,
                onChanged: context.read<PaymentCubit>().search,
              ),
            ),
            Wrap(
              spacing: AppUtils.spacingSm,
              runSpacing: AppUtils.spacingSm,
              children: [
                AppSecondaryButton(
                  label: AppStrings.exportBeneficiarySheet,
                  leading: _downloadIcon(context),
                  onPressed: () => exportBeneficiaries(context),
                ),
                AppSecondaryButton(
                  label: AppStrings.exportWithdrawalSheet,
                  leading: _downloadIcon(context),
                  onPressed: () => exportWithdrawals(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
