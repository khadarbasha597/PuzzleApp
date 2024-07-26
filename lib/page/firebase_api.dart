import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:puzzle/main.dart';

class FirebaseApi{

  final _firebaseMessaging=FirebaseMessaging.instance;

  Future<void>initNotifications() async{
    await _firebaseMessaging.requestPermission();
    final fcmToken=await _firebaseMessaging.getToken();
    print('Token:$fcmToken');
    initPushNotificatoins();
  }
  void handleMessage(RemoteMessage? message){
    if(message == null)return;
    navigatorKey.currentState?.pushNamed(
     '/notification_screen',
      arguments: message,
    );
  }
  Future initPushNotificatoins() async{
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }

}