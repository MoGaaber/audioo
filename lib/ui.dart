import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:provider/provider.dart';
import 'package:volume_watcher/volume_watcher.dart';
import 'dart:math' as math;

import 'logic.dart';

class Ui extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Logic logic = Provider.of(context, listen: false);
    return SafeArea(
      child: Scaffold(
        key: logic.scaffoldKey,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: Material(
            color: Colors.black,
            child: Selector<Logic, int>(
              selector: (BuildContext, Logic logic) => logic.timerValue,
              builder: (BuildContext context, int value, Widget child) {
                return ListTile(
                  leading: logic.timerValue == 0
                      ? SizedBox.shrink()
                      : Text(
                          logic.timerValue.toString(),
                          style: TextStyle(color: Colors.white),
                        ),
                  trailing: logic.trailling(),
                );
              },
            ),
          ),
        ),
        body: Column(
          children: <Widget>[
            Expanded(flex: 5,
              child: ListView.separated(
                controller: logic.scrollController,
                itemCount: logic.assets.length,
                itemBuilder: (BuildContext context, int index) {
                  var asset = logic.assets[index];
                  return Selector<Logic, bool>(
                    builder: (BuildContext context, bool value,
                            Widget child) =>
                        Material(
                          color: Colors.amber,
                          child: ListTile(
                      onTap: () {
                          logic.onTapListTile(index);
                      },
                      title: Text(
                          asset.substring(asset.indexOf('/') + 1,
                              asset.lastIndexOf('.')),
                          style: TextStyle(
                              color: value ? Colors.blue : Colors.black,
                              fontSize: 22),
                          textAlign: TextAlign.right,
                      ),
                    ),
                        ),
                    selector: (BuildContext, Logic logic) =>
                        logic.assetsAudioPlayer.playlist.currentIndex ==
                        index,
                  );
                }, separatorBuilder: (BuildContext context, int index) =>Padding(padding: EdgeInsets.symmetric(vertical: 10)),
              ),
            ),
            Expanded(
              flex: 2,
              child: Stack(overflow: Overflow.visible,
                children: <Widget>[
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      StreamProvider<Duration>(
                        initialData: Duration(seconds: 0),
                        child: ProgressSlider(),
                        create: (BuildContext context) =>
                            logic.assetsAudioPlayer.currentPosition,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.skip_previous,
                            ),
                            onPressed: logic.playPreviousAudioInList,
                          ),
                          InkWell(
                            onTap: logic.playOrPause,
                            child: AnimatedIcon(
                              icon: AnimatedIcons.play_pause,
                              progress: logic.animation,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.skip_next),
                            onPressed: logic.playNextAudioInList,
                          )
                        ],
                      ),
                    ],
                  ),
                  Positioned(left: 4,
                    bottom: 50,
                    child: Selector<Logic, bool>(
                      selector: (BuildContext, Logic logic) =>
                      logic.showVolumeSlider,
                      builder: (BuildContext context, bool isPlaying,
                          Widget child) =>
                      isPlaying
                          ? Center(
                        child: SizedBox(
                          height: 150,
                          child: FutureProvider<List<num>>(
                            child: VolumeSlider(),
                            create: (BuildContext context) =>
                                Future.wait([
                                  VolumeWatcher.getMaxVolume,
                                  VolumeWatcher.getCurrentVolume
                                ]),
                          ),
                        ),
                      )
                          : SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class VolumeSlider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    var volumeProperties = Provider.of<List<num>>(context);
    return volumeProperties == null
        ? SizedBox.shrink()
        : Selector<Logic, int>(
            builder: (BuildContext context, int value, Widget child) =>
                FlutterSlider(
              rtl: true,
              min: 0,
              max: volumeProperties[0].toDouble(),
              onDragging: (x, y, z) {
                VolumeWatcher.setVolume(y);
              },
              axis: Axis.vertical,
              values: <double>[
                value == null
                    ? volumeProperties[1].toDouble()
                    : value.toDouble()
              ],
            ),
            selector: (BuildContext, Logic logic) => logic.currentVolume,
          );
  }
}

class ProgressSlider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Logic logic = Provider.of<Logic>(context, listen: false);
    Duration currentPosition = Provider.of<Duration>(context, listen: true);
    print(currentPosition.toString());
    return Builder(
      builder: (BuildContext context) => currentPosition == null ||
              logic.assetsAudioPlayer.current.value == null
          ? Column(
              children: <Widget>[
                FractionallySizedBox(
      widthFactor: 0.8 ,
                  child: Slider(
                    value: 0,
                    onChanged: (x) {},
                  ),
                ),
                Align(
                  child: Text('00:00 - 00:00'),
                  alignment: Alignment(0.8, 0),
                )
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FractionallySizedBox(widthFactor: 0.8,
                  child: Slider(
                      min: 0,
                      max: logic
                          .assetsAudioPlayer.current.value.duration.inSeconds
                          .toDouble(),
                      value: logic.soundProgress(currentPosition),
                      onChangeStart: (x) {
                        logic.onChangeSliderStart(x);
                      },
                      onChangeEnd: (x) {
                        logic.onChangeSliderEnd(x);
                      },
                      onChanged: logic.onChangeSlider),
                ),
                Align(
                  child: Selector<Logic, Duration>(
                    builder: (BuildContext context, Duration soundDuration,
                            Widget child) =>
                        Text(
                            '${logic.soundDuration < currentPosition.inSeconds ? logic.durationToString(soundDuration) : logic.durationToString(currentPosition)} - ${logic.durationToString(soundDuration)}'),
                    selector: (BuildContext, Logic logic) =>
                        logic.assetsAudioPlayer.current.value.duration,
                  ),
                  alignment: Alignment(0.8, 0),
                )
              ],
            ),
    );
  }
}
