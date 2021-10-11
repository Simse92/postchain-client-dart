import 'package:collection/collection.dart';
import 'package:tuple/tuple.dart';
import 'dart:collection';

class Path {
  List<PathElement> pathElements;

  Path(this.pathElements);

  PathElement getCurrentPathElement() {
    return pathElements.first;
  }

  Path tail() {
    if (pathElements.isEmpty) {
      throw Exception("Impossible to tail empty array");
    }

    return Path(pathElements.skip(1).toList());
  }

  @override
  bool operator ==(other) {
    return (other is Path) &&
        IterableEquality().equals(other.pathElements, pathElements);
  }

  @override
  int get hashCode => pathElements.hashCode;
}

class PathElement {
  SearchablePathElement previous;

  PathElement(this.previous);
}

class PathLeafElement extends PathElement {
  PathLeafElement(SearchablePathElement previous) : super(previous);

  // todo Not neccessary?!
  // @override
  // bool operator ==(other) {
  //   return (other is MerkleHashSummary) &&
  //       IterableEquality().equals(other.merkleHash, merkleHash);
  // }

  // @override
  // int get hashCode => hashCode;
}

abstract class SearchablePathElement extends PathElement {
  SearchablePathElement(SearchablePathElement previous) : super(previous);

  Object getSearchKey();
}

class ArrayPathElement extends SearchablePathElement {
  final int _index;

  ArrayPathElement(SearchablePathElement previous, this._index)
      : super(previous);

  @override
  Object getSearchKey() {
    return _index;
  }

  @override
  bool operator ==(other) {
    return (other is ArrayPathElement) && other._index == _index;
  }

  @override
  int get hashCode => _index.hashCode;
}

class DictPathElement extends SearchablePathElement {
  final Object _key;

  DictPathElement(SearchablePathElement previous, this._key) : super(previous);

  @override
  Object getSearchKey() {
    return _key;
  }

  @override
  bool operator ==(other) {
    return (other is DictPathElement) && other._key == _key;
  }

  @override
  int get hashCode => _key.hashCode;
}

class PathSet {
  late HashSet<Path> _paths;

  PathSet(List<Path> pathList) {
    _paths = HashSet.from(pathList);
  }

  bool isEmpty() {
    return _paths.isEmpty;
  }

  PathElement? getPathLeafOrElseAnyCurrentPathElement() {
    PathLeafElement? leafElem;
    PathElement? currElem;
    Tuple2<Path, PathElement>? prev;

    for (var path in _paths) {
      currElem = path.getCurrentPathElement();
      if (currElem is PathLeafElement) {
        leafElem = currElem;
      }
      // weird behaviour
      prev = errorCheckUnequalParent(path, currElem, prev!.item1, prev.item2);
    }

    if (leafElem != null) {
      return leafElem;
    } else {
      return currElem;
    }
  }

  Tuple2<Path, PathElement> errorCheckUnequalParent(Path currPath,
      PathElement currElem, Path prevPath, PathElement? prevElem) {
    if (prevElem != null) {
      if (currElem.previous != prevElem.previous) {
        throw Exception(
            "Something is wrong, these paths do not have the same parent.");
      }
    }
    return Tuple2(currPath, currElem);
  }

  PathSet keepOnlyArrayPaths() {
    var filteredPaths = _paths
        .where((element) => element.pathElements.first is ArrayPathElement);
    return PathSet(filteredPaths.toList());
  }

  PathSet keepOnlyDictPaths() {
    var filteredPaths = _paths
        .where((element) => element.pathElements.first is DictPathElement);
    return PathSet(filteredPaths.toList());
  }

  PathSet getTailIfFirstElementIsArrayOfThisIndexFromList(int index) {
    var retPaths = List<Path>.empty(growable: true);

    for (var path in _paths) {
      var newPath = _getTail(index, path);
      if (newPath != null) {
        retPaths.add(newPath);
      }
    }

    return PathSet(retPaths);
  }

  Path? _getTail(Object searchKey, Path path) {
    try {
      var firstElement = path.pathElements.first;
      if (firstElement is SearchablePathElement &&
          firstElement.getSearchKey() == searchKey) {
        return path.tail();
      }
    } catch (e) {
      print("Why are we dropping first element of an empty path? " +
          e.toString());
      return null;
    }
    return null;
  }

  PathSet getTailIfFirstElementIsDictOfThisKeyFromList(String key) {
    var retPaths = List<Path>.empty(growable: true);
    for (var path in _paths) {
      var newPath = _getTail(key, path);
      if (newPath != null) {
        retPaths.add(newPath);
      }
    }
    return PathSet(retPaths);
  }
}
