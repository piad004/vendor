import 'dart:convert';

import 'package:vendor/model/user.dart';
import 'package:vendor/service/firebase.service.dart';

import 'app_strings.dart';
import 'local_storage.service.dart';

class AuthServices {

  static Future<User> saveUser(dynamic jsonObject) async {
    final currentUser = User.fromJson(jsonObject);
    try {
      await LocalStorageService.prefs.setString(
        AppStrings.userKey,
        json.encode(
          currentUser.toJson(),
        ),
      );

      //subscribe to firebase topic
      FirebaseService().firebaseMessaging.subscribeToTopic("all");
      FirebaseService().firebaseMessaging.subscribeToTopic("${currentUser.id}");
      FirebaseService()
          .firebaseMessaging
          .subscribeToTopic("${currentUser.role}");

      return currentUser;
    } catch (error) {
      return null;
    }
  }
}
