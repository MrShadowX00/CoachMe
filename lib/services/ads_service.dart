import 'package:flutter/foundation.dart';

// Conditional import: stub for web, real for mobile
export 'ads_service_mobile.dart' if (dart.library.html) 'ads_service_stub.dart';

class AdsServiceBase {
  static bool get isMobile => !kIsWeb;
}
