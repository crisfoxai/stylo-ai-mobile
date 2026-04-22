import 'dart:async';
import 'dart:io';

import 'package:in_app_purchase/in_app_purchase.dart';

const _kProductIdMonthly = 'stylo_premium_monthly';
const _kProductIdAnnual = 'stylo_premium_annual';
const kIapProductIds = {_kProductIdMonthly, _kProductIdAnnual};

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
    final response = await _iap.queryProductDetails(kIapProductIds);
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
    if (Platform.isIOS) {
      return details.verificationData.serverVerificationData;
    }
    // Android: returns the purchase token
    return details.verificationData.serverVerificationData;
  }

  String get platform => Platform.isIOS ? 'ios' : 'android';
}
