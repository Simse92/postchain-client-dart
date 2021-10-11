import 'package:postchain_client/src/asn1/asn_reader.dart';
import 'package:postchain_client/src/gtv/a_value.dart';
import 'package:postchain_client/src/gtv/utf8_string_value.dart';
import 'package:test/test.dart';

void main() {
  test('simple string test', () {
    var val = UTF8StringValue("test");

    var decoded = AValue.decode(AsnReader(val.encode()));
    expect(val.runtimeType, decoded.runtimeType);
    expect(val.value, decoded.value);
  });

  test('empty string test', () {
    var val = UTF8StringValue("");

    var decoded = AValue.decode(AsnReader(val.encode()));
    expect(val.runtimeType, decoded.runtimeType);
    expect(val.value, decoded.value);
  });
}
