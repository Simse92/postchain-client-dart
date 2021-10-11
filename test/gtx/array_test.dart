import 'dart:typed_data';

import 'package:postchain_client/src/asn1/asn_reader.dart';
import 'package:postchain_client/src/gtv/a_value.dart';
import 'package:postchain_client/src/gtv/array_value.dart';
import 'package:postchain_client/src/gtv/integer_value.dart';
import 'package:postchain_client/src/gtv/null_value.dart';
import 'package:postchain_client/src/gtv/octet_string_value.dart';
import 'package:postchain_client/src/gtv/utf8_string_value.dart';
import 'package:test/test.dart';

main() {
  test('simple array test', () {
    var val = ArrayValue(List<AValue>.empty(growable: true));

    var innerVal = UTF8StringValue("test");
    val.value.add(innerVal);

    var decoded = AValue.decode(AsnReader(val.encode()));
    expect(val.runtimeType, decoded.runtimeType);
    expect(val.value.length, val.value.length);
    expect(val.value.first, val.value.first);
  });

  test('empty array test', () {
    var val = ArrayValue(List<AValue>.empty(growable: true));

    var decoded = AValue.decode(AsnReader(val.encode()));
    expect(val.runtimeType, decoded.runtimeType);
    expect(val.value.length, val.value.length);
  });

  test('array in array test', () {
    var val = ArrayValue(List<AValue>.empty(growable: true));

    var innerVal = ArrayValue(List<AValue>.empty(growable: true));

    var innerInnerVal = IntegerValue(1000);
    innerVal.value.add(innerInnerVal);

    val.value.add(innerVal);

    var decoded = AValue.decode(AsnReader(val.encode()));
    expect(val.runtimeType, decoded.runtimeType);
    expect(val.value.length, decoded.value.length);
    expect(val.value.first.value.length, decoded.value.first.value.length);
  });

  test('full array test', () {
    var val = ArrayValue(List<AValue>.empty(growable: true));

    var innerVal1 = UTF8StringValue("test");
    val.value.add(innerVal1);

    var innerVal2 = NullValue();
    val.value.add(innerVal2);

    var innerVal3 = IntegerValue(9223372036854775807);
    val.value.add(innerVal3);

    var innerVal4 =
        OctetStringValue(Uint8List.fromList([0xaf, 0xfe, 0xca, 0xfe]));
    val.value.add(innerVal4);

    var innerVal5 = ArrayValue(List<AValue>.empty(growable: true));
    val.value.add(innerVal5);

    var decoded = AValue.decode(AsnReader(val.encode()));
    expect(val.runtimeType, decoded.runtimeType);
    expect(val.value.length, decoded.value.length);
  });
}
