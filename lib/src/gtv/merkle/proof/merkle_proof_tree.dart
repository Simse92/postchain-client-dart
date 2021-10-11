import 'dart:math';
import 'dart:typed_data';
import 'package:collection/collection.dart';

import 'package:postchain_client/src/gtv/merkle/binary_tree.dart';
import 'package:postchain_client/src/gtv/merkle/path.dart';

class MerkleProofElement {}

class ProofNode implements MerkleProofElement {
  int prefix;
  MerkleProofElement left;
  MerkleProofElement right;

  ProofNode(this.prefix, this.left, this.right);
}

class ProofNodeSimple extends ProofNode {
  ProofNodeSimple(MerkleProofElement left, MerkleProofElement right)
      : super(HashPrefix.node.id, left, right);
}

class ProofValueLeaf implements MerkleProofElement {
  Object? content;
  final SearchablePathElement _pathElement;

  ProofValueLeaf(this.content, this._pathElement);
}

class ProofHashedLeaf implements MerkleProofElement {
  Uint8List merkleHash;

  ProofHashedLeaf(this.merkleHash);

  @override
  bool operator ==(other) {
    return (other is ProofHashedLeaf) &&
        IterableEquality().equals(other.merkleHash, merkleHash);
  }

  @override
  int get hashCode => merkleHash.hashCode;
}

class ProofNodeArrayHead extends ProofNode {
  SearchablePathElement? _pathElement;

  ProofNodeArrayHead(MerkleProofElement left, MerkleProofElement right,
      SearchablePathElement? pathElem)
      : super(HashPrefix.nodeArray.id, left, right) {
    _pathElement = pathElem;
  }
}

class ProofNodeDictHead extends ProofNode {
  SearchablePathElement? _pathElement;

  ProofNodeDictHead(MerkleProofElement left, MerkleProofElement right,
      SearchablePathElement? pathElem)
      : super(HashPrefix.nodeDict.id, left, right) {
    _pathElement = pathElem;
  }
}

class MerkleProofTree {
  MerkleProofElement root;

  MerkleProofTree(this.root);

  int maxLevel() {
    return _maxLevelInternal(root);
  }

  int _maxLevelInternal(MerkleProofElement node) {
    if (node is ProofValueLeaf || node is ProofHashedLeaf) {
      return 1;
    } else if (node is ProofNode) {
      return max(_maxLevelInternal(node.left), _maxLevelInternal(node.right)) +
          1;
    } else {
      throw Exception(
          "Should be able to handle node type: " + node.runtimeType.toString());
    }
  }
}
