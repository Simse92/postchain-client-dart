import 'dart:typed_data';

import 'package:postchain_client/src/gtv/gtv.dart';
import 'package:postchain_client/src/postchain_util.dart';
import 'package:test/test.dart';

main() {
  test('simple hash test', () {
    var hash = Gtv.hash("test");
    var hashHex = PostchainUtil.byteArrayToString(hash).toUpperCase();

    expect(hashHex,
        "BD0582E368DFB006FA34A75F372F761D3CFB6CD58BF5E4853ADDF767F55D8265");
  });

  test('array hash test', () {
    var hash = Gtv.hash([
      "test",
      null,
      9223372036854775807,
      Uint8List.fromList([0xde, 0xad, 0xbe, 0xef]),
      List.empty()
    ]);
    var hashHex = PostchainUtil.byteArrayToString(hash).toUpperCase();

    expect(hashHex,
        "E74615C8E242EE865655B24A17B1454E0F14523520384903682CD31500907A2D");
  });
}
