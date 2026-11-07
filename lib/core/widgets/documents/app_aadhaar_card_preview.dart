import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';

class AppAadhaarCardPreview extends StatelessWidget {
  const AppAadhaarCardPreview({
    super.key,
    required this.name,
    required this.maskedNumber,
  });

  static const Size cardSize = Size(600, 376);
  static const double _bandHeight = 74;
  static const double _photoWidth = 136;
  static const double _photoHeight = 168;
  static const double _photoIconSize = 136;
  static const double _photoGap = 28;
  static const double _lineHeight = 12;
  static const double _lineGap = 14;
  static const double _nameGap = 20;
  static const double _numberGap = 26;
  static const List<double> _lineFactors = [0.72, 0.53, 0.62];
  static const EdgeInsets _bandPadding = EdgeInsets.symmetric(horizontal: 30);
  static const EdgeInsets _bodyPadding = EdgeInsets.fromLTRB(30, 28, 30, 0);

  final String name;
  final String maskedNumber;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ColoredBox(
      color: colors.uploadBackground,
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.topCenter,
        child: SizedBox.fromSize(
          size: cardSize,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: _bandHeight,
                padding: _bandPadding,
                alignment: Alignment.centerLeft,
                color: colors.uploadBorder,
                child: Text(
                  AppStrings.aadhaarCardFront.toUpperCase(),
                  style: AppTextStyles.titleSmall.copyWith(
                    color: colors.onPrimarySoft,
                  ),
                ),
              ),
              Padding(
                padding: _bodyPadding,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: _photoWidth,
                      height: _photoHeight,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: colors.uploadBorder.withValues(alpha: 0.45),
                        borderRadius: AppUtils.radiusSmall,
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Icon(
                          Icons.person_rounded,
                          size: _photoIconSize,
                          color: colors.uploadBorder,
                        ),
                      ),
                    ),
                    const SizedBox(width: _photoGap),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: context.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: _nameGap),
                          for (final factor in _lineFactors) ...[
                            FractionallySizedBox(
                              widthFactor: factor,
                              child: Container(
                                height: _lineHeight,
                                decoration: BoxDecoration(
                                  color: colors.uploadBorder.withValues(
                                    alpha: 0.6,
                                  ),
                                  borderRadius: AppUtils.radiusPill,
                                ),
                              ),
                            ),
                            const SizedBox(height: _lineGap),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: _numberGap),
              Text(
                maskedNumber,
                textAlign: TextAlign.center,
                style: AppTextStyles.displayCourier.copyWith(
                  color: context.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
