import 'dart:typed_data';

import 'package:postchain_client/src/asn1/asn_reader.dart';
import 'package:postchain_client/src/gtv/a_value.dart';
import 'package:postchain_client/src/gtv/octet_string_value.dart';
import 'package:test/test.dart';

void main() {
  test('simple byte array test', () {
    var val = OctetStringValue(Uint8List.fromList([0xaf, 0xfe, 0xca, 0xfe]));

    var decoded = AValue.decode(AsnReader(val.encode()));
    expect(val.runtimeType, decoded.runtimeType);
    expect(val.value, decoded.value);
  });

  test('empty byte array test', () {
    var val = OctetStringValue(Uint8List.fromList([]));

    var decoded = AValue.decode(AsnReader(val.encode()));
    expect(val.runtimeType, decoded.runtimeType);
    expect(val.value, decoded.value);
  });
}
