// test/check_tuner_coverage_test.dart
import 'package:flutter_test/flutter_test.dart';
import '../tool/check_tuner_coverage.dart' as cov;

void main() {
  group('scanPublicFields', () {
    test('extracts fields from PixelShapeStyle source', () {
      const src = '''
@immutable
class PixelShapeStyle {
  final PixelCorners corners;
  final Color fillColor;
  final Color? borderColor;
  final int borderWidth;
  final PixelShadow? shadow;
  final PixelTexture? texture;
}
''';
      final fields = cov.scanPublicFields(src, 'PixelShapeStyle');
      expect(fields, containsAll(<String>[
        'corners',
        'fillColor',
        'borderColor',
        'borderWidth',
        'shadow',
        'texture',
      ]));
      expect(fields, hasLength(6));
    });

    test('ignores underscore-prefixed (private) fields', () {
      const src = '''
class PixelShapeStyle {
  static const Object _unset = Object();
  final PixelCorners corners;
}
''';
      final fields = cov.scanPublicFields(src, 'PixelShapeStyle');
      expect(fields, <String>['corners']);
    });

    test('returns empty when target class absent', () {
      const src = 'class Other { final int x; }';
      expect(cov.scanPublicFields(src, 'PixelShapeStyle'), isEmpty);
    });
  });

  group('scanControlReferences', () {
    test('finds field identifiers referenced in control source', () {
      const src = '''
Widget cornerPicker(State s) {
  return Row(children: [
    Text('tl'),
    Slider(value: s.tl.length),
    Text('tr'),
    Slider(value: s.tr.length),
  ]);
}
''';
      final refs = cov.scanControlReferences(src, <String>['tl', 'tr', 'bl', 'br']);
      expect(refs, containsAll(<String>['tl', 'tr']));
      expect(refs, isNot(contains('bl')));
    });

    test('only matches whole-word identifiers', () {
      const src = "Text('this is unrelated but contains trsomething');";
      final refs = cov.scanControlReferences(src, <String>['tr']);
      expect(refs, isEmpty);
    });
  });

  group('compare', () {
    test('reports missing fields and orphan controls', () {
      final fields = <String>{'corners', 'fillColor', 'borderColor', 'shadow'};
      final controlRefs = <String, Set<String>>{
        'corner_picker.dart': <String>{'corners'},
        'color_hex_input.dart': <String>{'fillColor'},
        'orphan_control.dart': <String>{'nonexistent'},
      };
      final result = cov.compare(fields, controlRefs);
      expect(result.missing, containsAll(<String>['borderColor', 'shadow']));
      expect(result.orphans, contains('orphan_control.dart'));
      expect(result.hasDrift, isTrue);
    });

    test('clean when everything matches', () {
      final fields = <String>{'a', 'b'};
      final controlRefs = <String, Set<String>>{
        'ab_control.dart': <String>{'a', 'b'},
      };
      final result = cov.compare(fields, controlRefs);
      expect(result.hasDrift, isFalse);
      expect(result.missing, isEmpty);
      expect(result.orphans, isEmpty);
    });
  });
}
