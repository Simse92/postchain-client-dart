import 'package:postchain_client/src/asn1/asn_reader.dart';
import 'package:postchain_client/src/asn1/asn_writer.dart';
import 'package:postchain_client/src/gtv/a_value.dart';

class NullValue extends AValue {
  NullValue() : super(null);

  @override
  int addContent(AsnWriter writer) {
    writer.writeNull();
    return tagNull;
  }

  @override
  String toString() {
    return "null";
  }

  static AValue readContent(AsnReader reader) {
    reader.readChoice();
    reader.readChoice();

    return NullValue();
  }
}
