import 'dart:typed_data';

import 'package:postchain_client/src/gtv/merkle/binary_tree_factory.dart';
import 'package:postchain_client/src/gtv/merkle/merkle_hash_calculator.dart';
import 'package:postchain_client/src/gtv/merkle/proof/merkle_hash_carrier.dart';
import 'package:postchain_client/src/gtv/merkle/proof/merkle_hash_summary_factory.dart';
import 'package:postchain_client/src/gtv/merkle/proof/merkle_proof_tree.dart';
import 'package:postchain_client/src/gtv/merkle/proof/merkle_proof_tree_factory.dart';

class MerkleProof {
  static final BinaryTreeFactory _treeFactory = BinaryTreeFactory();
  static final MerkleProofTreeFactory _proofFactory = MerkleProofTreeFactory();

  static Uint8List merkleHash(Object value, MerkleHashCalculator calculator) {
    return merkleHashSummary(value, calculator).merkleHash;
  }

  static Uint8List merkleTreeHash(
      MerkleProofTree tree, MerkleHashCalculator calculator) {
    return merkleProofHashSummary(tree, calculator).merkleHash;
  }

  static MerkleHashSummary merkleHashSummary(
      Object value, MerkleHashCalculator calculator) {
    var summaryFactory = MerkleHashSummaryFactory(_treeFactory, _proofFactory);
    return summaryFactory.calculateMerkleRoot(value, calculator);
  }

  static MerkleHashSummary merkleProofHashSummary(
      MerkleProofTree tree, MerkleHashCalculator calculator) {
    var summaryFactory = MerkleHashSummaryFactory(_treeFactory, _proofFactory);
    return summaryFactory.calculateMerkleTreeRoot(tree, calculator);
  }
}
