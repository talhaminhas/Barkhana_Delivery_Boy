import 'dart:async';
import 'package:flutterrtdeliveryboyapp/api/common/ps_resource.dart';
import 'package:flutterrtdeliveryboyapp/api/common/ps_status.dart';
import 'package:flutterrtdeliveryboyapp/provider/common/ps_provider.dart';
import 'package:flutterrtdeliveryboyapp/repository/noti_repository.dart';
import 'package:flutterrtdeliveryboyapp/utils/utils.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/common/ps_value_holder.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/noti.dart';

class NotiProvider extends PsProvider {
  NotiProvider(
      {required NotiRepository repo, this.psValueHolder, int limit = 0})
      : super(repo, limit) {
    _repo = repo;
    //isDispose = false;
    print('Notification Provider: $hashCode');

    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;
    });

    notiListStream = StreamController<PsResource<List<Noti>>>.broadcast();
    subscription = notiListStream.stream.listen((dynamic resource) {
      updateOffset(resource.data.length);

      _notiList = resource;

      if (resource.status != PsStatus.BLOCK_LOADING &&
          resource.status != PsStatus.PROGRESS_LOADING) {
        isLoading = false;
      }

      if (!isDispose) {
        notifyListeners();
      }
    });
  }
  NotiRepository? _repo;
  PsValueHolder? psValueHolder;
  String userId = '';
  String? deviceToken;

  PsResource<Noti> _noti = PsResource<Noti>(PsStatus.NOACTION, '', null);
  PsResource<Noti> get user => _noti;

  PsResource<List<Noti>> _notiList =
      PsResource<List<Noti>>(PsStatus.NOACTION, '', <Noti>[]);
  PsResource<List<Noti>> get notiList => _notiList;
 late StreamSubscription<dynamic> subscription;
 late StreamController<PsResource<List<Noti>>> notiListStream;
  @override
  void dispose() {
    //_repo.cate.close();
    subscription.cancel();
    isDispose = true;
    print('Notification Provider Dispose: $hashCode');
    super.dispose();
  }

  Future<dynamic> getNotiList(Map<dynamic, dynamic> paramMap) async {
    isConnectedToInternet = await Utils.checkInternetConnectivity();
    isLoading = true;

    await _repo!.getNotiList(notiListStream, isConnectedToInternet, limit,
        offset, PsStatus.BLOCK_LOADING, paramMap);
  }

  Future<dynamic> nextNotiList(Map<dynamic, dynamic> paramMap) async {
    isConnectedToInternet = await Utils.checkInternetConnectivity();
    if (!isLoading && !isReachMaxData) {
      super.isLoading = true;

      await _repo!.getNextPageNotiList(notiListStream, isConnectedToInternet,
          limit, offset, PsStatus.PROGRESS_LOADING, paramMap);
    }
  }

  Future<void> resetNotiList(Map<dynamic, dynamic> paramMap) async {
    isConnectedToInternet = await Utils.checkInternetConnectivity();
    isLoading = true;

    updateOffset(0);

    await _repo!.getNotiList(notiListStream, isConnectedToInternet, limit,
        offset, PsStatus.BLOCK_LOADING, paramMap);

    isLoading = false;
  }

  Future<dynamic> postNoti(
    Map<dynamic, dynamic> jsonMap,
  ) async {
    isLoading = true;

    isConnectedToInternet = await Utils.checkInternetConnectivity();

    _noti =
        await _repo!.postNoti(notiListStream, jsonMap, isConnectedToInternet);

    return _noti;
  }
}
