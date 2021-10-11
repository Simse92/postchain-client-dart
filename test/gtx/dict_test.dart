import 'package:postchain_client/src/asn1/asn_reader.dart';
import 'package:postchain_client/src/gtv/a_value.dart';
import 'package:postchain_client/src/gtv/dict_value.dart';
import 'package:postchain_client/src/gtv/utf8_string_value.dart';
import 'package:test/test.dart';

main() {
  test('simple dict test', () {
    var map = <String, AValue>{};
    map.putIfAbsent("name", () => UTF8StringValue("Bertha"));
    var val = DictValue(map);

    var decoded = AValue.decode(AsnReader(val.encode()));
    expect(decoded.runtimeType, val.runtimeType);
    expect(decoded.value.length, val.value.length);
    expect(decoded.value.values.first.value, "Bertha");
    expect(decoded.value.keys.first, "name");
  });
}
