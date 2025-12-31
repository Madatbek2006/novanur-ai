// import 'package:auto_route/auto_route.dart';
// import 'package:b2b/core/extensions/text_extensions.dart';
// import 'package:b2b/core/gen/assets/assets.gen.dart';
// import 'package:b2b/domain/models/chat/discuss.dart';
// import 'package:b2b/domain/models/product/product_detail.dart';
// import 'package:b2b/domain/models/service/service_detail.dart';
// import 'package:b2b/presentation/router/app_router.dart';
// import 'package:b2b/presentation/support/colors/static_colors.dart';
// import 'package:b2b/presentation/support/extensions/color_extension.dart';
// import 'package:b2b/presentation/widgets/card/custom_card.dart';
// import 'package:b2b/presentation/widgets/image/rounded_cached_network_image_widget.dart';
// import 'package:b2b/utils/extensions/image.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:shimmer/shimmer.dart';
//
// class DiscussMessageWidget extends StatelessWidget{
//
//   final Discuss? discuss;
//   final double messageMaxWidth;
//   final bool isSentByMe;
//
//   const DiscussMessageWidget({super.key, this.discuss, required this.messageMaxWidth, required this.isSentByMe});
//   @override
//   Widget build(BuildContext context) {
//     if(discuss==null)return Container();
//
//
//     switch(discuss?.type){
//       case "productDiscuss":
//         return _buildProduct(context);
//       case "serviceDiscuss":
//         return _buildService(context);
//       case "request_price":
//         return _buildRequestPrice(context);
//       case "requestDiscuss":
//         return _buildRequestDiscuss(context);
//       case "audio_call":
//         return _buildAudioCall(context);
//       case "video_call":
//         return _buildVideoCall(context);
//       default:
//         return Container();
//     }
//   }
//
//   Widget _buildProduct(BuildContext context){
//     return Padding(
//       padding: EdgeInsets.only(bottom: 8),
//       child: switch(discuss!.state){
//         DiscussState.loading => _buildLoading(),
//         DiscussState.error => Container(),
//         DiscussState.success => _buildProductSuccess(context),
//       },
//     );
//   }
//
//
//   Widget _buildProductSuccess(BuildContext context){
//     final ProductDetail product = discuss!.data as ProductDetail;
//
//     return InkWell(
//       onTap: (){
//         context.router.push(ProductDetailRoute(detail: product));
//       },
//       child: CustomCard(
//         borderRadius: BorderRadius.circular(4),
//         color: Colors.white.withValues(alpha: 0.2),
//         padding: EdgeInsets.all(4),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           "Mahsulot bo'yicha munozara".s(12).w(500).c(isSentByMe ? context.mainBg : context.textPrimary),
//           SizedBox(height: 8),
//           SizedBox(
//             height: 80,
//             width: messageMaxWidth-12,
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//
//                 RoundedCachedNetworkImage(
//                   height: 64,
//                   width: 64,
//                   borderRadius: BorderRadius.circular(4),
//                   imageUrl: product.mainPhotoUrl,
//                 ),
//                 SizedBox(
//                   width: 8,
//                 ),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       product.titleLan.getLocalized(context).s(14).w(700).c(isSentByMe ? context.mainBg : context.textPrimary),
//                       "${product.price} UZS".s(12).w(500).c(isSentByMe ? context.mainBg : context.textPrimary),
//                       "${product.priceUsd} USD".s(12).w(500).c(isSentByMe ? context.mainBg : context.textPrimary),
//                       "Цена: ${product.priceWithNds} UZS QQS bilan(12%) за ${product.currency}".s(12).w(500).c(isSentByMe ? context.mainBg : context.textPrimary)
//                       .copyWith(
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//
//
//                     ],
//                   ),
//                 )
//
//
//               ]),
//           )
//         ],
//         ),
//       ),
//     );
//   }
//
//
//   Widget _buildRequestDiscuss(BuildContext context){
//     return Container();
//     // return Padding(
//     //   padding: EdgeInsets.only(bottom: 8),
//     //   child: InkWell(
//     //     onTap: (){
//     //       context.router.push(ProductDetailRoute(detail: product));
//     //     },
//     //     child: CustomCard(
//     //       borderRadius: BorderRadius.circular(4),
//     //       color: Colors.white.withValues(alpha: 0.2),
//     //       padding: EdgeInsets.all(4),
//     //       child: Column(
//     //         crossAxisAlignment: CrossAxisAlignment.start,
//     //         children: [
//     //           "Mahsulot bo'yicha munozara".s(12).w(500).c(isSentByMe ? context.mainBg : context.textPrimary),
//     //           SizedBox(height: 8),
//     //           SizedBox(
//     //             height: 72,
//     //             width: messageMaxWidth-12,
//     //             child: Row(
//     //                 crossAxisAlignment: CrossAxisAlignment.center,
//     //                 children: [
//     //
//     //                   RoundedCachedNetworkImage(
//     //                     height: 64,
//     //                     width: 64,
//     //                     borderRadius: BorderRadius.circular(4),
//     //                     imageUrl: product.mainPhotoUrl,
//     //                   ),
//     //                   SizedBox(
//     //                     width: 8,
//     //                   ),
//     //                   Expanded(
//     //                     child: Column(
//     //                       crossAxisAlignment: CrossAxisAlignment.start,
//     //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     //                       children: [
//     //                         product.titleLan.getLocalized(context).s(14).w(700).c(isSentByMe ? context.mainBg : context.textPrimary),
//     //                         "${product.price} UZS".s(12).w(500).c(isSentByMe ? context.mainBg : context.textPrimary),
//     //                         "${product.priceUsd} USD".s(12).w(500).c(isSentByMe ? context.mainBg : context.textPrimary),
//     //                         "Цена: ${product.priceWithNds} UZS QQS bilan(12%) за ${product.currency}".s(12).w(500).c(isSentByMe ? context.mainBg : context.textPrimary)
//     //                             .copyWith(
//     //                           maxLines: 2,
//     //                           overflow: TextOverflow.ellipsis,
//     //                         ),
//     //
//     //
//     //                       ],
//     //                     ),
//     //                   )
//     //
//     //
//     //                 ]),
//     //           )
//     //         ],
//     //       ),
//     //     ),
//     //   )
//     // );
//   }
//
//
//
//   Widget _buildRequestPrice(BuildContext context){
//     return Padding(
//       padding: EdgeInsets.only(bottom: 8),
//       child: switch(discuss!.state){
//         DiscussState.loading => _buildLoading(),
//         DiscussState.error => _buildRequestPriceSuccess(context),
//         DiscussState.success => _buildRequestPriceSuccess(context),
//       },
//     );
//   }
//
//
//   Widget _buildRequestPriceSuccess(BuildContext context){
//
//     ProductDetail? product;
//     if(discuss!.data !=null){
//       product = discuss!.data as ProductDetail;
//     }
//
//
//     return CustomCard(
//       borderRadius: BorderRadius.circular(4),
//       color: Colors.white.withValues(alpha: 0.2),
//       padding: EdgeInsets.all(4),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(
//           height: 72,
//           width: messageMaxWidth-12,
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//
//               RoundedCachedNetworkImage(
//                 height: 64,
//                 width: 64,
//                 borderRadius: BorderRadius.circular(4),
//                 imageUrl: product?.mainPhotoUrl??"",
//               ),
//               SizedBox(
//                 width: 8,
//               ),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     "Narx bo‘yicha so‘rov".s(14).w(500).c(isSentByMe ? context.mainBg : context.textPrimary),
//                     if(product!=null)
//                     product.titleLan.getLocalized(context).s(14).w(700).c(isSentByMe ? context.mainBg : context.textPrimary).copyWith(
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     "Miqdori - ${discuss?.count??""} ${(product?.measureUnit??"").tr()}".s(14).w(600).c(isSentByMe ? context.mainBg : context.textPrimary)
//
//
//                   ],
//                 ),
//               )
//
//
//             ]),
//         )
//       ],
//       ),
//     );
//   }
//
//
//
//   Widget _buildService(BuildContext context){
//     return Padding(
//       padding: EdgeInsets.only(bottom: 8),
//       child: switch(discuss!.state){
//         DiscussState.loading => _buildLoading(),
//         DiscussState.error => Container(),
//         DiscussState.success => _buildServiceSuccess(context),
//       },
//     );
//   }
//
//   Widget _buildServiceSuccess(BuildContext context){
//     final ServiceDetail service = discuss!.data as ServiceDetail;
//     return InkWell(
//       onTap: (){
//         context.router.push(ServiceDetailRoute(detail: service));
//       },
//       child: CustomCard(
//         borderRadius: BorderRadius.circular(4),
//         color: Colors.white.withValues(alpha: 0.2),
//         padding: EdgeInsets.all(4),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             "Xizmat bo'yicha munozara".s(12).w(500).c(isSentByMe ? context.mainBg : context.textPrimary),
//             SizedBox(height: 8),
//             SizedBox(
//               height: 80,
//               width: messageMaxWidth-12,
//               child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//
//                     RoundedCachedNetworkImage(
//                       height: 64,
//                       width: 64,
//                       borderRadius: BorderRadius.circular(4),
//                       imageUrl: service.mainPhotoUrl??"",
//                     ),
//                     SizedBox(
//                       width: 8,
//                     ),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         // mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           service.titleLan.getLocalized(context).s(14).w(700).c(isSentByMe ? context.mainBg : context.textPrimary),
//                           "${service.categoryLan.getLocalized(context)} - ${service.subcategoryLan.getLocalized(context)}".s(12).w(500).c(isSentByMe ? context.mainBg : context.textPrimary).copyWith(maxLines: 2, overflow: TextOverflow.ellipsis,),
//
//                         ],
//                       ),
//                     )
//
//
//                   ]),
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//
//
//
//
//
//   Widget _buildAudioCall(BuildContext context) {
//     return CustomCard(
//       borderRadius: BorderRadius.circular(4),
//       color: Colors.white.withValues(alpha: 0.2),
//       padding: EdgeInsets.all(4),
//       child: SizedBox(
//         height: 48,
//         child: Row(
//           children: [
//             CustomCard(
//               color: isSentByMe?context.mainBg:context.primaryLight,
//               borderRadius: BorderRadius.circular(360),
//               height: 48,
//               width: 48,
//               child: Center(
//                 child: Assets.images.component.icAudioCall.svgCustom(
//                   color: isSentByMe?context.primaryLight:context.mainBg,
//                   height: 32,
//                   width: 32
//                 ),
//               ),
//             ),
//
//             SizedBox(
//               width: 8,
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 "Audio call".s(12).w(600).c(isSentByMe?context.mainBg:context.primaryLight),
//                 (discuss!.duration??"").s(14).w(700).c(isSentByMe?context.mainBg:context.primaryLight),
//               ],
//             ),
//             SizedBox(width: 8),
//           ],
//         ),
//       ),
//     );
//   }
//
//
//   Widget _buildVideoCall(BuildContext context) {
//     return CustomCard(
//       borderRadius: BorderRadius.circular(4),
//       color: Colors.white.withValues(alpha: 0.2),
//       padding: EdgeInsets.all(4),
//       child: SizedBox(
//         height: 48,
//         child: Row(
//           children: [
//             CustomCard(
//               color: isSentByMe?context.mainBg:context.primaryLight,
//               borderRadius: BorderRadius.circular(360),
//               height: 48,
//               width: 48,
//               child: Center(
//                 child: Assets.images.component.icAudioCall.svgCustom(
//                     color: isSentByMe?context.primaryLight:context.mainBg,
//                     height: 32,
//                     width: 32
//                 ),
//               ),
//             ),
//
//             SizedBox(
//               width: 8,
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 "Video call".s(12).w(600).c(isSentByMe?context.mainBg:context.primaryLight),
//                 (discuss!.duration??"").s(14).w(700).c(isSentByMe?context.mainBg:context.primaryLight),
//               ],
//             ),
//             SizedBox(width: 8),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLoading(){
//     return CustomCard(
//       borderRadius: BorderRadius.circular(4),
//       color: Colors.white.withValues(alpha: 0.2),
//       padding: const EdgeInsets.all(4),
//       child: Shimmer.fromColors(
//         baseColor: StaticColors.shimmerBaseColor,
//         highlightColor: StaticColors.shimmerHighLightColor,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//
//             // Заголовок
//             Container(
//               height: 12,
//               width: 160,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(6),
//               ),
//             ),
//
//             const SizedBox(height: 8),
//
//             SizedBox(
//               height: 72,
//               width: messageMaxWidth - 12,
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//
//                   // Фото
//                   Container(
//                     height: 64,
//                     width: 64,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ),
//
//                   const SizedBox(width: 8),
//
//                   Expanded(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//
//                         Container(
//                           height: 14,
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                         ),
//
//                         Container(
//                           height: 12,
//                           width: 120,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                         ),
//
//                         Container(
//                           height: 12,
//                           width: 100,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                         ),
//
//                         Container(
//                           height: 12,
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//
//   }
// }
