import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/profile_photo_request.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/widgets/profile_photo_card.dart';

class ProfilePhotoGrid extends StatelessWidget {
  const ProfilePhotoGrid({super.key, required this.photos});

  static const double _gap = 14;
  static const double _minCardWidth = 230;
  static const int _maxColumns = 4;
  static const EdgeInsets _padding = EdgeInsets.all(16);

  final List<ProfilePhotoRequest> photos;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns =
              ((constraints.maxWidth + _gap) / (_minCardWidth + _gap))
                  .floor()
                  .clamp(1, _maxColumns);
          final width = (constraints.maxWidth - _gap * (columns - 1)) / columns;

          return Wrap(
            spacing: _gap,
            runSpacing: _gap,
            children: [
              for (final photo in photos)
                SizedBox(
                  width: width,
                  child: ProfilePhotoCard(photo: photo),
                ),
            ],
          );
        },
      ),
    );
  }
}
