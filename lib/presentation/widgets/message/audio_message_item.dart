// import 'dart:async';
// import 'dart:io';
//
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_chat_types/flutter_chat_types.dart';
// class AudioMessageItem extends StatefulWidget {
//   final bool isSentByMe;
//   final AudioMessage audioMessage;
//   final double messageWidth;
//   final Function(Message message)onClickRepliedMsg;
//
//   final Function (AudioMessage message) onUpdateAudio;
//
//   const AudioMessageItem(
//       {super.key,
//       required this.isSentByMe,
//       required this.audioMessage,
//       required this.messageWidth, required this.onClickRepliedMsg, required this.onUpdateAudio});
//
//   @override
//   State<AudioMessageItem> createState() => _AudioMessageItemState();
// }
//
// class _AudioMessageItemState extends State<AudioMessageItem> {
//   // bool downloading = false;
//   // bool downloaded = false;
//   File? audioFile;
//   bool isPlaying=false;
//   final manager = audioManager;
//
//
//   late double waveWidgetWidth;
//   late int noOfSamples;
//
//
//
//   Duration? audioDuration;
//   Duration? progressDuration;
//
//   @override
//   void initState() {
//     // chekFile();
//     super.initState();
//     streamSubscription();
//
//   }
//
//
//   void initial() async {
//
//   }
//
//   void streamSubscription(){
//
//     manager.onStateChanged.observe(widget.audioMessage.id, (state) {
//       setState(() {
//         isPlaying=state==AudioState.play;
//       });
//     });
//     manager.onPositionChanged.observe(widget.audioMessage.id, (state) {
//       setState(() {
//         progressDuration=state;
//       });
//     });
//
//   }
//
//   // void chekFile() async{
//   //   String? path;
//   //   if(widget.audioMessage.metadata?[MsgMetadata.audioFile.name]!=null) {
//   //
//   //     path = widget.audioMessage.metadata?[MsgMetadata.audioFile.name];
//   //     Logger().d("OOO=> chekFile metadata: $path");
//   //   }else{
//   //     var audioFile = await DefaultCacheManager().getFileFromCache(widget.audioMessage.uri)
//   //         .then((cachedFile) => cachedFile?.file);
//   //     path=audioFile?.path;
//   //     Logger().d("OOO=> chekFile DefaultCacheManager: $path");
//   //     if(path!=null){
//   //       widget.onUpdateAudio(
//   //           widget.audioMessage.copyWith(
//   //               metadata: {
//   //                 MsgMetadata.audioFile.name:path
//   //               }
//   //           ) as AudioMessage
//   //       );
//   //     }
//   //   }
//   //
//   //   Logger().d("OOO=> chekFile path: $path");
//   //   if(path!=null) {
//   //     // final player = AudioPlayer();
//   //     // await player.setFilePath(path);
//   //     // final dur = player.duration;
//   //     // // setState(() {
//   //     //   audioDuration = dur;
//   //     //   progressDuration = dur;
//   //       downloaded = true;
//   //       downloading = false;
//   //     // });
//   //   }
//   //
//   // }
//
//   // Future<void> downloadAndPrepareAudio() async {
//   //   setState(() {
//   //     downloading = true;
//   //   });
//   //
//   //   try {
//   //     final file = await DefaultCacheManager().getSingleFile(widget.audioMessage.uri);
//   //     audioFile = file;
//   //
//   //     await AudioPlayer().setFilePath(file.path);
//   //
//   //     final player = AudioPlayer();
//   //     await player.setFilePath(file.path);
//   //     final dur = player.duration;
//   //     widget.onUpdateAudio(
//   //         widget.audioMessage.copyWith(
//   //             metadata: {
//   //               MsgMetadata.audioFile.name:file.path
//   //             }
//   //         ) as AudioMessage
//   //     );
//   //
//   //     // var index=widget.audioMessages.indexOf(widget.audioMessage);
//   //     // if(index!=-1){
//   //     //   widget.audioMessages[index]=widget.audioMessage.copyWith(
//   //     //       metadata: {
//   //     //         "file":file.path
//   //     //       }
//   //     //   ) as AudioMessage;
//   //     // }
//   //
//   //     setState(() {
//   //       downloaded = true;
//   //       downloading = false;
//   //       audioDuration = dur;
//   //       progressDuration = dur;
//   //     });
//   //   } catch (e) {
//   //     Logger().d("GGG=> downloadAndPrepareAudio error: $e");
//   //     setState(() {
//   //       downloading = false;
//   //     });
//   //   }
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     // final playerWaveStyle = PlayerWaveStyle(
//     //     fixedWaveColor: widget.isSentByMe?Colors.white54:context.primaryLight.withValues(alpha: 0.54),
//     //     liveWaveColor: widget.isSentByMe?Colors.white:context.primaryLight,
//     //     waveThickness: 3,
//     //     spacing: 4
//     // );
//     return VoiceMessageView(
//       backgroundColor: widget.isSentByMe?context.borderStroke:context.primaryLight,
//       activeSliderColor: widget.isSentByMe?context.primaryLight:Colors.white,
//       circlesColor: widget.isSentByMe?context.primaryLight:Colors.white,
//       refreshIcon:  Icon(
//         Icons.refresh,
//         color: widget.isSentByMe?Colors.white:context.primaryLight
//       ),
//       pauseIcon:  Icon(
//         Icons.pause_rounded,
//           color: widget.isSentByMe?Colors.white:context.primaryLight
//       ),
//       playIcon:  Icon(
//         Icons.play_arrow_rounded,
//           color: widget.isSentByMe?Colors.white:context.primaryLight
//       ),
//       stopDownloadingIcon:  Icon(
//         Icons.close,
//           color: widget.isSentByMe?Colors.white:context.primaryLight
//       ),
//       circlesTextStyle:  TextStyle(
//         color: widget.isSentByMe?Colors.white:context.primaryLight,
//         fontSize: 10,
//         fontWeight: FontWeight.bold,
//       ),
//       counterTextStyle:  TextStyle(
//         color: widget.isSentByMe?context.primaryLight:Colors.white,
//         fontSize: 11,
//         fontWeight: FontWeight.w500,
//       ),
//       controller: VoiceController(
//         audioSrc: widget.audioMessage.uri,
//         cacheKey: widget.audioMessage.id,
//         onComplete: () {
//           /// do something on complete
//         },
//         onPause: () {
//           /// do something on pause
//         },
//         onPlaying: () {
//           /// do something on playing
//         },
//         onError: (err) {
//           /// do somethin on error
//         },
//         maxDuration: const Duration(seconds: 30),
//         isFile: false,
//       ),
//       innerPadding: 12,
//       cornerRadius: 20,
//     );
//   }
//   @override
//   void dispose() {
//     // manager.onPositionChanged.deactivate(widget.audioMessage.id);
//     // manager.onStateChanged.deactivate(widget.audioMessage.id);
//
//     super.dispose();
//   }
//
//
//   // String _format(Duration d) {
//   //   final m = d.inMinutes;
//   //   final s = d.inSeconds % 60;
//   //   return '$m:${s.toString().padLeft(2, '0')}';
//   // }
//   // Future<Duration?> getAudioDuration(String url) async {
//   //   final player = AudioPlayer();
//   //   try {
//   //     // Загружаем только метаданные
//   //     await player.setUrl(url, preload: false);
//   //     final duration = player.duration;
//   //     await player.dispose();
//   //     return duration;
//   //   } catch (e) {
//   //     await player.dispose();
//   //     return null;
//   //   }
//   // }
//   //
// }
