import 'package:flutter/cupertino.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/common/ps_holder.dart'
    show PsHolder;

class CompletedOrderListHolder extends PsHolder<CompletedOrderListHolder> {
  CompletedOrderListHolder({@required this.deliveryBoyId, @required this.justToday});

  final String? deliveryBoyId;
  final String? justToday;

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{};

    map['delivery_boy_id'] = deliveryBoyId;
    map['just_today'] = justToday;
    return map;
  }

  @override
  CompletedOrderListHolder fromMap(dynamic dynamicData) {
    return CompletedOrderListHolder(
      deliveryBoyId: dynamicData['delivery_boy_id'],
      justToday: dynamicData['just_today']
    );
  }

  @override
  String getParamKey() {
    String key = '';

    if (deliveryBoyId != '') {
      key += deliveryBoyId!;
    }
    return key;
  }
}
