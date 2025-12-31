// import 'package:b2b/core/enum/msg_metadatas.dart';
// import 'package:b2b/core/extensions/text_extensions.dart';
// import 'package:b2b/presentation/support/extensions/color_extension.dart';
// import 'package:b2b/presentation/widgets/card/custom_card.dart';
// import 'package:b2b/presentation/widgets/image/rounded_cached_network_image_widget.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_chat_types/flutter_chat_types.dart';
// import 'package:logger/logger.dart';
//
// class RepledMessage extends StatelessWidget{
//   final Message message;
//   final double messageWidth;
//   final Function(Message message) onClickRepliedMsg;
//
//   const RepledMessage({super.key, required this.message, required this.messageWidth, required this.onClickRepliedMsg});
//   @override
//   Widget build(BuildContext context) {
//     Logger().d("FFF=> ${message.type.name}");
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(4),
//         onTap: (){
//           onClickRepliedMsg(message);
//         },
//         child: CustomCard(
//           borderRadius: BorderRadius.circular(4),
//           color: Colors.white.withValues(alpha: 0.2),
//           child: Row(
//               children: [
//                 CustomCard(
//                   borderRadius: BorderRadius.only(topLeft: Radius.circular(4),bottomLeft: Radius.circular(4)),
//                   height: 48,
//                   width: 4,
//                   color: context.mainBg,
//                 ),
//                 SizedBox(
//                   width: 4,
//                 ),
//                 if(message.metadata?[MsgMetadata.attachedUrl.name]!=null||message.metadata?[MsgMetadata.attachedFile.name]!=null)
//                   RoundedCachedNetworkImage(
//                     height: 36,
//                     width: 36,
//                     borderRadius: BorderRadius.circular(4),
//                     imageUrl: (message.metadata?[MsgMetadata.attachedUrl.name] as List<String>)[0],
//                   ),
//                 SizedBox(
//                   width: 4,
//                 ),
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     "В ответ ${message.author.firstName}".s(14).w(700).c(context.mainBg),
//                     _buildFolder(context)
//                   ],
//                 ),
//                 SizedBox(
//                   width: 4,
//                 ),
//               ]
//           ),
//         ),
//       ),
//     );
//   }
//   Widget _buildFolder(BuildContext context){
//
//     return Container(
//       padding: const EdgeInsets.only(bottom: 8.0),
//       constraints: BoxConstraints(maxWidth: messageWidth.toDouble()-84),
//       child: (switch(message.type){
//         MessageType.audio =>  "Голосовое сообщение".s(14).w(500).c(context.mainBg).copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
//
//         MessageType.custom =>  Container(),
//
//         MessageType.file =>  Container(),
//
//         MessageType.image =>  Container(),
//
//         MessageType.system =>  Container(),
//
//         MessageType.text =>  (message as TextMessage).text.s(14).w(500).c(context.mainBg).copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
//
//         MessageType.unsupported =>  Container(),
//
//         MessageType.video =>  Container(),
//       })
//     );
//
//   }
//
// }