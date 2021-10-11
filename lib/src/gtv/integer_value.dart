import 'package:postchain_client/src/asn1/asn_reader.dart';
import 'package:postchain_client/src/asn1/asn_writer.dart';
import 'package:postchain_client/src/gtv/a_value.dart';

class IntegerValue extends AValue {
  final int _value;

  IntegerValue(this._value) : super(_value);

  @override
  int addContent(AsnWriter writer) {
    writer.writeInteger(_value);
    return tagInteger;
  }

  @override
  String toString() {
    return _value.toString();
  }

  static AValue readContent(AsnReader reader) {
    var value = reader.readInteger();
    return IntegerValue(value);
  }
}
