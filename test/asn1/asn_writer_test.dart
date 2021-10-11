import 'package:postchain_client/postchain_client.dart';
import 'package:test/test.dart';
import 'dart:typed_data';

void main() {
  test('null test', () {
    var writer = AsnWriter();
    writer.writeNull();

    var content =
        PostchainUtil.byteArrayToString(writer.encode()).toUpperCase();

    expect(content, "0500");
  });

  test('octet string test', () {
    var writer = AsnWriter();

    writer.writeOctetString(Uint8List.fromList([0xaf, 0xfe]));

    var content =
        PostchainUtil.byteArrayToString(writer.encode()).toUpperCase();

    expect(content, "0402AFFE");
  });

  test('empty octet string test', () {
    var writer = AsnWriter();

    writer.writeOctetString(Uint8List.fromList([]));

    var content =
        PostchainUtil.byteArrayToString(writer.encode()).toUpperCase();

    expect(content, "0400");
  });

  test('brid octet string test', () {
    var writer = AsnWriter();
    var brid =
        "E2BE5C617CE50AFD0882A753C6FDA9C4D925EEDAC50DB97E33F457826A856DE0";

    writer.writeOctetString(PostchainUtil.hexStringToBuffer(brid));

    var content =
        PostchainUtil.byteArrayToString(writer.encode()).toUpperCase();

    var expected =
        "0420E2BE5C617CE50AFD0882A753C6FDA9C4D925EEDAC50DB97E33F457826A856DE0";
    expect(content, expected);
  });

  test('utf-8 string test', () {
    var writer = AsnWriter();

    writer.writeUTF8String("Hello World!");

    var content =
        PostchainUtil.byteArrayToString(writer.encode()).toUpperCase();

    var expected = "0C0C48656C6C6F20576F726C6421";
    expect(content, expected);
  });

  test('empty utf-8 string test', () {
    var writer = AsnWriter();

    writer.writeUTF8String("");

    var content =
        PostchainUtil.byteArrayToString(writer.encode()).toUpperCase();

    var expected = "0C00";
    expect(content, expected);
  });

  test('special utf-8 string test', () {
    var writer = AsnWriter();

    writer.writeUTF8String("Swedish: Åå Ää Öö");
    writer.writeUTF8String("Danish/Norway: Ææ Øø Åå");
    writer.writeUTF8String("German/Finish: Ää Öö Üü");
    writer.writeUTF8String("Greek lower: αβγδϵζηθικλμνξοπρστυϕχψω");
    writer.writeUTF8String("Greek upper: ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩ");
    writer.writeUTF8String(
        "Russian: АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпСсТтУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя");

    var content =
        PostchainUtil.byteArrayToString(writer.encode()).toUpperCase();

    var expected =
        "0C17537765646973683A20C385C3A520C384C3A420C396C3B60C1D44616E6973682F4E6F727761793A20C386C3A620C398C3B820C385C3A50C1D4765726D616E2F46696E6973683A20C384C3A420C396C3B620C39CC3BC0C3D477265656B206C6F7765723A20CEB1CEB2CEB3CEB4CFB5CEB6CEB7CEB8CEB9CEBACEBBCEBCCEBDCEBECEBFCF80CF81CF83CF84CF85CF95CF87CF88CF890C3D477265656B2075707065723A20CE91CE92CE93CE94CE95CE96CE97CE98CE99CE9ACE9BCE9CCE9DCE9ECE9FCEA0CEA1CEA3CEA4CEA5CEA6CEA7CEA8CEA90C81895275737369616E3A20D090D0B0D091D0B1D092D0B2D093D0B3D094D0B4D095D0B5D081D191D096D0B6D097D0B7D098D0B8D099D0B9D09AD0BAD09BD0BBD09CD0BCD09DD0BDD09ED0BED09FD0BFD0A1D181D0A2D182D0A3D183D0A4D184D0A5D185D0A6D186D0A7D187D0A8D188D0A9D189D0AAD18AD0ABD18BD0ACD18CD0ADD18DD0AED18ED0AFD18F";
    expect(content, expected);
  });

  test('integer test', () {
    var writer = AsnWriter();

    writer.writeInteger(42424242);

    var content =
        PostchainUtil.byteArrayToString(writer.encode()).toUpperCase();

    var expected = "0204028757B2";
    expect(content, expected);
  });

  test('negative integer test', () {
    var writer = AsnWriter();

    writer.writeInteger(-256);

    var content =
        PostchainUtil.byteArrayToString(writer.encode()).toUpperCase();

    var expected = "0202FF00";
    expect(content, expected);
  });

  test('sequence test', () {
    var writer = AsnWriter();

    writer.pushSequence();

    writer.pushSequence();
    writer.writeOctetString(PostchainUtil.hexStringToBuffer(
        "E2BE5C617CE50AFD0882A753C6FDA9C4D925EEDAC50DB97E33F457826A856DE0"));
    writer.popSequence();

    writer.pushSequence();
    writer.pushSequence();
    writer.writeUTF8String("test_op1");
    writer.writeUTF8String("arg1");
    writer.writeInteger(42);
    writer.popSequence();
    writer.pushSequence();
    writer.writeUTF8String("test_op2");
    writer.popSequence();
    writer.popSequence();

    writer.popSequence();

    var content =
        PostchainUtil.byteArrayToString(writer.encode()).toUpperCase();

    var expected =
        "304730220420E2BE5C617CE50AFD0882A753C6FDA9C4D925EEDAC50DB97E33F457826A856DE0302130130C08746573745F6F70310C046172673102012A300A0C08746573745F6F7032";
    expect(content, expected);
  });
}
