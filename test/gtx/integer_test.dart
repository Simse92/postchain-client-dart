import 'package:postchain_client/src/asn1/asn_reader.dart';
import 'package:postchain_client/src/gtv/a_value.dart';
import 'package:postchain_client/src/gtv/integer_value.dart';
import 'package:test/test.dart';

void main() {
  test('simple integer test', () {
    var val = IntegerValue(1337);

    var decoded = AValue.decode(AsnReader(val.encode()));
    expect(decoded.runtimeType, val.runtimeType);
    expect(decoded.value, val.value);
  });

  test('negative integer test', () {
    var val = IntegerValue(-1337);

    var decoded = AValue.decode(AsnReader(val.encode()));
    expect(decoded.runtimeType, val.runtimeType);
    expect(decoded.value, val.value);
  });

  test('zero integer test', () {
    var val = IntegerValue(0);

    var decoded = AValue.decode(AsnReader(val.encode()));
    expect(decoded.runtimeType, val.runtimeType);
    expect(decoded.value, val.value);
  });

  test('max integer test', () {
    var val = IntegerValue(9223372036854775807);

    var decoded = AValue.decode(AsnReader(val.encode()));
    expect(decoded.runtimeType, val.runtimeType);
    expect(decoded.value, val.value);
  });

  test('min integer test', () {
    var val = IntegerValue(-9223372036854775807);

    var decoded = AValue.decode(AsnReader(val.encode()));
    expect(decoded.runtimeType, val.runtimeType);
    expect(decoded.value, val.value);
  });
}
