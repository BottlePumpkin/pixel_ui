import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:pixel_ui/pixel_ui.dart';

class SliderState extends ChangeNotifier {
  PixelShapeStyle track = _defaultTrack;
  PixelShapeStyle fill = _defaultFill;
  PixelShapeStyle thumb = _defaultThumb;
  PixelShapeStyle? disabledStyle;
  double min = 0.0;
  double max = 1.0;
  int? divisions;
  double previewValue = 0.5;

  void setTrack(PixelShapeStyle s) {
    track = s;
    notifyListeners();
  }

  void setFill(PixelShapeStyle s) {
    fill = s;
    notifyListeners();
  }

  void setThumb(PixelShapeStyle s) {
    thumb = s;
    notifyListeners();
  }

  void setDisabled(PixelShapeStyle? s) {
    disabledStyle = s;
    notifyListeners();
  }

  void setMin(double v) {
    min = v;
    previewValue = previewValue.clamp(min, max);
    notifyListeners();
  }

  void setMax(double v) {
    max = v;
    previewValue = previewValue.clamp(min, max);
    notifyListeners();
  }

  void setDivisions(int? n) {
    divisions = n;
    notifyListeners();
  }

  void setPreviewValue(double v) {
    previewValue = v.clamp(min, max);
    notifyListeners();
  }

  static const _defaultTrack = PixelShapeStyle(
    corners: PixelCorners.sm,
    fillColor: Color(0xFF222732),
    borderColor: Color(0xFF12141A),
    borderWidth: 1,
  );
  static const _defaultFill = PixelShapeStyle(
    corners: PixelCorners.sm,
    fillColor: Color(0xFFFFD643),
    borderColor: Color(0xFF2A4820),
    borderWidth: 1,
  );
  static const _defaultThumb = PixelShapeStyle(
    corners: PixelCorners.sm,
    fillColor: Color(0xFFFFFFFF),
    borderColor: Color(0xFF12141A),
    borderWidth: 1,
  );
}
