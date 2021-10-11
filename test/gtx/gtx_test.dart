import 'package:postchain_client/src/gtx/gtx.dart';
import 'package:postchain_client/src/postchain_util.dart';
import 'package:test/test.dart';

main() {
  test('buffer to sign test', () {
    var privKey1 = PostchainUtil.makeKeyPair();
    var privKey2 = PostchainUtil.makeKeyPair();
    var gtx = Gtx("abcdef1234567890abcdef1234567890");

    gtx.addOperationToGtx("test", ["teststring"]);

    gtx.addSignerToGtx(privKey1.publicKey);
    gtx.addSignerToGtx(privKey2.publicKey);

    gtx.sign(privKey1, privKey1.publicKey);
    gtx.sign(privKey2, privKey2.publicKey);

    expect(gtx.signatures.length, 2);
  });
}
