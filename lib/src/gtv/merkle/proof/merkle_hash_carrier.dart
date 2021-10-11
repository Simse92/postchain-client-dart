import 'package:collection/collection.dart';
import 'dart:typed_data';

class MerkleHashSummary {
  final Uint8List merkleHash;

  MerkleHashSummary(this.merkleHash);

  @override
  bool operator ==(other) {
    return (other is MerkleHashSummary) &&
        IterableEquality().equals(other.merkleHash, merkleHash);
  }

  @override
  int get hashCode => merkleHash.hashCode;
}
