import 'package:postchain_client/src/gtv/a_value.dart';
import 'package:postchain_client/src/gtv/array_value.dart';
import 'package:postchain_client/src/gtx/gtx.dart';
import 'package:collection/collection.dart';

class Operation {
  String opName;
  late List<AValue> args;
  final List<Object?> _rawArgs;

  Operation(this.opName, this._rawArgs) {
    args = List<AValue>.empty(growable: true);

    for (var opArg in _rawArgs) {
      args.add(Gtx.argToGtxValue(opArg));
    }
  }

  @override
  bool operator ==(other) {
    return (other is Operation) &&
        other.opName == opName &&
        IterableEquality().equals(other._rawArgs, _rawArgs);
  }

  @override
  int get hashCode => opName.hashCode;

  AValue toGtxValue() {
    var value = List<AValue>.empty(growable: true);
    value.add(Gtx.argToGtxValue(opName));
    value.addAll(args);

    return ArrayValue(value);
  }

  List<Object?> raw() {
    return List.from([opName, _rawArgs]);
  }

  @override
  String toString() {
    return opName + " (" + args.toString() + ")";
  }
}
