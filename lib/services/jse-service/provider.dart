import 'package:flutter/foundation.dart';

import './base/jse-service-base.dart';
import './web/jse-service-web.dart';


class JseServiceProvider {
  @protected
  static JseService _instance;

  static JseService getInstance() {
    if (_instance == null) {
      if (kIsWeb) {
        _instance = JseServiceWeb();
      } else {
        _instance = JseServiceWeb();
      }
    }
    return _instance;
  } 
}