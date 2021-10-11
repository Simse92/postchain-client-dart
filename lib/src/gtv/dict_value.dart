import 'package:postchain_client/src/asn1/asn_reader.dart';
import 'package:postchain_client/src/asn1/asn_writer.dart';
import 'package:postchain_client/src/gtv/a_value.dart';

class DictValue extends AValue {
  final Map<String, AValue> _value;

  DictValue(this._value) : super(_value);

  @override
  int addContent(AsnWriter writer) {
    writer.pushSequence();

    for (MapEntry<String, AValue> e in _value.entries) {
      writer.pushSequence();
      writer.writeUTF8String(e.key);
      writer.writeEncodedValue(e.value.encode());
      writer.popSequence();
    }

    writer.popSequence();

    return tagDict;
  }

  static AValue readContent(AsnReader reader) {
    var value = <String, AValue>{};
    var innerSequence = reader.readSequence();

    while (innerSequence.remainingBytes() > 0) {
      var dictSequence = innerSequence.readSequence();
      var name = dictSequence.readUTF8String();
      var vals = AValue.decode(dictSequence);

      value.putIfAbsent(name, () => vals);
    }

    return DictValue(value);
  }
}
