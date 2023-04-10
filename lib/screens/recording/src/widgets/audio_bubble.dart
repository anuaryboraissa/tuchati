// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'package:tuchati/constants/app_colors.dart';

import '../globals.dart';

class AudioBubble extends StatefulWidget {
  const AudioBubble({
    Key? key,
    required this.filepath,
    required this.sent,
  }) : super(key: key);

  final String filepath;
  final bool sent;

  @override
  State<AudioBubble> createState() => _AudioBubbleState();
}

class _AudioBubbleState extends State<AudioBubble> {
  final player = AudioPlayer();
  Duration? duration;

  @override
  void initState() {
    super.initState();
    player.setFilePath(widget.filepath).then((value) {
      setState(() {
        duration = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:widget.sent? Alignment.topRight: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4,horizontal: 4),
        child: Row(
          mainAxisAlignment:widget.sent? MainAxisAlignment.end:MainAxisAlignment.start,
          children: [
            SizedBox(width: MediaQuery.of(context).size.width * 0.4),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(right:10),
                height: 45,
                padding: const EdgeInsets.only(left: 12, right: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Globals.borderRadius - 10),
                  color: AppColors.appColor,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // const SizedBox(height: 4),
                    Row(
                      children: [
                        StreamBuilder<PlayerState>(
                          stream: player.playerStateStream,
                          builder: (context, snapshot) {
                            final playerState = snapshot.data;
                            final processingState = playerState?.processingState;
                            final playing = playerState?.playing;
                            if (processingState == ProcessingState.loading ||
                                processingState == ProcessingState.buffering) {
                              return GestureDetector(
                                onTap: player.play,
                                child: const Icon(Icons.play_arrow,color: Colors.white,),
                              );
                            } else if (playing != true) {
                              return GestureDetector(
                                onTap: player.play,
                                child: const Icon(Icons.play_arrow,color: Colors.white,),
                              );
                            } else if (processingState !=
                                ProcessingState.completed) {
                              return GestureDetector(
                                onTap: player.pause,
                                child:  const Icon(Icons.pause,color: Colors.white,),
                              );
                            } else {
                              return GestureDetector(
                                child: const Icon(Icons.replay,color: Colors.white,),
                                onTap: () {
                                  player.seek(Duration.zero);
                                },
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: StreamBuilder<Duration>(
                            stream: player.positionStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Column(
                                  children: [
                                    const SizedBox(height: 4),
                                    LinearProgressIndicator(
                                      color: Colors.white,
                                      value: snapshot.data!.inMilliseconds /
                                          (duration?.inMilliseconds ?? 1),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          prettyDuration(
                                              snapshot.data! == Duration.zero
                                                  ? duration ?? Duration.zero
                                                  : snapshot.data!),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        const Text(
                                          "M4A",
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              } else {
                                return const LinearProgressIndicator(color: Colors.white,);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String prettyDuration(Duration d) {
    var min = d.inMinutes < 10 ? "0${d.inMinutes}" : d.inMinutes.toString();
    var sec = d.inSeconds < 10 ? "0${d.inSeconds}" : d.inSeconds.toString();
    return min + ":" + sec;
  }
}
