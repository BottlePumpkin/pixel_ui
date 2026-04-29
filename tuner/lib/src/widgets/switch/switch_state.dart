import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:pixel_ui/pixel_ui.dart';

class SwitchState extends ChangeNotifier {
  PixelShapeStyle onTrack = _defaultOnTrack;
  PixelShapeStyle offTrack = _defaultOffTrack;
  PixelShapeStyle thumb = _defaultThumb;
  PixelShapeStyle? disabledStyle;
  bool previewValue = false;

  void setOnTrack(PixelShapeStyle s) {
    onTrack = s;
    notifyListeners();
  }

  void setOffTrack(PixelShapeStyle s) {
    offTrack = s;
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

  void togglePreviewValue() {
    previewValue = !previewValue;
    notifyListeners();
  }

  static const _defaultOnTrack = PixelShapeStyle(
    corners: PixelCorners.sm,
    fillColor: Color(0xFFFFD643),
    borderColor: Color(0xFF2A4820),
    borderWidth: 1,
  );
  static const _defaultOffTrack = PixelShapeStyle(
    corners: PixelCorners.sm,
    fillColor: Color(0xFF555E73),
    borderColor: Color(0xFF12141A),
    borderWidth: 1,
  );
  static const _defaultThumb = PixelShapeStyle(
    corners: PixelCorners.sm,
    fillColor: Color(0xFFFFFFFF),
  );
}
