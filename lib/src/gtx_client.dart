import 'package:postchain_client/src/gtx/gtx.dart';
import 'package:postchain_client/src/rest_client.dart';
import 'package:postchain_client/src/transaction.dart';
import 'package:elliptic/elliptic.dart';

class GTXClient {
  final RESTClient _restClient;

  GTXClient(this._restClient);

  ///<summary>
  ///Create a new Transaction.
  ///</summary>
  ///<param name = "signers">Array of signers (can be null).</param>
  ///<returns>New Transaction object.</returns>
  Transaction newTransaction(List<PublicKey> signers) {
    Gtx newGtx = Gtx(_restClient.blockchainRID!);

    for (var signer in signers) {
      newGtx.addSignerToGtx(signer);
    }

    return Transaction(newGtx, _restClient);
  }

  ///<summary>
  ///Send a query to the node.
  ///</summary>
  ///<param name = "queryName">Name of the query to be called.</param>
  ///<param name = "queryObject">List of parameter pairs of query parameter name and its value. For example {"city", "Hamburg"}.</param>
  ///<returns>Task, which returns the query return content.</returns>
  Future<Object> query(String queryName, queryObject) async {
    var queryContent = await _restClient.query(queryName, queryObject);

    return queryContent;
  }
}

class PostchainErrorControl {
  bool error;
  String message;

  PostchainErrorControl(this.error, this.message);
}
