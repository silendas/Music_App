import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlayingSong extends StatefulWidget {
  const PlayingSong({
    super.key,
    required this.songModel,
    required this.audioPlayer,
    required this.index,
    required this.lastestIndex,
  });
  final List<SongModel> songModel;
  final AudioPlayer audioPlayer;
  final RxInt index;
  final int lastestIndex;

  @override
  State<PlayingSong> createState() => _PlayingSongState();
}

class _PlayingSongState extends State<PlayingSong> {
  var playIndex = 0.obs;
  var duration = ''.obs;
  var position = ''.obs;
  var max = 0.0.obs;
  var value = 0.0.obs;
  var source = ''.obs;
  var isPlaying = false.obs;
  var looping = false.obs;

  var listSongs = ConcatenatingAudioSource(
    useLazyPreparation: true,
    shuffleOrder: DefaultShuffleOrder(),
    children: [],
  );

  @override
  void initState() {
    super.initState();
    audioSource(widget.index.value);
    listenToEvent();
    listenToSong();
    listenPosition();
    listenDuration();
    listenToLoop();
  }

  void audioSource(int index) {
    try {
      playIndex.value = index;
      for (var element in widget.songModel) {
        listSongs.add(
          AudioSource.uri(
            Uri.parse(element.uri!),
            tag: MediaItem(
              id: element.id.toString(),
              album: element.album == "<unknown>"
                  ? "No Album Found"
                  : element.album,
              artist: element.artist == "<unknown>"
                  ? "No Artist Found"
                  : element.artist,
              title: element.displayNameWOExt.toString(),
              artUri: Uri.parse(element.id.toString()),
            ),
          ),
        );
      }
      if (widget.lastestIndex == playIndex.value) {
      } else {
        widget.audioPlayer.setAudioSource(
          listSongs,
          initialIndex: playIndex.value,
          initialPosition: Duration.zero,
        );
      }
      widget.audioPlayer.play();
    } catch (e) {
      print(e);
    }
  }

  void listenToEvent() {
    widget.audioPlayer.playerStateStream.listen(
      (event) {
        if (event.playing) {
          isPlaying.value = true;
        } else {
          isPlaying.value = false;
        }
      },
    );
  }

  void listenToLoop() {
    widget.audioPlayer.loopModeStream.listen(
      (event) {
        if (event == LoopMode.all) {
          looping.value = false;
        } else if (event == LoopMode.one) {
          looping.value = true;
        }
      },
    );
  }

  void listenToSong() {
    widget.audioPlayer.currentIndexStream.listen(
      (event) {
        playIndex.value = event!;
      },
    );
  }

  void listenDuration() {
    widget.audioPlayer.durationStream.listen((d) {
      if (d == null) {
      } else {
        duration.value = d.toString().split('.')[0];
        max.value = d.inSeconds.toDouble();
      }
    });
  }

  void listenPosition() {
    widget.audioPlayer.positionStream.listen((p) {
      position.value = p.toString().split('.')[0];
      value.value = p.inSeconds.toDouble();
    });
  }

  void changeDurationtoSeconds(int seconds) {
    Duration duration = Duration(seconds: seconds);
    widget.audioPlayer.seek(duration);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 39, 52, 58),
        elevation: 0,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width * 1,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 39, 52, 58),
              Color.fromARGB(255, 39, 52, 58),
              Color.fromARGB(255, 27, 36, 41),
              Color.fromARGB(255, 24, 32, 36),
            ],
          ),
        ),
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.shade900.withOpacity(0.8),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: const Offset(1, 1)),
                ],
              ),
              child: Center(
                child: Obx(
                  () => QueryArtworkWidget(
                    id: widget.songModel[playIndex.value].id,
                    type: ArtworkType.AUDIO,
                    artworkFit: BoxFit.cover,
                    nullArtworkWidget: const Icon(
                      Icons.music_note,
                      color: Colors.white,
                      size: 90,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Obx(
              () => Center(
                child: Text(
                  widget.songModel[playIndex.value].displayNameWOExt,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Obx(
              () => Center(
                child: Text(
                  widget.songModel[playIndex.value].artist.toString() ==
                          "<unknown>"
                      ? "Unknown Artist"
                      : widget.songModel[playIndex.value].artist.toString(),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      CupertinoIcons.heart,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(0),
                        decoration: looping.value == true
                            ? BoxDecoration(
                                borderRadius: BorderRadius.circular(35),
                                color: Colors.blueGrey.shade400,
                              )
                            : const BoxDecoration(),
                        child: IconButton(
                          icon: const Icon(
                            Icons.loop_outlined,
                            size: 24,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            widget.audioPlayer.setLoopMode(LoopMode.one);
                            looping.value == true;
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(0),
                        decoration: looping.value == false
                            ? BoxDecoration(
                                borderRadius: BorderRadius.circular(35),
                                color: Colors.blueGrey.shade400,
                              )
                            : const BoxDecoration(),
                        child: IconButton(
                          icon: const Icon(
                            CupertinoIcons.shuffle,
                            size: 24,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            widget.audioPlayer.setLoopMode(LoopMode.all);
                            looping.value == false;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Obx(
              () => Container(
                padding: const EdgeInsets.all(0),
                margin: const EdgeInsets.all(0),
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width * 1,
                child: Slider(
                  thumbColor: Colors.blueGrey.shade400,
                  activeColor: Colors.blueGrey.shade400,
                  inactiveColor: Colors.blueGrey.shade900,
                  min: const Duration(microseconds: 0).inSeconds.toDouble(),
                  value: value.value,
                  max: max.value,
                  onChanged: (value) {
                    changeDurationtoSeconds(value.toInt());
                    value = value;
                  },
                ),
              ),
            ),
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    position.value,
                  ),
                  Text(
                    duration.value,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 35,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    if (looping.value == true) {
                      widget.audioPlayer.setLoopMode(LoopMode.all);
                      widget.audioPlayer.seekToPrevious();
                      widget.audioPlayer.setLoopMode(LoopMode.one);
                    } else {
                      widget.audioPlayer.seekToPrevious();
                    }
                  },
                  icon: const Icon(
                    Icons.skip_previous,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.all(5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(35),
                      color: Colors.white,
                    ),
                    child: IconButton(
                      onPressed: () {
                        if (isPlaying.value == true) {
                          widget.audioPlayer.pause();
                        } else {
                          widget.audioPlayer.play();
                        }
                      },
                      icon: Icon(
                        isPlaying.value == true
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.blueGrey.shade900,
                        size: 34,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (looping.value == true) {
                      widget.audioPlayer.setLoopMode(LoopMode.all);
                      widget.audioPlayer.seekToNext();
                      widget.audioPlayer.setLoopMode(LoopMode.one);
                    } else {
                      widget.audioPlayer.seekToNext();
                    }
                  },
                  icon: const Icon(
                    Icons.skip_next,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
