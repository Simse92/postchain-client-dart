import 'package:postchain_client/postchain_client.dart';
import 'package:postchain_client/src/asn1/asn_reader.dart';
import 'package:test/test.dart';
import 'dart:typed_data';

void main() {
  test('null test', () {
    var writer = AsnWriter();
    writer.writeNull();

    var reader = AsnReader(writer.encode());
    reader.readChoice();
    reader.readChoice();
  });

  test('read octet string', () {
    var writer = AsnWriter();
    var bytes = [0xaf, 0xfe];
    writer.writeOctetString(Uint8List.fromList(bytes));

    var reader = AsnReader(writer.encode());
    expect(reader.readOctetString(), bytes);
  });

  test('read empty octet string', () {
    var writer = AsnWriter();

    List<int> bytes = [];
    writer.writeOctetString(Uint8List.fromList(bytes));

    var reader = AsnReader(writer.encode());

    expect(reader.readOctetString(), bytes);
  });

  test('read brid octet string', () {
    var writer = AsnWriter();
    var brid = PostchainUtil.hexStringToBuffer(
        "E2BE5C617CE50AFD0882A753C6FDA9C4D925EEDAC50DB97E33F457826A856DE0");

    writer.writeOctetString(brid);

    var reader = AsnReader(writer.encode());

    expect(reader.readOctetString(), brid);
  });

  test('read utf-8 string', () {
    var writer = AsnWriter();
    String str = "Hello World!";
    writer.writeUTF8String(str);

    var reader = AsnReader(writer.encode());

    expect(reader.readUTF8String(), str);
  });

  test('read empty utf-8 string', () {
    var writer = AsnWriter();

    writer.writeUTF8String("");

    var reader = AsnReader(writer.encode());

    expect(reader.readUTF8String(), "");
  });

  test('read special utf-8 string', () {
    var writer = AsnWriter();

    List<String> strings = [
      "Swedish: Åå Ää Öö",
      "Danish/Norway: Ææ Øø Åå",
      "German/Finish: Ää Öö Üü",
      "Greek lower: αβγδϵζηθικλμνξοπρστυϕχψω",
      "Greek upper: ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩ",
      "Russian: АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпСсТтУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя"
    ];
    for (var string in strings) {
      writer.writeUTF8String(string);
    }

    var reader = AsnReader(writer.encode());
    for (var str in strings) {
      expect(reader.readUTF8String(), str);
    }
  });

  test('read integer', () {
    var writer = AsnWriter();
    writer.writeInteger(1337);

    var reader = AsnReader(writer.encode());
    expect(reader.readInteger(), 1337);
  });

  test('read sequence', () {
    var writer = AsnWriter();
    writer.pushSequence();
    writer.pushSequence();
    var brid = PostchainUtil.hexStringToBuffer(
        "E2BE5C617CE50AFD0882A753C6FDA9C4D925EEDAC50DB97E33F457826A856DE0");

    writer.writeOctetString(brid);
    writer.popSequence();

    writer.pushSequence();
    writer.pushSequence();
    String op1Name = "test_op1";
    String op1Arg1 = "arg1";
    int op1Arg2 = 42;
    writer.writeUTF8String(op1Name);
    writer.writeUTF8String(op1Arg1);
    writer.writeInteger(op1Arg2);
    writer.popSequence();
    writer.pushSequence();
    String op2Name = "test_op2";
    writer.writeUTF8String(op2Name);
    writer.popSequence();
    writer.popSequence();

    writer.popSequence();

    var reader = AsnReader(writer.encode());
    var mainSeq = reader.readSequence();

    var bridSeq = mainSeq.readSequence();
    expect(bridSeq.readOctetString(), brid);

    var opSeq = mainSeq.readSequence();
    var op1Seq = opSeq.readSequence();
    expect(op1Seq.readUTF8String(), op1Name);
    expect(op1Seq.readUTF8String(), op1Arg1);
    expect(op1Seq.readInteger(), op1Arg2);

    var op2Seq = opSeq.readSequence();
    expect(op2Seq.readUTF8String(), op2Name);
  });
}
