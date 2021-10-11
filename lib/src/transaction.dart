import 'package:postchain_client/src/gtx/gtx.dart';
import 'package:postchain_client/src/postchain_util.dart';
import 'package:postchain_client/src/rest_client.dart';
import 'package:elliptic/elliptic.dart';

class Transaction {
  Gtx gtxObject;
  final RESTClient _restClient;

  Transaction(this.gtxObject, this._restClient);

  ///<summary>
  ///Add an operation to the Transaction.
  ///</summary>
  ///<param name = "name">Name of the operation.</param>
  ///<param name = "args">Array of object parameters. For example {"Hamburg", 42}</param>
  void addOperation(String name, dynamic args) {
    gtxObject.addOperationToGtx(name, args);
  }

  ///<summary>
  ///Commit the Transaction and send it to the blockchain.
  ///</summary>
  ///<returns>Task, which returns null if it was succesful or the error message if not.</returns>
  Future<Object> postAndWaitConfirmation() async {
    return await _restClient.postAndWaitConfirmation(
        gtxObject.serialize(), _getTxRID());
  }

  ///<summary>
  ///Commit the Transaction and send it to the blockchain.
  ///</summary>
  ///<returns>Task, which returns null if it was succesful or the error message if not.</returns>
  // Future<PostchainErrorControl> postAndWaitConfirmation() async {}

  void sign(PrivateKey privateKey) {
    gtxObject.sign(privateKey, privateKey.publicKey);
  }

  String _getTxRID() {
    return PostchainUtil.byteArrayToString(gtxObject.getBufferToSign());
  }
}
