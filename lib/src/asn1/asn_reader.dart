import 'dart:typed_data';
import 'dart:convert';

class AsnReader {
  Uint8List _bytes;

  AsnReader(this._bytes);

  int remainingBytes() {
    return _bytes.length;
  }

  int readChoice() {
    return getByte(null);
  }

  AsnReader readSequence() {
    getByte(0x30);

    int length = readLength();
    var sequence = _bytes.take(length).toList();
    var byteList = _bytes.toList();
    byteList.removeRange(0, length);

    _bytes = Uint8List.fromList(byteList);

    return AsnReader(Uint8List.fromList(sequence));
  }

  Uint8List readOctetString() {
    getByte(0x04);
    var length = readLength();

    final buffer = BytesBuilder();
    for (var i = 0; i < length; i++) {
      buffer.addByte(getByte(null));
    }

    return buffer.toBytes();
  }

  String readUTF8String() {
    getByte(0x0c);
    var length = readLength();

    final buffer = BytesBuilder();
    for (var i = 0; i < length; i++) {
      buffer.addByte(getByte(null));
    }

    return utf8.decode(buffer.toBytes());
  }

  int readInteger() {
    getByte(0x02);
    return readIntegerInternal(readLength(), false);
  }

  int readLength() {
    var first = getByte(null);

    if (first < 128) {
      return first;
    } else {
      return readIntegerInternal(first - 0x80, true);
    }
  }

  int readIntegerInternal(int byteAmount, bool onlyPositive) {
    List<int> buffer = List.empty(growable: true);
    for (int i = 0; i < byteAmount; i++) {
      buffer.add(getByte(null));
    }
    var paddingByte = buffer.first >= 0x80 && !onlyPositive ? 0xff : 0x00;

    for (var i = buffer.length; i < 8; i++) {
      buffer.insert(0, paddingByte);
    }

    if (Endian.host != Endian.little) {
      buffer = buffer.reversed.toList();
    }

    int number = 0;
    for (var byte in buffer) {
      number = (number << 8) | byte;
    }

    return number;
  }

  int getByte(expected) {
    var got = _bytes.first;

    if (expected != null && expected != got) {
      throw Exception(
          "Expected byte " + expected.toString() + ", got " + got.toString());
    }

    if (_bytes.length == 1) {
      _bytes = Uint8List.fromList([]);
    } else {
      _bytes = _bytes.sublist(1, _bytes.length);
    }

    return got;
  }
}
