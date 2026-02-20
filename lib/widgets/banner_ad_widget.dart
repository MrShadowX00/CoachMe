// Conditional export: real banner on mobile, empty on web
export 'banner_ad_mobile.dart' if (dart.library.html) 'banner_ad_stub.dart';
