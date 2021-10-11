import 'package:postchain_client/src/asn1/asn_reader.dart';
import 'package:postchain_client/src/gtv/a_value.dart';
import 'package:postchain_client/src/gtv/null_value.dart';
import 'package:test/test.dart';

void main() {
  test('simple null test', () {
    var val = NullValue();

    var decoded = AValue.decode(AsnReader(val.encode()));
    expect(val.runtimeType, decoded.runtimeType);
    expect(val.value, decoded.value);
  });
}
