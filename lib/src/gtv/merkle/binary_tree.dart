import 'package:postchain_client/src/gtv/merkle/path.dart';

enum HashPrefix { node, leaf, nodeArray, nodeDict }

extension HashPrefixExt on HashPrefix {
  int get id {
    switch (this) {
      case HashPrefix.node:
        return 0;
      case HashPrefix.leaf:
        return 1;
      case HashPrefix.nodeArray:
        return 7;
      case HashPrefix.nodeDict:
        return 8;
      default:
        return -1;
    }
  }
}

abstract class BinaryTreeElement {
  PathElement? pathElem;

  void setPathElement(PathElement? pathElem) {
    this.pathElem = pathElem;
  }

  int getPrefixByte();
}

class Node extends BinaryTreeElement {
  BinaryTreeElement left;
  BinaryTreeElement right;

  Node(this.left, this.right);

  @override
  int getPrefixByte() {
    return HashPrefix.node.id;
  }
}

class SubTreeRootNode<T> extends Node {
  T content;

  SubTreeRootNode(BinaryTreeElement left, BinaryTreeElement right, this.content,
      PathElement? pathElem)
      : super(left, right) {
    setPathElement(pathElem);
  }
}

class Leaf extends BinaryTreeElement {
  Object? content;

  Leaf(this.content, PathElement? pathElem) {
    if (pathElem != null) {
      if (pathElem is PathLeafElement) {
        setPathElement(pathElem);
      } else {
        throw Exception(
            "The path and object structure does not match! We are at a leaf, but the path expects a sub structure.");
      }
    }
  }

  @override
  int getPrefixByte() {
    return HashPrefix.leaf.id;
  }
}

class EmptyLeaf extends BinaryTreeElement {
  @override
  int getPrefixByte() {
    return HashPrefix.node.id;
  }
}

class BinaryTree {
  BinaryTreeElement root;

  BinaryTree(this.root);
}

class ArrayHeadNode<T> extends SubTreeRootNode<T> {
  ArrayHeadNode(BinaryTreeElement left, BinaryTreeElement right, T content,
      PathElement? pathElem)
      : super(left, right, content, pathElem);

  @override
  int getPrefixByte() {
    return HashPrefix.nodeArray.id;
  }
}

class DictHeadNode<T> extends SubTreeRootNode<T> {
  DictHeadNode(BinaryTreeElement left, BinaryTreeElement right, T content,
      PathElement? pathElem)
      : super(left, right, content, pathElem);

  @override
  int getPrefixByte() {
    return HashPrefix.nodeDict.id;
  }
}
