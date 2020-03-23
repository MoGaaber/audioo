import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:provider/provider.dart';
import 'package:volume_watcher/volume_watcher.dart';

import 'logic.dart';

class Ui extends StatelessWidget {
  var volume = 0.0;
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
                  trailing: Builder(
                    builder: (BuildContext ctx) => PopupMenuButton<int>(
                      color: Colors.white,
                      onSelected: logic.onSelected,
                      child: Icon(
                        Icons.snooze,
                        color: Colors.white,
                      ),
                      itemBuilder: (BuildContext context) {
                        return [
                          //  PopupMenuItem(value: 0, child: Text('now')),
                          PopupMenuItem(
                              value: 5, child: Text('5 min')), // هنا لخمس دقايق
                          PopupMenuItem(
                              value: 10,
                              child: Text('10 min')), //هنا لعشره وهكذا
                          PopupMenuItem(value: 15, child: Text('15 min'))
                        ];
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 6,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 8,
                    child: ListView.builder(
                      controller: logic.scrollController,
                      itemCount: logic.assets.length,
                      itemBuilder: (BuildContext context, int index) =>
                          Selector<Logic, bool>(
                        builder:
                            (BuildContext context, bool value, Widget child) =>
                                ListTile(
                          onTap: () {
                            logic.onTapListTile(index);
                          },
                          title: Text(
                            logic.assets[index],
                            style: TextStyle(color: logic.tileColor(index)),
                          ),
                        ),
                        selector: (BuildContext, Logic logic) =>
                            logic.rebuildListTile,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Selector<Logic, bool>(
                      selector: (BuildContext, Logic logic) => logic.isPlaying,
                      builder: (BuildContext context, bool isPlaying,
                              Widget child) =>
                          isPlaying
                              ? Center(
                                  child: SizedBox(
                                    height: 300,
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
                  )
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
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
    return Builder(
      builder: (BuildContext context) => currentPosition == null ||
              logic.assetsAudioPlayer.current.value == null
          ? Column(
              children: <Widget>[
                Slider(
                  value: 0,
                  onChanged: (x) {},
                ),
                Align(
                  child: Text('00:00'),
                  alignment: Alignment(0.8, 0),
                )
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Slider(
                    min: 0,
                    max: logic
                        .assetsAudioPlayer.current.value.duration.inSeconds
                        .toDouble(),
                    value: currentPosition?.inSeconds?.toDouble(),
                    onChangeStart: (x) {
                      logic.onChangeSliderStart();
                    },
                    onChangeEnd: (x) {
                      logic.onChangeSliderEnd();
                    },
                    onChanged: logic.onChangeSlider),
                Align(
                  child: Selector<Logic, Duration>(
                    builder: (BuildContext context, Duration soundDuration,
                            Widget child) =>
                        Text(
                            '${logic.durationToString(currentPosition)} - ${logic.durationToString(soundDuration)}'),
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
