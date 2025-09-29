import 'package:imechano/ui/common/globals.dart';

class PriceCalculator {
  /// Calculate total price from cart
  static double getTotalPrice() {
    if (cart.isEmpty) return 0.0;

    List<double> prices = cart
        .where((element) => element['price'] != "" && element['price'] != null)
        .toList()
        .map((item) => double.tryParse(item['price'] ?? '0') ?? 0.0)
        .toList();

    return prices.isNotEmpty ? prices.reduce((a, b) => a + b) : 0.0;
  }

  /// Calculate delivery charges (5% of total or minimum 45)
  static double getDeliveryCharges() {
    double total = getTotalPrice();
    double deliveryCharge = total * 0.05; // 5% of total
    return deliveryCharge < 45.0 ? 45.0 : deliveryCharge;
  }

  /// Calculate final total (total + delivery charges)
  static double getFinalTotal() {
    return getTotalPrice() + getDeliveryCharges();
  }

  /// Calculate 75% balance amount
  static double getBalanceAmount() {
    return getTotalPrice() * 0.75;
  }

  /// Calculate labour cost (50% of parts cost)
  static double getLabourCost() {
    return getTotalPrice() * 0.5;
  }

  /// Format price with currency
  static String formatPrice(double price, {String currency = 'KWD'}) {
    return '$currency ${price.toStringAsFixed(3)}';
  }

  /// Format price with currency (2 decimal places)
  static String formatPriceShort(double price, {String currency = 'KWD'}) {
    return '$currency ${price.toStringAsFixed(2)}';
  }

  /// Get cart item count
  static int getCartItemCount() {
    return cart.length;
  }

  /// Check if cart has items
  static bool hasItems() {
    return cart.isNotEmpty;
  }

  /// Get formatted total price
  static String getFormattedTotal() {
    return formatPrice(getTotalPrice());
  }

  /// Get formatted delivery charges
  static String getFormattedDeliveryCharges() {
    return formatPriceShort(getDeliveryCharges());
  }

  /// Get formatted final total
  static String getFormattedFinalTotal() {
    return formatPrice(getFinalTotal());
  }

  /// Get formatted balance amount
  static String getFormattedBalanceAmount() {
    return formatPriceShort(getBalanceAmount());
  }

  /// Get formatted labour cost
  static String getFormattedLabourCost() {
    return formatPriceShort(getLabourCost());
  }
}
