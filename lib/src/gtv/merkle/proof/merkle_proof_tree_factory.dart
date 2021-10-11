import 'dart:typed_data';
import 'package:postchain_client/src/gtv/merkle/binary_tree.dart';
import 'package:postchain_client/src/gtv/merkle/merkle_hash_calculator.dart';
import 'package:postchain_client/src/gtv/merkle/path.dart';
import 'package:postchain_client/src/gtv/merkle/proof/merkle_proof_tree.dart';

class MerkleProofTreeFactory {
  MerkleProofTree buildFromBinaryTree(
      BinaryTree originalTree, MerkleHashCalculator calculator) {
    var rootElem = buildFromBinaryTreeInternal(originalTree.root, calculator);
    return MerkleProofTree(rootElem);
  }

  MerkleProofElement buildFromBinaryTreeInternal(
      BinaryTreeElement currentElement, MerkleHashCalculator calculator) {
    if (currentElement is EmptyLeaf) {
      return ProofHashedLeaf(Uint8List(32));
    } else if (currentElement is Leaf) {
      var pathElem = currentElement.pathElem;

      if (pathElem != null) {
        if (pathElem is PathLeafElement) {
          return ProofValueLeaf(currentElement.content, pathElem.previous);
        } else {
          throw Exception(
              "The path and structure don't match. We are at a leaf, but path elem is not a leaf: " +
                  pathElem.runtimeType.toString());
        }
      } else {
        var hash = calculator.calculateLeafHash(currentElement.content);
        return ProofHashedLeaf(hash);
      }
    } else if (currentElement is SubTreeRootNode<Object>) {
      var pathElem = currentElement.pathElem;

      if (pathElem != null) {
        if (pathElem is PathLeafElement) {
          return ProofValueLeaf(currentElement.content, pathElem.previous);
        } else {
          return convertNode(currentElement, calculator);
        }
      } else {
        return convertNode(currentElement, calculator);
      }
    } else if (currentElement is Node) {
      return convertNode(currentElement, calculator);
    } else {
      throw Exception("Cannot handle " + currentElement.runtimeType.toString());
    }
  }

  MerkleProofElement convertNode(Node node, MerkleHashCalculator calculator) {
    var left = buildFromBinaryTreeInternal(node.left, calculator);
    var right = buildFromBinaryTreeInternal(node.right, calculator);

    if (left is ProofHashedLeaf && right is ProofHashedLeaf) {
      var addedHash = calculator.calculateNodeHash(
          node.getPrefixByte(), left.merkleHash, right.merkleHash);

      return ProofHashedLeaf(addedHash);
    } else {
      return buildNodeOfCorrectType(node, left, right);
    }
  }

  SearchablePathElement? extractSearchablePathElement(Node node) {
    var pathElem = node.pathElem;

    if (pathElem != null) {
      return pathElem.previous;
    } else {
      return null;
    }
  }

  ProofNode buildNodeOfCorrectType(
      Node node, MerkleProofElement left, MerkleProofElement right) {
    if (node is ArrayHeadNode<List<Object>>) {
      return ProofNodeArrayHead(
          left, right, extractSearchablePathElement(node));
    } else if (node is DictHeadNode<Map<String, Object>>) {
      return ProofNodeDictHead(left, right, extractSearchablePathElement(node));
    } else if (node is Node) {
      return ProofNodeSimple(left, right);
    } else {
      throw Exception("Should have taken care of this node type: " +
          node.runtimeType.toString());
    }
  }
}
