import 'dart:async';
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hardware_buttons/hardware_buttons.dart';
import 'package:volume_watcher/volume_watcher.dart';

class Logic extends ChangeNotifier {
  Animation<double> animation;
  AnimationController animationController;
  AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();
  ScrollController scrollController = ScrollController();
  bool isFirstTime = true;
  bool showVolumeSlider = false;
  double sliderValue = 0;
  int currentVolume;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  List<bool> shouldRebuildTile;
  Timer timer;
  int timerValue = 0;
  int count = 0;
  List<String> assets = [
    '1 (1).mp3',
    '1 (2).mp3',
    '1 (3).mp3',
    '1 (4).mp3',
    '1 (5).mp3',
    '1 (6).mp3',
    '1 (7).mp3',
    '1 (8).mp3',
    '1 (9).mp3',
  ];
  Future<void> initAds() async {
    await FirebaseAdMob.instance
        .initialize(appId: 'ca-app-pub-4229060137718895~5541081383');
    bannerAd = createBannerAd();
    await bannerAd.load();
    interstitialAd = createInterstitialAd();

    await interstitialAd.load();
  }

  InterstitialAd interstitialAd;

  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
      adUnitId: "ca-app-pub-4229060137718895/1376467484",
      listener: (MobileAdEvent event) {
        if (event == MobileAdEvent.failedToLoad) {
          interstitialAd?.dispose();
          interstitialAd = createInterstitialAd();
          interstitialAd.load();
        }
        if (event == MobileAdEvent.loaded) {
          interstitialAd.show();
        }

        print(event);
      },
    );
  }

  BannerAd bannerAd;

  BannerAd createBannerAd() {
    return BannerAd(
        adUnitId: 'ca-app-pub-4229060137718895/2531774660',
        size: AdSize.banner,
        listener: (MobileAdEvent event) async {
          if (event == MobileAdEvent.loaded) {
            bannerAd.show();
          }
          if (event == MobileAdEvent.failedToLoad) {
            await bannerAd?.dispose();
            bannerAd = createBannerAd();
            bannerAd.load();
          }
        });
  }

  bool rebuildListTile = false;
  Logic(TickerProvider tickerProvider) {
    animationController = AnimationController(
        vsync: tickerProvider, duration: Duration(milliseconds: 200));
    animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(animationController);

    volumeButtonEvents.listen((VolumeButtonEvent event) async {
      var currentVolume = await VolumeWatcher.getCurrentVolume;
      this.currentVolume = currentVolume;
      notifyListeners();
    });
    initAds();
    assetsAudioPlayer.playlistAudioFinished.listen((x) {
      print('hello i am finished');
      print(assetsAudioPlayer.playlist.currentIndex);
      print(assets.length);
      if (assetsAudioPlayer.playlist.currentIndex == assets.length) {
        assetsAudioPlayer.playlistPlayAtIndex(0);
      }
      rebuildListTile = !rebuildListTile;

      notifyListeners();
    });

    for (int i = 0; i < assets.length; i++) {
      assets[i] = 'assets/${assets[i]}';
    }
    shouldRebuildTile = List.filled(assets.length, false);
    assetsAudioPlayer.openPlaylist(Playlist(assetAudioPaths: assets));
    assetsAudioPlayer.stop();
  }

  Future<void> onTapListTile(int index) async {

    count++ ;
    if(count%10==0){
      interstitialAd?.dispose();
      interstitialAd = createInterstitialAd();
      interstitialAd.load();
    }
    if (this.isFirstTime) {
      isFirstTime = false;
    }
    if (this.animation.isDismissed) {
      await this.animationController.forward();
    }
    assetsAudioPlayer.playlistPlayAtIndex(index);

    if (!showVolumeSlider) showVolumeSlider = true;
    this.rebuildListTile = !rebuildListTile;
    notifyListeners();
  }

  String durationToString(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes =
        twoDigits(duration.inMinutes.remainder(Duration.minutesPerHour));
    String twoDigitSeconds =
        twoDigits(duration.inSeconds.remainder(Duration.secondsPerMinute));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  double get soundDuration =>
      assetsAudioPlayer.current.value?.duration?.inSeconds?.toDouble();
  double soundProgress(Duration currentPosition) =>
      currentPosition.inSeconds.toDouble() > this.soundDuration
          ? this.soundDuration
          : currentPosition.inSeconds.toDouble();
  Color tileColor(int index) {
    return assetsAudioPlayer.playlist.currentIndex == index
        ? Colors.blue
        : Colors.black;
  }

  void onChangeSlider(double x) {
    assetsAudioPlayer.seek(Duration(seconds: x.toInt()));
  }

  void onChangeSliderStart(double x) {
    print(x.toString() + 'start');
    if (!isFirstTime) {
      assetsAudioPlayer.pause();
    } else {
      this.isFirstTime = false;
      assetsAudioPlayer.playlistPlayAtIndex(0);

      notifyListeners();
    }
  }

  Future<void> onChangeSliderEnd(double x) async {
    if (this.animation.isDismissed) {
      await this.animationController.forward();
    }
    assetsAudioPlayer.play();
    this.showVolumeSlider = true;
    notifyListeners();
  }

  Future<void> playPreviousAudioInList() async {
    if (this.animation.isDismissed) {
      await this.animationController.forward();
    }

    if (assetsAudioPlayer.playlist.currentIndex == 0) {
      assetsAudioPlayer.playlistPlayAtIndex(assets.length - 1);
    } else {
      assetsAudioPlayer.playlistPrevious();
    }

    this.showVolumeSlider = true;
    this.rebuildListTile = !rebuildListTile;

    notifyListeners();
  }

  Future<void> playNextAudioInList() async {
    if (this.animation.isDismissed) {
      await this.animationController.forward();
    }

    if (assetsAudioPlayer.playlist.currentIndex == assets.length - 1) {
      assetsAudioPlayer.playlistPlayAtIndex(0);
    } else {
      assetsAudioPlayer.playlistNext();
    }

    this.showVolumeSlider = true;
    this.rebuildListTile = !rebuildListTile;
    notifyListeners();
  }

  Future<void> playOrPause() async {
    if (this.animation.isCompleted) {
      await this.animationController.reverse();
    } else {
      await this.animationController.forward();
    }
    if (isFirstTime) {
      isFirstTime = false;
      assetsAudioPlayer.playlistPlayAtIndex(0);
    }
    assetsAudioPlayer.playOrPause();
    showVolumeSlider = !showVolumeSlider;
    notifyListeners();
  }

  void onSelected(int selected) {
    timerValue = selected * 60;
    notifyListeners();
    scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text('App will close after $selected sec')));
    startCountDownTimer();
  }

  void startCountDownTimer() {
    if (timer != null) {
      if (timer.isActive) timer.cancel();
    }

    this.timer = Timer.periodic(
      Duration(seconds: 1),
      (Timer timer) {
        if (timerValue < 1) {
          timer.cancel();
          exit(0);
        } else {
          this.timerValue = this.timerValue - 1;
          notifyListeners();
        }
      },
    );
  }

  void cancelTimer() {
    timer.cancel();
    timerValue = 0;
    notifyListeners();
    scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text('Timer was succeffully canceled')));
  }

  Widget trailling() {
    if (timer == null) {
      return PopupMenuButton<int>(
        color: Colors.white,
        onSelected: onSelected,
        child: Icon(
          Icons.snooze,
          color: Colors.white,
        ),
        itemBuilder: (BuildContext context) {
          return [
            //  PopupMenuItem(value: 0, child: Text('now')),
            PopupMenuItem(value: 5, child: Text('5 min')), // هنا لخمس دقايق
            PopupMenuItem(value: 10, child: Text('10 min')), //هنا لعشره وهكذا
            PopupMenuItem(value: 15, child: Text('15 min'))
          ];
        },
      );
    } else {
      if (timer.isActive) {
        return IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.white,
            ),
            onPressed: cancelTimer);
      } else {
        return PopupMenuButton<int>(
          color: Colors.white,
          onSelected: onSelected,
          child: Icon(
            Icons.snooze,
            color: Colors.white,
          ),
          itemBuilder: (BuildContext context) {
            return [
              //  PopupMenuItem(value: 0, child: Text('now')),
              PopupMenuItem(value: 5, child: Text('5 min')), // هنا لخمس دقايق
              PopupMenuItem(value: 10, child: Text('10 min')), //هنا لعشره وهكذا
              PopupMenuItem(value: 15, child: Text('15 min'))
            ];
          },
        );
      }
    }
  }
}
