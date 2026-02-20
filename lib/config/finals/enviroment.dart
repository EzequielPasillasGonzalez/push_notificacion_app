import 'package:flutter_dotenv/flutter_dotenv.dart';

class Enviroment {
  static final String apikeyAndroid =
      dotenv.env["APIKEY_ANDROID"] ??
      (throw AssertionError('APIKEY_ANDROID not found'));
  static final String apiidAndroid =
      dotenv.env["APIID_ANDROID"] ??
      (throw AssertionError('APIID_ANDROID not found'));
  static final String messagindSenderId =
      dotenv.env["MESSAGING_SENDER_ID"] ??
      (throw AssertionError('MESSAGING_SENDER_ID not found'));
  static final String projectId =
      dotenv.env["PROJECT_ID"] ??
      (throw AssertionError('PROJECT_ID not found'));
  static final String storageBucket =
      dotenv.env["STORAGE_BUCKET"] ??
      (throw AssertionError('STORAGE_BUCKET not found'));
  static final String apikeyIos =
      dotenv.env["APIKEY_IOS"] ??
      (throw AssertionError('APIKEY_IOS not found'));
  static final String apiidIos =
      dotenv.env["APIID_IOS"] ?? (throw AssertionError('APIID_IOS not found'));
  static final String iosBundleId =
      dotenv.env["IOS_BUNDLE_ID"] ??
      (throw AssertionError('IOS_BUNDLE_ID not found'));
}
