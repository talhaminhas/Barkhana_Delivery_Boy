import 'package:flutter/cupertino.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/common/ps_holder.dart'
    show PsHolder;

class AcceptOrderParameterHolder extends PsHolder<AcceptOrderParameterHolder> {
  AcceptOrderParameterHolder({
    @required this.deliveryBoyId,
    @required this.transactionHeaderId,
    });

  final String? deliveryBoyId;
  final String? transactionHeaderId;

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{};

    map['delivery_boy_id'] = deliveryBoyId;
    map['transaction_header_id'] = transactionHeaderId;

    return map;
  }

  @override
  AcceptOrderParameterHolder fromMap(dynamic dynamicData) {
    return AcceptOrderParameterHolder(
      deliveryBoyId: dynamicData['delivery_boy_id'],
      transactionHeaderId: dynamicData['transaction_header_id'],
    );
  }

  @override
  String getParamKey() {
    String key = '';

    if (deliveryBoyId != '') {
      key += deliveryBoyId!;
    }
    if (transactionHeaderId != '') {
      key += transactionHeaderId!;
    }
    return key;
  }
}
