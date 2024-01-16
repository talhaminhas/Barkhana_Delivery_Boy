import 'dart:async';
import 'package:flutterrtdeliveryboyapp/api/common/ps_resource.dart';
import 'package:flutterrtdeliveryboyapp/api/common/ps_status.dart';
import 'package:flutterrtdeliveryboyapp/provider/common/ps_provider.dart';
import 'package:flutterrtdeliveryboyapp/repository/transaction_header_repository.dart';
import 'package:flutterrtdeliveryboyapp/utils/utils.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/transaction_header.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/transaction_parameter_holder.dart';


class NearestOrderProvider extends PsProvider {
  NearestOrderProvider(
      {required TransactionHeaderRepository repo, int limit = 0})
      : super(repo, limit) {
    _repo = repo;

    print('Accept order Provider: $hashCode');

    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;
    });

    transactionListStream =
        StreamController<PsResource<List<TransactionHeader>>>.broadcast();
    subscription = transactionListStream.stream
        .listen((PsResource<List<TransactionHeader>> resource) {
      updateOffset(resource.data!.length);

      _transactionList = resource;

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

  PsResource<List<TransactionHeader>> _transactionList =
      PsResource<List<TransactionHeader>>(
          PsStatus.NOACTION, '', <TransactionHeader>[]);
  PsResource<List<TransactionHeader>> get nearestTransactionList =>
      _transactionList;

 late StreamSubscription<PsResource<List<TransactionHeader>>> subscription;
 late StreamController<PsResource<List<TransactionHeader>>> transactionListStream;
  @override
  void dispose() {
    subscription.cancel();
    isDispose = true;
    print('Transaction Header Provider Dispose: $hashCode');
    super.dispose();
  }

  Future<dynamic> loadNearestOrderList(
      String loginUserId, TransactionParameterHolder holder) async {
    isLoading = true;

    isConnectedToInternet = await Utils.checkInternetConnectivity();
    await _repo!.getAllNearestOrderList(
        transactionListStream,
        isConnectedToInternet,
        loginUserId,
        limit,
        offset,
        PsStatus.PROGRESS_LOADING,
        holder
        );
  }

  Future<dynamic> nextNearestOrderList(
      String loginUserId, TransactionParameterHolder holder) async {
    isConnectedToInternet = await Utils.checkInternetConnectivity();

    if (!isLoading && !isReachMaxData) {
      super.isLoading = true;
      await _repo!.getAllNearestOrderList(
          transactionListStream,
          isConnectedToInternet,
          loginUserId,
          limit,
          offset,
          PsStatus.PROGRESS_LOADING,
          holder
          );
    }
  }

  Future<void> resetNearesOrderList(
      String loginUserId, TransactionParameterHolder holder) async {
    isConnectedToInternet = await Utils.checkInternetConnectivity();
    isLoading = true;

    updateOffset(0);

    await _repo!.getAllNearestOrderList(
        transactionListStream,
        isConnectedToInternet,
        loginUserId,
        limit,
        offset,
        PsStatus.PROGRESS_LOADING,
        holder
        );

    isLoading = false;
  }
}
