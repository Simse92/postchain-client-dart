import 'dart:typed_data';

import 'package:postchain_client/src/gtv/merkle/binary_tree.dart';
import 'package:postchain_client/src/gtv/merkle/path.dart';

class BinaryTreeFactory {
  BinaryTreeElement handleLeaf(Object? leaf, PathSet paths, bool isRoot) {
    if (paths.isEmpty() && isRoot == false) {
      return _innerHandleLeaf(leaf, _getEmptyPathSet());
    } else {
      return _innerHandleLeaf(leaf, paths);
    }
  }

  PathSet _getEmptyPathSet() {
    return PathSet(List<Path>.empty(growable: true));
  }

  BinaryTreeElement _innerHandleLeaf(Object? leaf, PathSet paths) {
    if (leaf == null || leaf is Uint8List || leaf is String || leaf is int) {
      return _handlePrimitiveLeaf(leaf, paths);
    } else if (leaf is List<Object?>) {
      return buildFromArray(leaf, paths);
    } else if (leaf is Map<String, Object>) {
      return _buildFromDictionary(leaf, paths);
    } else {
      throw Exception("Unsupporting data type: " + leaf.runtimeType.toString());
    }
  }

  BinaryTreeElement _handlePrimitiveLeaf(Object? leaf, PathSet paths) {
    var pathElem = paths.getPathLeafOrElseAnyCurrentPathElement();

    if (pathElem != null && pathElem is! PathLeafElement) {
      throw Exception(
          "Path does not match the tree structure. We are at a leaf " +
              leaf.toString() +
              " but found path element " +
              pathElem.toString());
    }

    return Leaf(leaf, pathElem);
  }

  List<BinaryTreeElement> buildHigherLayer(
      int layer, List<BinaryTreeElement> inList) {
    if (inList.isEmpty) {
      throw Exception(
          "Cannot work on empty arrays. Layer: " + layer.toString());
    } else if (inList.length == 1) {
      return inList;
    }

    var returnArray = List<BinaryTreeElement>.empty(growable: true);
    int nrOfNodesToCreate = (inList.length / 2).floor();
    BinaryTreeElement? leftValue;
    var isLeft = true;

    for (var element in inList) {
      if (isLeft) {
        leftValue = element;
        isLeft = false;
      } else {
        var tempNode = Node(leftValue as BinaryTreeElement, element);
        returnArray.add(tempNode);
        nrOfNodesToCreate--;
        isLeft = true;
        leftValue = null;
      }
    }

    if (!isLeft) {
      returnArray.add(leftValue as BinaryTreeElement);
    }

    if (nrOfNodesToCreate != 0) {
      throw Exception(
          "Why didn't we build exactly the correct amount? Layer: " +
              layer.toString() +
              " , residue: " +
              nrOfNodesToCreate.toString() +
              " , input args size: " +
              inList.length.toString() +
              ".");
    }

    return buildHigherLayer(layer + 1, returnArray);
  }

  BinaryTree build(Object data) {
    return buildWithPath(data, _getEmptyPathSet());
  }

  BinaryTree buildWithPath(Object data, PathSet paths) {
    var result = handleLeaf(data, paths, true);
    return BinaryTree(result);
  }

  ArrayHeadNode<List<Object?>> buildFromArray(
      List<Object?> array, PathSet paths) {
    var pathElem = paths.getPathLeafOrElseAnyCurrentPathElement();

    if (array.isEmpty) {
      return ArrayHeadNode(EmptyLeaf(), EmptyLeaf(), array, pathElem);
    }

    var leafArray = _buildLeafElements(array, paths);
    var result = buildHigherLayer(1, leafArray);

    var orgRoot = result[0];
    if (orgRoot is Node) {
      return ArrayHeadNode(orgRoot.left, orgRoot.right, array, pathElem);
    }

    if (orgRoot is Leaf) {
      return buildFromOneLeaf(array, orgRoot, pathElem);
    } else {
      throw Exception("Should not find element of this type here");
    }
  }

  ArrayHeadNode<List<Object?>> buildFromOneLeaf(
      List<Object?> array, BinaryTreeElement orgRoot, PathElement? pathElem) {
    if (array.length > 1) {
      throw Exception("How come we got a leaf returned when we had " +
          array.length.toString() +
          " elements is the args?");
    } else {
      return ArrayHeadNode(orgRoot, EmptyLeaf(), array, pathElem);
    }
  }

  List<BinaryTreeElement> _buildLeafElements(
      List<Object?> leafList, PathSet paths) {
    var leafArray = List<BinaryTreeElement>.empty(growable: true);
    var onlyArrayPaths = paths.keepOnlyArrayPaths();

    for (var i = 0; i < leafList.length; i++) {
      var pathsRelevantForThisLeaf =
          onlyArrayPaths.getTailIfFirstElementIsArrayOfThisIndexFromList(i);
      var leaf = leafList[i];
      var binaryTreeElement = handleLeaf(leaf, pathsRelevantForThisLeaf, false);
      leafArray.add(binaryTreeElement);
    }

    return leafArray;
  }

  DictHeadNode<Map<String, Object?>> _buildFromDictionary(
      Map<String, Object> dict, PathSet paths) {
    var pathElem = paths.getPathLeafOrElseAnyCurrentPathElement();

    var keys = List<String>.from(dict.keys);

    if (keys.isEmpty) {
      return DictHeadNode(EmptyLeaf(), EmptyLeaf(), dict, pathElem);
    }
    keys.sort();

    var leafArray = _buildLeafElementFromDict(keys, dict, paths);
    var result = buildHigherLayer(1, leafArray);

    var orgRoot = result[0];
    if (orgRoot is Node) {
      return DictHeadNode(orgRoot.left, orgRoot.right, dict, pathElem);
    } else {
      throw Exception("Should not find element of this type here");
    }
  }

  List<BinaryTreeElement> _buildLeafElementFromDict(
      List<String> keys, Map<String, Object> dict, PathSet paths) {
    var leafArray = List<BinaryTreeElement>.empty(growable: true);
    var onlyDictPaths = paths.keepOnlyDictPaths();

    for (var i = 0; i < keys.length; i++) {
      var key = keys[i];
      var keyElement = handleLeaf(key, _getEmptyPathSet(), false);
      leafArray.add(keyElement);

      var content = dict[key];
      var pathsRelevantForThisLeaf =
          onlyDictPaths.getTailIfFirstElementIsDictOfThisKeyFromList(key);
      var contentElement = handleLeaf(content, pathsRelevantForThisLeaf, false);
      leafArray.add(contentElement);
    }

    return leafArray;
  }
}
