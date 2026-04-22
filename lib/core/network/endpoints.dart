class Endpoints {
  Endpoints._();

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String googleAuth = '/auth/google';
  static const String appleAuth = '/auth/apple';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';

  // Users
  static const String me = '/users/me';
  static const String avatar = '/users/me/avatar';
  static const String stats = '/users/me/stats';

  // Wardrobe
  static const String garments = '/garments';
  static String garment(String id) => '/garments/$id';
  static const String scanUpload = '/garments/scan';
  static String garmentJob(String jobId) => '/garments/jobs/$jobId';

  // Outfits
  static const String outfits = '/outfits';
  static String outfit(String id) => '/outfits/$id';
  static const String generateOutfit = '/outfits/generate';
  static const String favorites = '/outfits/favorites';
  static String toggleFavorite(String id) => '/outfits/$id/favorite';
  static String logWorn(String id) => '/outfits/$id/worn';
  static const String outfitHistory = '/outfits/history';

  // Style Profile
  static const String styleProfile = '/style-profile';
  static const String styleQuiz = '/style-profile/quiz';

  // Subscription
  static const String subscription = '/subscription';
  static const String verifyPurchase = '/subscription/verify';

  // Weather
  static const String weather = '/weather/current';

  // Notifications
  static const String registerPushToken = '/notifications/register-token';
  // Try-On
  static const String tryOn = '/tryon';
}
