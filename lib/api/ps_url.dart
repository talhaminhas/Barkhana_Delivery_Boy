import 'package:flutterrtdeliveryboyapp/config/ps_config.dart';

class PsUrl {
  PsUrl._();

  ///
  /// APIs Url
  ///
  static const String ps_product_detail_url = 'rest/products/get';

  static const String ps_shipping_method_url =
      'rest/shippings/get/api_key/${PsConfig.ps_api_key}/';

  static const String ps_news_feed_url =
      'rest/feeds/get/api_key/${PsConfig.ps_api_key}/';

  static const String ps_category_url = 'rest/categories/search';

  static const String ps_about_app_url = 'rest/abouts/get';

  static const String ps_contact_us_url =
      'rest/contacts/add/api_key/${PsConfig.ps_api_key}';

  static const String ps_transaction_status_list_url =
      'rest/transaction_status/get/api_key/${PsConfig.ps_api_key}';

  static const String ps_payment_status_url =
      'rest/payment_status/update_payment_status/api_key/${PsConfig.ps_api_key}';

  static const String ps_update_trans_status_url =
      'rest/delivery_status/update_delivery_status/api_key/${PsConfig.ps_api_key}';

  static const String ps_completed_order_url =
      'rest/delivery_status/completed_order/api_key/${PsConfig.ps_api_key}';

  static const String ps_pending_order_url =
      'rest/delivery_status/pending_order/api_key/${PsConfig.ps_api_key}';

  static const String ps_api_request_token_post_url =
      'rest/TokenFunc/token/api_key/${PsConfig.ps_api_key}';

  static const String ps_api_update_token_post_url =
      'rest/TokenFunc/refresh_token/api_key/${PsConfig.ps_api_key}';

  static const String ps_accept_order_for_delivery_boy_url =
      'rest/transactionheaders/accept_order';
  
  static const String ps_accept_order_url = 
      'rest/transactionheaders/accept_order_from_deliboy';

  static const String ps_image_upload_url =
      'rest/images/upload/api_key/${PsConfig.ps_api_key}';

  static const String ps_collection_url = 'rest/collections/get';

  static const String ps_all_collection_url =
      'rest/products/all_collection_products';

  static const String ps_post_ps_app_info_url =
      'rest/appinfo/get_delete_history/api_key/${PsConfig.ps_api_key}';

  static const String ps_post_ps_user_register_url =
      'rest/users/add/api_key/${PsConfig.ps_api_key}/';

  static const String ps_post_ps_user_email_verify_url =
      'rest/users/verify/api_key/${PsConfig.ps_api_key}/';

  static const String ps_post_ps_zone_shipping_method_url =
      'rest/shipping_zones/get_shipping_cost/api_key/${PsConfig.ps_api_key}/';

  static const String ps_post_ps_user_login_url =
      'rest/users/login/api_key/${PsConfig.ps_api_key}/';

  static const String ps_post_ps_user_forgot_password_url =
      'rest/users/reset/api_key/${PsConfig.ps_api_key}/';

  static const String ps_post_ps_user_change_password_url =
      'rest/users/password_update/api_key/${PsConfig.ps_api_key}/';

  static const String ps_post_ps_user_update_profile_url =
      'rest/users/profile_update/api_key/${PsConfig.ps_api_key}';

  static const String ps_post_ps_phone_login_url =
      'rest/users/phone_register/api_key/${PsConfig.ps_api_key}';

  static const String ps_post_ps_fb_login_url =
      'rest/users/facebook_register/api_key/${PsConfig.ps_api_key}';

  static const String ps_post_ps_google_login_url =
      'rest/users/google_register/api_key/${PsConfig.ps_api_key}';

  static const String ps_post_ps_apple_login_url =
      'rest/users/apple_register/api_key/${PsConfig.ps_api_key}';

  static const String ps_post_ps_resend_code_url =
      'rest/users/request_code/api_key/${PsConfig.ps_api_key}/';

  static const String ps_post_ps_touch_count_url =
      'rest/touches/add_touch/api_key/${PsConfig.ps_api_key}';

  static const String ps_product_url = 'rest/products/search';

  static const String ps_shop_url = 'rest/shops/search';

  static const String ps_about_us_url = 'rest/abouts/get';

  static const String ps_shop_category_url = 'rest/categories/get';

  static const String ps_shop_tag_url = 'rest/tags/get';

  static const String ps_get_shop_by_tagid_url = 'rest/shops/get_shop_tag_id';

  static const String ps_products_search_url =
      'rest/products/search/api_key/${PsConfig.ps_api_key}/';

  static const String ps_subCategory_url = 'rest/subcategories/get';

  static const String ps_user_url = 'rest/users/get';

  static const String ps_noti_url = 'rest/notis/all_notis';

  static const String ps_shop_info_url = 'rest/shops/get_shop_info';

  static const String ps_shop_info_byId_url = 'rest/shops/get';

  static const String ps_bloglist_url = 'rest/feeds/get';

  static const String ps_transactionList_url = 'rest/transactionheaders/get';

  static const String ps_transactionDetail_url = 'rest/transactiondetails/get';

  static const String ps_shipping_country_url =
      'rest/shipping_zones/get_shipping_country';

  static const String ps_shipping_city_url =
      'rest/shipping_zones/get_shipping_city';

  static const String ps_relatedProduct_url =
      'rest/products/related_product_trending';

  static const String ps_commentList_url = 'rest/commentheaders/get';

  static const String ps_commentDetail_url = 'rest/commentdetails/get';

  static const String ps_commentHeaderPost_url =
      'rest/commentheaders/press/api_key/${PsConfig.ps_api_key}';

  static const String ps_commentDetailPost_url =
      'rest/commentdetails/press/api_key/${PsConfig.ps_api_key}';

  static const String ps_downloadProductPost_url =
      'rest/downloads/download_product/api_key/${PsConfig.ps_api_key}';

  static const String ps_noti_register_url =
      'rest/notis/register/api_key/${PsConfig.ps_api_key}';

  static const String ps_noti_post_url =
      'rest/notis/is_read/api_key/${PsConfig.ps_api_key}';

  static const String ps_noti_unregister_url =
      'rest/notis/unregister/api_key/${PsConfig.ps_api_key}';

  static const String ps_ratingPost_url =
      'rest/rates/add_rating/api_key/${PsConfig.ps_api_key}';

  static const String ps_ratingList_url = 'rest/rates/get';

  static const String ps_favouritePost_url =
      'rest/favourites/press/api_key/${PsConfig.ps_api_key}';

  static const String ps_favouriteList_url = 'rest/products/get_favourite';

  static const String ps_gallery_url = 'rest/images/get';

  static const String ps_couponDiscount_url =
      'rest/coupons/check/api_key/${PsConfig.ps_api_key}';

  static const String ps_token_url = 'rest/paypal/get_token';

  static const String ps_transaction_submit_url =
      'rest/transactionheaders/submit/api_key/${PsConfig.ps_api_key}';

  static const String ps_collection_product_url =
      'rest/products/all_collection_products';
  
  static const String ps_delete_user_url =
      'rest/users/deliboy_delete/api_key/${PsConfig.ps_api_key}';
  static const String ps_update_location_url =
      'rest/users/deliboy_location_update/api_key/${PsConfig.ps_api_key}';
}
