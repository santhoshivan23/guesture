import 'dart:io';


class AdMobService {
  String getAdMobAppId() {
    if(Platform.isAndroid) {
      return 'ca-app-pub-2926499666072016~3530970451';
    }
    return null;
  }

  String getBannerAdId() {
    if(Platform.isAndroid) {
      return 'ca-app-pub-2926499666072016/9686934204';
    }
    return null;
  }

  String getInterstitialAdId() {
    if(Platform.isAndroid) {
      return 'ca-app-pub-2926499666072016/2295243939';
    }
    return null;
  }
 
  

  
}