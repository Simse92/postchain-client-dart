import 'dart:typed_data';

import 'package:postchain_client/src/gtv/merkle/merkle_hash_calculator.dart';
import 'package:postchain_client/src/gtv/merkle/proof/merkle_proof.dart';

class Gtv {
  static Uint8List hash(Object obj) {
    return MerkleProof.merkleHashSummary(
            obj, MerkleHashCalculator(CryptoSystem()))
        .merkleHash;
  }
}
