import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:postchain_client/src/gtx_client.dart';

class RESTClient {
  String? blockchainRID;
  final String _urlBase;

  ///<summary>
  ///Create new RESTClient object.
  ///</summary>
  ///<param name = "urlBase">URL to rest server.</param>
  ///<param name = "blockchainRID">RID of blockchain.</param>
  RESTClient(this._urlBase, {this.blockchainRID});

  Future<Object> postTransaction(String serializedTransaction) async {
    var jsonString = jsonEncode({"tx": serializedTransaction});
    print(jsonString);
    return await post(_urlBase, "tx/" + blockchainRID!, jsonString);
  }

  Future<Object> postAndWaitConfirmation(
      String serializedTransaction, String txRID) async {
    await postTransaction(serializedTransaction);
    return await waitConfirmation(txRID);
  }

  Future<dynamic> query(
      String queryName, Map<String, Object> queryObject) async {
    var entries = queryObject.entries;

    var obj = Map<String, Object>.fromEntries([MapEntry("type", queryName)]);
    obj.addEntries(entries);

    String queryString = jsonEncode(obj);

    return await post(_urlBase, "query/" + blockchainRID!, queryString);
  }

  Future<dynamic> post(String urlBase, String path, String jsonString) async {
    try {
      var url = Uri.parse(urlBase + path);
      print(url);
      var response = await http.post(url, body: jsonString);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return response.body;
    } catch (e) {
      print(e.toString());
      return HTTPStatusResponse("exception", e.toString());
    }
  }

  Future<Object> waitConfirmation(String txRID) async {
    var response = await status(txRID);
    print(response);

    switch (response["status"]) {
      case "confirmed":
        return PostchainErrorControl(false, "");
      case "rejected":
        return PostchainErrorControl(true, response["rejectReason"]);
      case "unknown":
        return PostchainErrorControl(true, "");
      case "waiting":
        await Future.delayed(Duration(milliseconds: 511));
        return await waitConfirmation(txRID);
      case "exception":
        return PostchainErrorControl(
            true, "HTTP Exception: " + response["rejectReason"]);
      default:
        return PostchainErrorControl(
            true, "Got unexpected response from server: " + response["status"]);
    }
  }

  Future<dynamic> status(String messageHash) async {
    return await get(
        _urlBase, "tx/" + blockchainRID! + "/" + messageHash + "/status");
  }

  Future<dynamic> get(String urlBase, String path) async {
    var url = Uri.parse(urlBase + path);

    try {
      var response = await http.get(url);
      return jsonDecode(response.body);
    } catch (e) {
      print(e.toString());
      return HTTPStatusResponse("exception", e.toString());
    }
  }
}

class HTTPStatusResponse {
  String status;
  String rejectReason;

  HTTPStatusResponse(this.status, this.rejectReason);
}
