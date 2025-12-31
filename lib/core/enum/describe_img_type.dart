

import 'package:baiqavisit/core/gen/localization/strings.dart';

enum DescribeImgType{
  short,
  detailed,
  question;


  static DescribeImgType valueOrDefault(String value) {
    switch (value) {
      case "short":
        return DescribeImgType.short;
      case "detailed":
        return DescribeImgType.detailed;
      case "question":
        return DescribeImgType.question;
      default:
        return DescribeImgType.short;
    }
  }

  String get value{
    switch (this) {
      case DescribeImgType.short:
        return "short";
      case DescribeImgType.detailed:
        return "detailed";
        case DescribeImgType.question:
        return "question";
      default:
        return "short";
    }
  }


  String get title{
    switch(this){
      case DescribeImgType.short:
        return Strings.dashboardTypeShort;
      case DescribeImgType.detailed:
        return Strings.dashboardTypeDetailed;
      case DescribeImgType.question:
        return Strings.dashboardTypeQuestion;
      }
  }
}


