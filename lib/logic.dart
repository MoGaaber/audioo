import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Logic extends ChangeNotifier {
  Animation<double> animation;
  AnimationController animationController;
  AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();
  ScrollController scrollController = ScrollController();
  List<String> assets = [
    '026.mp3',
    '031.mp3',
    '032.mp3',
    '044.mp3',
    '050.mp3',
    '053.mp3',
    '059.mp3',
    '066.mp3',
    '067.mp3',
    '068.mp3',
    '072.mp3',
    '079.mp3',
    '085.mp3',
    '088.mp3',
  ];

  double sliderValue = 0;

  Logic(TickerProvider tickerProvider) {
    animationController = AnimationController(
        vsync: tickerProvider, duration: Duration(milliseconds: 200));
    animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(animationController);
    assetsAudioPlayer.playlistAudioFinished.listen((x) {
      notifyListeners();
    });

    for (int i = 0; i < assets.length; i++) {
      assets[i] = 'assets/${assets[i]}';
    }
    assetsAudioPlayer.openPlaylist(Playlist(assetAudioPaths: assets));
  }

  void onTapListTile(int index) {
    assetsAudioPlayer.stop();
    assetsAudioPlayer.playlistPlayAtIndex(index);
    notifyListeners();
  }

  double get duration =>
      assetsAudioPlayer.current.value?.duration?.inSeconds?.toDouble();
  double value(Duration duration) =>
      duration.inSeconds.toDouble() > this.duration
          ? this.duration
          : duration.inSeconds.toDouble();
  Color tileColor(int index) {
    return assetsAudioPlayer.playlist.currentIndex == index
        ? Colors.blue
        : Colors.black;
  }

  void onChangeSlider(double x) {
    assetsAudioPlayer.seek(Duration(seconds: x.toInt()));
  }

  void onChangeSliderStart() {
    assetsAudioPlayer.pause();
  }

  void onChangeSliderEnd() {
    assetsAudioPlayer.play();
  }

  void playPreviousAudioInList() {
    if (assetsAudioPlayer.playlist.currentIndex == 0) {
      assetsAudioPlayer.playlistPlayAtIndex(assets.length - 1);
    } else {
      assetsAudioPlayer.playlistPrevious();
    }
    notifyListeners();
  }

  void playNextAudioInList() {
    if (assetsAudioPlayer.playlist.currentIndex == assets.length - 1) {
      assetsAudioPlayer.playlistPlayAtIndex(0);
    } else {
      assetsAudioPlayer.playlistNext();
    }
    notifyListeners();
  }

  void playOrPause() {
    if (this.animation.isCompleted) {
      this.animationController.reverse();
    } else {
      this.animationController.forward();
    }
    assetsAudioPlayer.playOrPause();
  }
}
