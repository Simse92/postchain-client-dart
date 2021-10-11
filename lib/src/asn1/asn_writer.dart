import 'dart:typed_data';
import 'dart:convert';

import 'package:postchain_client/src/postchain_util.dart';

class AsnWriter {
  final BytesBuilder _buffer = BytesBuilder();
  final List<AsnWriter> _sequences = List.empty(growable: true);

  AsnWriter currentWriter() {
    return _sequences.isEmpty ? this : _sequences[_sequences.length - 1];
  }

  void writeNull() {
    var buffer = currentWriter()._buffer;

    buffer.addByte(0x05);
    buffer.addByte(0x00);
  }

  void writeOctetString(Uint8List octetString) {
    var buffer = currentWriter()._buffer;

    buffer.addByte(0x04);
    buffer.add(getLengthBytes(octetString.length));
    buffer.add(octetString);
  }

  void writeUTF8String(String characterString) {
    var buffer = currentWriter()._buffer;
    var content = utf8.encode(characterString);

    buffer.addByte(0x0c);
    buffer.add(getLengthBytes(content.length));
    buffer.add(content);
  }

  void writeInteger(int number) {
    var buffer = currentWriter()._buffer;
    var content = integerToBytes(number, false);

    buffer.addByte(0x02);
    buffer.add(getLengthBytes(content.length));
    buffer.add(content);
  }

  void pushSequence() {
    _sequences.add(AsnWriter());
  }

  void popSequence() {
    var writer = currentWriter();
    _sequences.remove(writer);

    var buffer = currentWriter()._buffer;
    var content = writer.encode();

    buffer.addByte(0x30);
    buffer.add(getLengthBytes(content.length));
    buffer.add(content);
  }

  void writeEncodedValue(Uint8List encodedValue) {
    var buffer = currentWriter()._buffer;

    buffer.add(encodedValue);
  }

  int getEncodedLength() {
    var buffer = currentWriter()._buffer;
    return buffer.length;
  }

  Uint8List encode() {
    if (_sequences.isNotEmpty) {
      throw Exception("Tried to encode with open Sequence");
    }

    return _buffer.toBytes();
  }

  Uint8List getLengthBytes(int length) {
    BytesBuilder lengthBytes = BytesBuilder();

    if (length < 128) {
      lengthBytes.addByte(length);
    } else {
      var sizeInBytes = integerToBytes(length, true);
      lengthBytes.addByte(0x80 + sizeInBytes.length);
      lengthBytes.add(sizeInBytes);
    }

    return lengthBytes.toBytes();
  }

  Uint8List getByteList(int integer) {
    var byteList = PostchainUtil.intToUint8List(integer);

    List<int> trimmedBytes = List.empty(growable: true);

    if (integer >= 0) {
      for (var i = byteList.length - 1; i >= 0; i--) {
        if (byteList[i] != 0) {
          for (var j = 0; j <= i; j++) {
            trimmedBytes.add(byteList[j]);
          }
        }
        break;
      }
    } else {
      for (var i = byteList.length - 1; i >= 0; i--) {
        if (byteList[i] != 0xff) {
          for (var j = 0; j <= i; j++) {
            trimmedBytes.add(byteList[j]);
          }
          break;
        }
      }

      if (trimmedBytes.isEmpty || trimmedBytes[trimmedBytes.length - 1] < 128) {
        trimmedBytes.insert(0, 0xff);

        if (integer > 0) {
          trimmedBytes = trimmedBytes.reversed.toList();
        }
      }
    }

    return Uint8List.fromList(trimmedBytes);
  }

  Uint8List integerToBytes(int integer, bool asLength) {
    Uint8List sizeInBytes = getByteList(integer);
    List<int> sizeInBytesList = sizeInBytes.toList(growable: true);

    if (Endian.host != Endian.little) {
      sizeInBytesList = sizeInBytesList.reversed.toList(growable: true);
    }

    if (sizeInBytesList.isEmpty) {
      sizeInBytesList.add(0x00);
    } else if (!asLength && integer >= 0 && sizeInBytesList.first >= 128) {
      sizeInBytesList.insert(0, 0x00);
    }

    return Uint8List.fromList(sizeInBytesList);
  }
}
