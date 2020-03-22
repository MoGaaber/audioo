import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'logic.dart';

class Ui extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Logic logic = Provider.of(context);
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                controller: logic.scrollController,
                itemCount: logic.assets.length,
                itemBuilder: (BuildContext context, int index) => ListTile(
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
            StreamBuilder<Duration>(
              stream: logic.assetsAudioPlayer.currentPosition,
              builder:
                  (BuildContext context, AsyncSnapshot<Duration> snapshot) {
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
              mainAxisAlignment: MainAxisAlignment.center,
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
                    icon: AnimatedIcons.pause_play,
                    progress: logic.animation,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.skip_next),
                  onPressed: logic.playNextAudioInList,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
