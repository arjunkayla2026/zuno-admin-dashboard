enum BannerAudience { user, host }

enum BannerArtwork { navy, brown, teal }

class BannerImage {
  const BannerImage({
    required this.fileName,
    required this.headline,
    required this.subheading,
    required this.actionLabel,
    required this.artwork,
    required this.addedOn,
    this.audience = BannerAudience.user,
  });

  final String fileName;
  final String headline;
  final String subheading;
  final String actionLabel;
  final BannerArtwork artwork;
  final DateTime addedOn;
  final BannerAudience audience;

  BannerImage copyWith({BannerAudience? audience}) {
    return BannerImage(
      fileName: fileName,
      headline: headline,
      subheading: subheading,
      actionLabel: actionLabel,
      artwork: artwork,
      addedOn: addedOn,
      audience: audience ?? this.audience,
    );
  }
}
