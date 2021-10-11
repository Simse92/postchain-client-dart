import 'dart:typed_data';
import 'package:postchain_client/src/asn1/asn_reader.dart';
import 'package:postchain_client/src/asn1/asn_writer.dart';
import 'package:postchain_client/src/gtv/array_value.dart';
import 'package:postchain_client/src/gtv/dict_value.dart';
import 'package:postchain_client/src/gtv/integer_value.dart';
import 'package:postchain_client/src/gtv/null_value.dart';
import 'package:postchain_client/src/gtv/octet_string_value.dart';
import 'package:postchain_client/src/gtv/utf8_string_value.dart';
import 'package:postchain_client/src/postchain_util.dart';

const tagNull = 0xa0;
const tagByteArray = 0xa1;
const tagString = 0xa2;
const tagInteger = 0xa3;
const tagArray = 0xa5;
const tagDict = 0xa4;
const tagSequence = 0x30;

abstract class AValue {
  dynamic value;

  AValue(this.value);

  Uint8List encode() {
    var writer = AsnWriter();
    var encoded = BytesBuilder();

    encoded.addByte(addContent(writer));

    var choiceSize = writer.getEncodedLength();
    if (choiceSize < 128) {
      encoded.addByte(choiceSize);
    } else {
      var sizeInBytes = _trimByteList(PostchainUtil.intToUint8List(choiceSize));
      var sizeLength = sizeInBytes.length;

      encoded.addByte((0x80 + sizeLength));

      if (Endian.host != Endian.little) {
        sizeInBytes =
            Uint8List.fromList(sizeInBytes.reversed.toList(growable: true));
      }

      encoded.add(sizeInBytes);
    }
    var bytes = BytesBuilder();
    bytes.add(encoded.toBytes());
    bytes.add(writer.encode());

    return bytes.toBytes();
  }

  static AValue decode(AsnReader reader) {
    var choice = reader.readChoice();
    reader.readLength();

    switch (choice) {
      case tagNull:
        return NullValue.readContent(reader);
      case tagByteArray:
        return OctetStringValue.readContent(reader);
      case tagString:
        return UTF8StringValue.readContent(reader);
      case tagInteger:
        return IntegerValue.readContent(reader);
      case tagArray:
        return ArrayValue.readContent(reader);
      case tagDict:
        return DictValue.readContent(reader);
      default:
        throw Exception("Unknown choice tag: " + choice.toString());
    }
  }

  int addContent(AsnWriter writer);

  static Uint8List _trimByteList(Uint8List byteList) {
    var trimmedBytes = BytesBuilder();

    for (var i = byteList.length - 1; i >= 0; i--) {
      if (byteList[i] != 0) {
        for (var j = 0; j <= i; j++) {
          trimmedBytes.addByte(byteList[j]);
        }
        break;
      }
    }

    return trimmedBytes.toBytes();
  }
}
