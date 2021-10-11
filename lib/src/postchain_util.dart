import 'package:crypto/crypto.dart';
import 'package:ecdsa/ecdsa.dart';
import 'package:elliptic/elliptic.dart';
import 'dart:typed_data';
import 'package:hex/hex.dart';

class PostchainUtil {
  static Uint8List sha256Digest(Uint8List buffer) {
    var digest = sha256.convert(buffer);
    return Uint8List.fromList(digest.bytes);
  }

  //  @param content to sign. It will be digested before signing.
  //  @param privKey The private key to sign the content with
  //  @return the signature
  static Uint8List sign(Uint8List content, PrivateKey privKey) {
    if (privKey.bytes.length != 32) {
      throw Exception(
          "Programmer error. Invalid key length. Expected 32, but got " +
              privKey.bytes.length.toString());
    }

    return PostchainUtil.signDigest(content, privKey);
  }

  //  @param digestBuffer to sign. It will not be digested before signing.
  //  @param privKey The private key to sign the digest with
  //  @return the signature
  static Uint8List signDigest(Uint8List digestBuffer, PrivateKey privKey) {
    var sig = signature(privKey, digestBuffer);
    return Uint8List.fromList(sig.toCompact());
  }

  //  Creates a key pair (which usually represents one user)
  //  @returns privKey: PrivateKey
  static PrivateKey makeKeyPair() {
    var ec = getSecp256k1();
    return ec.generatePrivateKey();
  }

  static PrivateKey createPrivateFromBytes(Uint8List bytes) {
    var ec = getSecp256k1();
    return PrivateKey.fromBytes(ec, bytes);
  }

  //  Verify that keypair is correct. Providing the private key, this function returns its associated public key
  //  @param privKey: Buffer
  //  @returns PublicKey
  static PublicKey verifyKeyPair(PrivateKey priv) {
    return priv.publicKey;
  }

  static String byteArrayToString(Uint8List ba) {
    return HEX.encode(ba);
  }

  static Uint8List hexStringToBuffer(String hex) {
    return Uint8List.fromList(HEX.decode(hex));
  }

  static Uint8List bigIntToUint8List(BigInt bigInt) =>
      bigIntToByteData(bigInt).buffer.asUint8List();

  static ByteData bigIntToByteData(BigInt bigInt) {
    final data = ByteData((bigInt.bitLength / 8).ceil());
    var _bigInt = bigInt;

    for (var i = 1; i <= data.lengthInBytes; i++) {
      data.setUint8(data.lengthInBytes - i, _bigInt.toUnsigned(8).toInt());
      _bigInt = _bigInt >> 8;
    }

    return data;
  }

  static Uint8List intToUint8List(int integer) =>
      _intToByteData(integer).buffer.asUint8List();

  static ByteData _intToByteData(int integer) {
    final data = ByteData((integer.bitLength / 8).ceil());
    var _integer = integer;

    for (var i = 1; i <= data.lengthInBytes; i++) {
      data.setUint8(data.lengthInBytes - i, _integer.toUnsigned(8).toInt());
      _integer = _integer >> 8;
    }

    return data;
  }
}
