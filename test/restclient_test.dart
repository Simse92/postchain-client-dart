import 'package:postchain_client/src/gtx_client.dart';
import 'package:postchain_client/src/postchain_util.dart';
import 'package:postchain_client/src/rest_client.dart';
import 'package:test/test.dart';

main() {
  test('restclient test', () async {
    var restclient = RESTClient("http://localhost:7740/",
        blockchainRID:
            "AC9E83560B275E917DE2BFE15BE92BEA44DB98C7B6A2F06BC0B3B32ECFB2E996");

    var gtx = GTXClient(restclient);
    var priv = PostchainUtil.makeKeyPair();
    var req = gtx.newTransaction([priv.publicKey]);
    req.addOperation("build_city", ["Hamburg", 25]);
    req.sign(priv);
    var result = await req.postAndWaitConfirmation();

    if (result is PostchainErrorControl) {
      print(result.message);
    }

    var test = await restclient.query("get_city", {"name": "Hamburg"});
    print(test);
  });
}
