import 'dart:async';

import 'package:flutterrtdeliveryboyapp/api/common/ps_resource.dart';
import 'package:flutterrtdeliveryboyapp/api/common/ps_status.dart';
import 'package:flutterrtdeliveryboyapp/provider/common/ps_provider.dart';
import 'package:flutterrtdeliveryboyapp/repository/transaction_header_repository.dart';
import 'package:flutterrtdeliveryboyapp/utils/utils.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/api_status.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/common/ps_value_holder.dart';

class OrderAcceptProvider extends PsProvider {
  OrderAcceptProvider(
      {required TransactionHeaderRepository repo,
      required this.psValueHolder,
      int limit = 0})
      : super(repo, limit) {
    _repo = repo;

    print('Pending order Provider: $hashCode');

    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;
    });

    //
    transactionHeaderStream =
        StreamController<PsResource<ApiStatus>>.broadcast();
    subscriptionObject = transactionHeaderStream.stream
        .listen((PsResource<ApiStatus> resource) {
      _transactionHeader = resource;

      if (resource.status != PsStatus.BLOCK_LOADING &&
          resource.status != PsStatus.PROGRESS_LOADING) {
        isLoading = false;
      }

      if (!isDispose) {
        notifyListeners();
      }
    });
  }

  TransactionHeaderRepository? _repo;
  PsValueHolder? psValueHolder;

  PsResource<ApiStatus> get transactionHeader => _transactionHeader;
  PsResource<ApiStatus> _transactionHeader =
      PsResource<ApiStatus>(PsStatus.NOACTION, '', null);
  late StreamSubscription<PsResource<ApiStatus>> subscriptionObject;
  late StreamController<PsResource<ApiStatus>> transactionHeaderStream;

  @override
  void dispose() {
    subscriptionObject.cancel();
    isDispose = true;
    print('Transaction Header Provider Dispose: $hashCode');
    super.dispose();
  }

   Future<dynamic> postOrderAccept(
      Map<dynamic, dynamic> jsonMap
  ) async {
    isLoading = true;

    isConnectedToInternet = await Utils.checkInternetConnectivity();

    _transactionHeader = await _repo!.postOrderAccept(
        jsonMap, isConnectedToInternet, PsStatus.PROGRESS_LOADING);

    return _transactionHeader;
  }
}
