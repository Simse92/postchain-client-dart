import 'dart:typed_data';
import 'package:postchain_client/src/gtv/merkle/binary_tree_factory.dart';
import 'package:postchain_client/src/gtv/merkle/merkle_hash_calculator.dart';
import 'package:postchain_client/src/gtv/merkle/proof/merkle_hash_carrier.dart';
import 'package:postchain_client/src/gtv/merkle/proof/merkle_proof_tree.dart';
import 'package:postchain_client/src/gtv/merkle/proof/merkle_proof_tree_factory.dart';

class MerkleHashSummaryFactory {
  BinaryTreeFactory treeFactory;
  MerkleProofTreeFactory proofTreeFactory;

  MerkleHashSummaryFactory(this.treeFactory, this.proofTreeFactory);

  MerkleHashSummary calculateMerkleRoot(
      Object value, MerkleHashCalculator calculator) {
    var binaryTree = treeFactory.build(value);
    var proofTree =
        proofTreeFactory.buildFromBinaryTree(binaryTree, calculator);

    return calculateMerkleTreeOfRoot(proofTree, calculator);
  }

  MerkleHashSummary calculateMerkleTreeRoot(
      MerkleProofTree tree, MerkleHashCalculator calculator) {
    return calculateMerkleTreeOfRoot(tree, calculator);
  }

  MerkleHashSummary calculateMerkleTreeOfRoot(
      MerkleProofTree proofTree, MerkleHashCalculator calculator) {
    var calculatedSummary =
        calculateMerkleRootInternal(proofTree.root, calculator);

    return MerkleHashSummary(calculatedSummary);
  }

  Uint8List calculateMerkleRootInternal(
      MerkleProofElement currentElement, MerkleHashCalculator calculator) {
    if (currentElement is ProofHashedLeaf) {
      return currentElement.merkleHash;
    } else if (currentElement is ProofValueLeaf) {
      var value = currentElement.content;
      return calculator.calculateLeafHash(value);
    } else if (currentElement is ProofNode) {
      var left = calculateMerkleRootInternal(currentElement.left, calculator);
      var right = calculateMerkleRootInternal(currentElement.right, calculator);

      return calculator.calculateNodeHash(currentElement.prefix, left, right);
    } else {
      throw Exception("Should have handled this type? " +
          currentElement.runtimeType.toString());
    }
  }

  MerkleProofTree buildProofTree(
      Object value, MerkleHashCalculator calculator) {
    var root = treeFactory.build(value);

    return proofTreeFactory.buildFromBinaryTree((root), calculator);
  }
}
