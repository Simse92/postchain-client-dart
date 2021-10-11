import 'dart:typed_data';

import 'package:postchain_client/src/gtv/merkle/binary_tree.dart';
import 'package:postchain_client/src/postchain_util.dart';
import 'package:postchain_client/src/gtv/a_value.dart';
import 'package:postchain_client/src/gtx/gtx.dart';

class CryptoSystem {
  Uint8List digest(Uint8List buffer) {
    return PostchainUtil.sha256Digest(buffer);
  }
}

class MerkleHashCalculator {
  final CryptoSystem _cryptoSystem;

  MerkleHashCalculator(this._cryptoSystem);

  Uint8List hashingFun(Uint8List buffer) {
    return _cryptoSystem.digest(buffer);
  }

  Uint8List calculateNodeHash(
      int prefix, Uint8List hashLeft, Uint8List hashRight) {
    return _calculateNodeHashInternal(prefix, hashLeft, hashRight);
  }

  Uint8List calculateLeafHash(Object? value) {
    var gtxValue = Gtx.argToGtxValue(value);
    return _calculateHashOfValueInternal(gtxValue);
  }

  Uint8List _calculateNodeHashInternal(
      int prefix, Uint8List hashLeft, Uint8List hashRight) {
    BytesBuilder buf = BytesBuilder();
    buf.addByte(prefix);
    buf.add(hashLeft);
    buf.add(hashRight);

    return hashingFun(buf.toBytes());
  }

  Uint8List _calculateHashOfValueInternal(AValue gtxValue) {
    BytesBuilder buf = BytesBuilder();
    buf.addByte(HashPrefix.leaf.id);
    buf.add(gtxValue.encode());

    return hashingFun(buf.toBytes());
  }
}
