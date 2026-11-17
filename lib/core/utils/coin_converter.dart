/// Converts between the wallet's rupees and coins exactly like the calling
/// app (`CoinConverter` in `lib/core/utils/coin_converter.dart`) and its
/// Cloud Functions (`coinsFor` in `functions/calls/billing.js`), so the
/// coins an admin sees match the coins the user sees in the app.
///
/// The user document stores only `walletBalance`, in rupees (up to six
/// decimals after call and chat billing); coins are never stored.
abstract final class CoinConverter {
  static const double coinsPerRupee = 15;

  /// Absorbs floating point error, e.g. 33.333334 × 15 = 499.99999.
  static const double _precision = 1e-6;

  /// Whole coins a rupee amount buys, rounded down like the app.
  static int rupeesToCoins(num rupees) {
    if (!rupees.isFinite || rupees <= 0) return 0;
    return (rupees * coinsPerRupee + _precision).floor();
  }

  static double coinsToRupees(num coins) => coins / coinsPerRupee;
}
