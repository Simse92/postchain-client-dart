import 'dart:typed_data';

import 'package:postchain_client/src/gtx/gtx.dart';
import 'package:postchain_client/src/postchain_util.dart';
import 'package:test/test.dart';

main() {
  test('empty operation test', () {
    var privKey = PostchainUtil.makeKeyPair();
    var gtx = Gtx("abcdef1234567890abcdef1234567890");

    gtx.addOperationToGtx("test", []);

    gtx.addSignerToGtx(privKey.publicKey);
    gtx.sign(privKey, privKey.publicKey);

    var encode = gtx.encode();
    var decoded = Gtx.decode(encode);

    expect(gtx.blockchainID, decoded.blockchainID);
    expect(gtx.signatures, decoded.signatures);
    expect(gtx.signers, decoded.signers);
    expect(gtx.operations, decoded.operations);
  });

  test('simple operation test', () {
    var privKey = PostchainUtil.makeKeyPair();
    var gtx = Gtx("abcdef1234567890abcdef1234567890");

    gtx.addOperationToGtx("test", ["teststring"]);

    gtx.addSignerToGtx(privKey.publicKey);
    gtx.sign(privKey, privKey.publicKey);

    var encode = gtx.encode();
    var decoded = Gtx.decode(encode);

    expect(gtx.blockchainID, decoded.blockchainID);
    expect(gtx.signatures, decoded.signatures);
    expect(gtx.signers, decoded.signers);
    expect(gtx.operations, decoded.operations);
  });

  test('multi signature operation test', () {
    var privKey = PostchainUtil.makeKeyPair();
    var privKey2 = PostchainUtil.makeKeyPair();
    var gtx = Gtx("abcdef1234567890abcdef1234567890");

    gtx.addOperationToGtx("test", ["teststring"]);

    gtx.addSignerToGtx(privKey.publicKey);
    gtx.addSignerToGtx(privKey2.publicKey);
    gtx.sign(privKey, privKey.publicKey);
    gtx.sign(privKey2, privKey2.publicKey);

    var encode = gtx.encode();
    var decoded = Gtx.decode(encode);

    expect(gtx.blockchainID, decoded.blockchainID);
    expect(gtx.signatures, decoded.signatures);
    expect(gtx.signers, decoded.signers);
    expect(gtx.operations, decoded.operations);
  });

  test('full operation test', () {
    var privKey = PostchainUtil.makeKeyPair();
    var gtx = Gtx("abcdef1234567890abcdef1234567890");

    gtx.addOperationToGtx("test", [
      "teststring",
      123,
      Uint8List.fromList([0xaf, 0xfe])
    ]);

    gtx.addSignerToGtx(privKey.publicKey);
    gtx.sign(privKey, privKey.publicKey);

    var encode = gtx.encode();
    var decoded = Gtx.decode(encode);

    expect(gtx.blockchainID, decoded.blockchainID);
    expect(gtx.signatures, decoded.signatures);
    expect(gtx.signers, decoded.signers);
    // equals for inner byte array
    // expect(gtx.operations, decoded.operations);
  });

  test('comparable operation test', () {
    var privBytes = PostchainUtil.hexStringToBuffer(
        "a3a0b4cd66de47ad5fce84300cc31b0b6ae9713ab9cec6f2de56f6b77817948f");
    var privKey = PostchainUtil.createPrivateFromBytes(privBytes);

    var gtx = Gtx("abcdef1234567890abcdef1234567890");

    gtx.addOperationToGtx("test", ["teststring"]);

    gtx.addSignerToGtx(privKey.publicKey);
    gtx.sign(privKey, privKey.publicKey);

    var encode = gtx.encode();
    var decoded = Gtx.decode(encode);

    expect(gtx.blockchainID, decoded.blockchainID);
    expect(gtx.signatures, decoded.signatures);
    expect(gtx.signers, decoded.signers);
    expect(gtx.operations, decoded.operations);
  });

  test('test operation test', () {
    var encode = PostchainUtil.hexStringToBuffer(
        "A581AE3081ABA561305FA1120410ABCDEF1234567890ABCDEF1234567890A520301EA51C301AA2060C0474657374A510300EA20C0C0A74657374737472696E67A5273025A123042102AE9F061829533B2E15EE723E39FC3084D1FF31E8779A68C25444006A06C1832CA5463044A1420440395D343D44BA16D9CBB9A532FF05509BF676503EAA5715882528AE92A97B311721776ABE6F66A5A07ABABC822743796863041AF0CA4473800EC3EA225DCB3034");
    var decoded = Gtx.decode(encode);
    print(decoded);
  });
}
