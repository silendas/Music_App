import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/pages/player_page.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:sticky_headers/sticky_headers.dart';

class HomePage extends StatefulWidget {
  const HomePage(
      {super.key, required this.audioQuery, required this.audioPlayer});

  final OnAudioQuery audioQuery;
  final AudioPlayer audioPlayer;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var playIndex = 0.obs;

  late final Future<List<SongModel>> simFuture;

  void listenToSong() {
    widget.audioPlayer.currentIndexStream.listen(
      (event) {
        if (event == null) {
        } else {
          playIndex.value = event;
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    listenToSong();
    simFuture = widget.audioQuery.querySongs(
      sortType: null,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18.0),
          children: [
            const Text(
              'Hello World !',
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 7,
            ),
            const Text(
              'Enjoy listening to songs on Nulr.',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            StickyHeader(
              header: Container(
                padding: const EdgeInsets.only(left: 15, right: 15),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 39, 52, 58),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  title: const Text('Your playlist'),
                  titleTextStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                  contentPadding: const EdgeInsets.all(0),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.more_horiz_outlined,
                      size: 25,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                ),
              ),
              content: const Center(
                child: SizedBox(
                  height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Coming soon...',
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Thanks for your support.',
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            StickyHeader(
              header: Container(
                padding: const EdgeInsets.only(left: 15, right: 15),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 39, 52, 58),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  title: const Text('Your Music'),
                  titleTextStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                  contentPadding: const EdgeInsets.all(0),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.more_horiz_outlined,
                      size: 25,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                ),
              ),
              content: FutureBuilder<List<SongModel>>(
                future: simFuture,
                builder: (context, item) {
                  if (item.data == null) {
                    return Container(
                      padding: const EdgeInsets.all(18),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(
                              height: 12,
                            ),
                            Text('Loading...')
                          ],
                        ),
                      ),
                    );
                  } else if (item.data!.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(18),
                      child: const Center(
                        child: Text(
                          'No Songs Found..',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: item.data!.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: QueryArtworkWidget(
                            id: item.data![index].id,
                            type: ArtworkType.AUDIO,
                            nullArtworkWidget: const Icon(
                              Icons.music_note,
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            item.data![index].displayNameWOExt,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            item.data![index].artist.toString() == "<unknown>"
                                ? "Unknown Artist"
                                : item.data![index].artist.toString(),
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.more_vert,
                              size: 22,
                              color: Colors.white,
                            ),
                            onPressed: () {},
                          ),
                          onTap: () {
                            Get.to(
                              () => PlayingSong(
                                songModel: item.data!,
                                audioPlayer: widget.audioPlayer,
                                index: index.obs,
                                lastestIndex: playIndex.toInt(),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
