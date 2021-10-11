import 'package:postchain_client/src/asn1/asn_reader.dart';
import 'package:postchain_client/src/asn1/asn_writer.dart';
import 'package:postchain_client/src/gtv/a_value.dart';
import 'package:postchain_client/src/gtv/dict_value.dart';

class ArrayValue extends AValue {
  final List<AValue> _value;

  ArrayValue(this._value) : super(_value);

  @override
  int addContent(AsnWriter writer) {
    writer.pushSequence();

    for (var value in _value) {
      writer.writeEncodedValue(value.encode());
    }

    writer.popSequence();
    return tagArray;
  }

  @override
  String toString() {
    var ret = "[";

    var count = 0;
    for (var elm in _value) {
      count++;
      ret += elm.toString() + (count >= _value.length ? "]" : ",");
    }

    return ret;
  }

  List<Object?> toObjectArray() {
    List<Object?> retArr = List.empty(growable: true);

    for (var innerValue in _value) {
      if (innerValue is ArrayValue) {
        retArr.add(innerValue.toObjectArray());
      } else if (innerValue is DictValue) {
        throw Exception("Unsupported type Dict.");
      } else {
        retArr.add(innerValue.value);
      }
    }
    return retArr;
  }

  static AValue readContent(AsnReader reader) {
    List<AValue> value = List.empty(growable: true);
    var innerSequence = reader.readSequence();

    while (innerSequence.remainingBytes() > 0) {
      value.add(AValue.decode(innerSequence));
    }

    return ArrayValue(value);
  }
}
