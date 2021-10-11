import 'package:postchain_client/src/asn1/asn_reader.dart';
import 'package:postchain_client/src/asn1/asn_writer.dart';
import 'package:postchain_client/src/gtv/a_value.dart';

class UTF8StringValue extends AValue {
  final String _value;

  UTF8StringValue(this._value) : super(_value);

  @override
  int addContent(AsnWriter writer) {
    writer.writeUTF8String(_value);
    return tagString;
  }

  @override
  String toString() {
    return _value;
  }

  static readContent(AsnReader reader) {
    var value = reader.readUTF8String();
    return UTF8StringValue(value);
  }
}
