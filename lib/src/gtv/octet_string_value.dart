import 'dart:typed_data';

import 'package:postchain_client/src/asn1/asn_reader.dart';
import 'package:postchain_client/src/asn1/asn_writer.dart';
import 'package:postchain_client/src/gtv/a_value.dart';
import 'package:postchain_client/src/postchain_util.dart';

class OctetStringValue extends AValue {
  final Uint8List _value;

  OctetStringValue(this._value) : super(_value);

  @override
  int addContent(AsnWriter writer) {
    writer.writeOctetString(_value);
    return tagByteArray;
  }

  @override
  String toString() {
    return PostchainUtil.byteArrayToString(_value);
  }

  static AValue readContent(AsnReader reader) {
    var value = reader.readOctetString();
    return OctetStringValue(value);
  }
}
