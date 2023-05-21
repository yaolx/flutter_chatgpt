import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import './route_handler.dart';

class Routes {
  static late final FluroRouter router;

  static String root = "/";
  static String home = "/home";
  static String home1 = "/home1";
  static String deepLink = "/message";

  static void configureRoutes(FluroRouter router) {
    router.notFoundHandler = Handler(
        handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      print("ROUTE WAS NOT FOUND !!!");
      return;
    });
    router.define(root, handler: homeHandler);
    router.define(home, handler: homeHandler);
    router.define(home1,
        handler: demoRouteHandler, transitionType: TransitionType.inFromRight);
    router.define(deepLink, handler: deepLinkHandler);
  }

  // 对参数进行encode，解决参数中有特殊字符，影响fluro路由匹配
  static Future navigateTo(BuildContext context, String path,
      {Map<String, dynamic>? params,
      TransitionType transition = TransitionType.native}) {
    String query = "";
    if (params != null) {
      int index = 0;
      for (var key in params.keys) {
        var value = Uri.encodeComponent(params[key]);
        if (index == 0) {
          query = "?";
        } else {
          query += "&";
        }
        query += "$key=$value";
        index++;
      }
    }
    print('我是navigateTo传递的参数：$query');

    path = path + query;
    return router.navigateTo(context, path, transition: transition);
  }
}
