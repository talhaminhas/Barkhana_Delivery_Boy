import 'dart:async';
import 'package:flutterrtdeliveryboyapp/api/common/ps_resource.dart';
import 'package:flutterrtdeliveryboyapp/api/common/ps_status.dart';
import 'package:flutterrtdeliveryboyapp/provider/common/ps_provider.dart';
import 'package:flutterrtdeliveryboyapp/repository/shop_repository.dart';
import 'package:flutterrtdeliveryboyapp/utils/utils.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/holder/shop_parameter_holder.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/shop.dart';

class NewShopProvider extends PsProvider {
  NewShopProvider({required ShopRepository repo, int limit = 0})
      : super(repo, limit) {
    _repo = repo;
    print('NewShopProvider : $hashCode');
    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;
    });

    shopListStream = StreamController<PsResource<List<Shop>>>.broadcast();

    subscription =
        shopListStream.stream.listen((PsResource<List<Shop>> resource) {
      updateOffset(resource.data!.length);

      _shopList = resource;

      if (resource.status != PsStatus.BLOCK_LOADING &&
          resource.status != PsStatus.PROGRESS_LOADING) {
        isLoading = false;
      }

      if (!isDispose) {
        notifyListeners();
      }
    });
  }
  ShopRepository? _repo;
  PsResource<List<Shop>> _shopList =
      PsResource<List<Shop>>(PsStatus.NOACTION, '', <Shop>[]);

  PsResource<List<Shop>> get shopList => _shopList;
 late StreamSubscription<PsResource<List<Shop>>> subscription;
 late StreamController<PsResource<List<Shop>>> shopListStream;
  @override
  void dispose() {
    subscription.cancel();
    isDispose = true;
    print('NewShop Provider Dispose: $hashCode');
    super.dispose();
  }

  Future<dynamic> loadShopList() async {
    isLoading = true;

    isConnectedToInternet = await Utils.checkInternetConnectivity();

    await _repo!.getShopList(
        shopListStream,
        isConnectedToInternet,
        limit,
        offset,
        PsStatus.PROGRESS_LOADING,
        ShopParameterHolder().getNewShopParameterHolder());
  }

  Future<dynamic> nextShopList() async {
    isConnectedToInternet = await Utils.checkInternetConnectivity();

    if (!isLoading && !isReachMaxData) {
      super.isLoading = true;

      await _repo!.getShopList(
          shopListStream,
          isConnectedToInternet,
          limit,
          offset,
          PsStatus.PROGRESS_LOADING,
          ShopParameterHolder().getNewShopParameterHolder());
    }
  }
}
