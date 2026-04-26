import 'dart:async';
import 'dart:io';

import 'package:in_app_purchase/in_app_purchase.dart';
import '../domain/entities/subscription.dart';

const _kProductIds = {
  'stylo_stylist_monthly',
  'stylo_stylist_annual',
  'stylo_pro_monthly',
  'stylo_pro_annual',
  'stylo_pro_unlimited_monthly',
  'stylo_pro_unlimited_annual',
};

const kProductTierMap = {
  'stylo_stylist_monthly': SubscriptionPlan.stylist,
  'stylo_stylist_annual': SubscriptionPlan.stylist,
  'stylo_pro_monthly': SubscriptionPlan.pro,
  'stylo_pro_annual': SubscriptionPlan.pro,
  'stylo_pro_unlimited_monthly': SubscriptionPlan.proUnlimited,
  'stylo_pro_unlimited_annual': SubscriptionPlan.proUnlimited,
};

// Backward-compat alias — prefer kProductTierMap
@Deprecated('Use kProductTierMap')
const kIapProductIds = _kProductIds;

class IapService {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  Stream<List<PurchaseDetails>> get purchaseStream => _iap.purchaseStream;

  Future<bool> get isAvailable => _iap.isAvailable();

  void listenToPurchases(void Function(List<PurchaseDetails>) handler) {
    _subscription = _iap.purchaseStream.listen(handler);
  }

  void dispose() {
    _subscription.cancel();
  }

  Future<List<ProductDetails>> loadProducts() async {
    final response = await _iap.queryProductDetails(_kProductIds);
    return response.productDetails;
  }

  Future<void> buyProduct(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> completePurchase(PurchaseDetails details) async {
    if (details.pendingCompletePurchase) {
      await _iap.completePurchase(details);
    }
  }

  String receiptDataFor(PurchaseDetails details) {
    return details.verificationData.serverVerificationData;
  }

  String get platform => Platform.isIOS ? 'ios' : 'android';
}
