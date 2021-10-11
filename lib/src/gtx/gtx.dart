import 'dart:typed_data';

import 'package:postchain_client/src/asn1/asn_reader.dart';
import 'package:postchain_client/src/gtv/a_value.dart';
import 'package:postchain_client/src/gtv/array_value.dart';
import 'package:postchain_client/src/gtv/dict_value.dart';
import 'package:postchain_client/src/gtv/gtv.dart';
import 'package:postchain_client/src/gtv/integer_value.dart';
import 'package:postchain_client/src/gtv/null_value.dart';
import 'package:postchain_client/src/gtv/octet_string_value.dart';
import 'package:postchain_client/src/gtv/utf8_string_value.dart';
import 'package:postchain_client/src/gtx/operation.dart';
import 'package:postchain_client/src/postchain_util.dart';
import 'package:elliptic/elliptic.dart';

class Gtx {
  String blockchainID;
  List<Operation> operations = List.empty(growable: true);
  List<PublicKey> signers = List.empty(growable: true);
  List<Uint8List?> signatures = List.empty(growable: true);

  Gtx(this.blockchainID);

  Gtx addOperationToGtx(String opName, List<Object?> args) {
    if (signatures.isNotEmpty) {
      throw Exception("Cannot add function calls to an already signed gtx");
    }

    operations.add(Operation(opName, args));
    return this;
  }

  static AValue argToGtxValue(Object? arg) {
    if (arg == null) {
      return NullValue();
    } else if (arg is int) {
      return IntegerValue(arg);
    } else if (arg is Uint8List) {
      return OctetStringValue(arg);
    } else if (arg is String) {
      return UTF8StringValue(arg);
    } else if (arg is List<Object?>) {
      var value = List<AValue>.empty(growable: true);

      for (var subArg in arg) {
        value.add(argToGtxValue(subArg));
      }

      return ArrayValue(value);
    } else if (arg is Map<String, Object?>) {
      var value = <String, AValue>{};
      for (MapEntry<String, Object?> e in arg.entries) {
        value.putIfAbsent(e.key, () => argToGtxValue(e.value));
      }
      return DictValue(value);
    } else if (arg is Operation) {
      return arg.toGtxValue();
    } else {
      throw Exception("Gtx.ArgToGTXValue() Can't create GTXValue out of type " +
          arg.runtimeType.toString());
    }
  }

  void addSignerToGtx(PublicKey signer) {
    if (signatures.isNotEmpty) {
      throw Exception("Cannot add signers to an already signed gtx");
    }

    signers.add(signer);
  }

  void sign(PrivateKey privKey, PublicKey pubKey) {
    var bufferToSign = getBufferToSign();
    print("bufferToSign: " + PostchainUtil.byteArrayToString(bufferToSign));
    var signature = PostchainUtil.sign(bufferToSign, privKey);
    print("signature: " + PostchainUtil.byteArrayToString(signature));
    addSignature(pubKey, signature);
  }

  Uint8List getBufferToSign() {
    var encodedBuffer = Gtv.hash(getGtvTxBody());
    return encodedBuffer;
  }

  List<Object?> getGtvTxBody() {
    var body = List<Object?>.empty(growable: true);
    body.add(PostchainUtil.hexStringToBuffer(blockchainID));

    body.add(operations.map((e) => e.raw()).toList());
    body.add(signers
        .map((e) => PostchainUtil.hexStringToBuffer(e.toCompressedHex()))
        .toList());

    return body;
  }

  void addSignature(PublicKey pubKey, Uint8List signature) {
    if (signatures.isEmpty) {
      signatures = List.generate(signers.length, (index) => null);
    }

    int signerIndex = signers.indexWhere((element) => element == pubKey);

    if (signerIndex == -1) {
      throw Exception(
          "No such signer, remember to call addSignerToGtx() before adding a signature");
    }

    signatures[signerIndex] = signature;
  }

  String serialize() {
    return PostchainUtil.byteArrayToString(encode());
  }

  Uint8List encode() {
    var gtxBody = List<Object?>.empty(growable: true);

    gtxBody.add(getGtvTxBody());
    gtxBody.add(signatures);

    return argToGtxValue(gtxBody).encode();
  }

  static Gtx decode(Uint8List encodedMessage) {
    var gtx = Gtx("");
    var gtxTransaction = AsnReader(encodedMessage);
    var gtxValue = AValue.decode(gtxTransaction);

    var gtxPayLoad = gtxValue.value.first;

    gtx.blockchainID =
        PostchainUtil.byteArrayToString(gtxPayLoad.value.first.value);

    for (var opArr in gtxPayLoad.value[1].value) {
      var opName = opArr.value[0].value;
      var opArgs = opArr.value[1].toObjectArray();

      gtx.addOperationToGtx(opName, opArgs);
    }

    var ec = getSecp256k1();
    for (var signer in gtxPayLoad.value[2].value) {
      var pubkey =
          PublicKey.fromHex(ec, PostchainUtil.byteArrayToString(signer.value));
      gtx.addSignerToGtx(pubkey);
    }

    for (var sig in gtxValue.value![1].value!) {
      gtx.signatures.add(sig.value!);
    }

    return gtx;
  }
}
