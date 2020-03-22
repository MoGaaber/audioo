import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:hardware_buttons/hardware_buttons.dart';
import 'package:provider/provider.dart';
import 'package:volume_watcher/volume_watcher.dart';

import 'logic.dart';

class Ui extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Logic logic = Provider.of(context);
    volumeButtonEvents.listen((x) {
      print(x);
    });
    return SafeArea(
      child: Scaffold(
        key: logic.scaffoldKey,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: Material(
            color: Colors.black,
            child: ListTile(
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
                          value: 10, child: Text('10 min')), //هنا لعشره وهكذا
                      PopupMenuItem(value: 15, child: Text('15 min'))
                    ];
                  },
                ),
              ),
/*
              title: const Text('القرآن الكريم',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26)),
*/
            ),
          ),
        ),
        body: Column(
          children: <Widget>[
            VolumeWatcher(
              onVolumeChangeListener: (x) {
                print(x);
              },
            ),
            Expanded(
              flex: 4,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 8,
                    child: ListView.builder(
                      controller: logic.scrollController,
                      itemCount: logic.assets.length,
                      itemBuilder: (BuildContext context, int index) =>
                          ListTile(
                        onTap: () {
                          logic.onTapListTile(index);
                        },
                        title: Text(
                          logic.assets[index],
                          style: TextStyle(color: logic.tileColor(index)),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: SizedBox(
                        height: 300,
                        child: FutureBuilder<num>(
                          future: VolumeWatcher.getMaxVolume,
                          builder: (BuildContext context,
                              AsyncSnapshot<num> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return FlutterSlider(
                                min: 0,
                                max: snapshot.data.toDouble(),
                                onDragging: (x, y, z) {
                                  print(y);
                                  VolumeWatcher.setVolume(y);
                                },
                                axis: Axis.vertical,
                                values: <double>[0, 1],
                              );
                            } else {
                              return SizedBox.shrink();
                            }
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  StreamBuilder<Duration>(
                    stream: logic.assetsAudioPlayer.currentPosition,
                    builder: (BuildContext context,
                        AsyncSnapshot<Duration> snapshot) {
                      Duration duration = snapshot.data;
                      if (snapshot.hasData && logic.duration != null) {
                        return Slider(
                            min: 0,
                            max: logic.duration,
                            value: logic.value(duration),
                            onChangeStart: (x) {
                              logic.onChangeSliderStart();
                            },
                            onChangeEnd: (x) {
                              logic.onChangeSliderEnd();
                            },
                            onChanged: logic.onChangeSlider);
                      } else {
                        return SizedBox.shrink();
                      }
                    },
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
