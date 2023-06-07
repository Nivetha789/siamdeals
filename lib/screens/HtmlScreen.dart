// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:siamdealz/core/ApiProvider/api_provider.dart';
import 'package:siamdealz/utils/ProgressDialog.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ResponseModule/HtmlContentModel.dart';
import '../utils/check_internet.dart';
import '../utils/handler/toast_handler.dart';

class HtmlScreen extends StatefulWidget {
  String htmlId;

  HtmlScreen(this.htmlId, {super.key});

  @override
  HtmlScreenState createState() => HtmlScreenState();
}

class HtmlScreenState extends State<HtmlScreen> {
  String htmlContent = "";
  String title = "";

  @override
  void initState() {
    super.initState();
    aboutUsApi();
    check().then((intenet) {
      if (intenet != null && intenet) {
        aboutUsApi();
      } else {
        ToastHandler.showToast(
            message: "Please check your internet connection");
      }
    });
  }

  final staticAnchorKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        // backgroundColor: Style.colors.white,
        appBar: AppBar(
          elevation: 4.0,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Color(0xFFA020F0),
            ),
          ),
          title: Text(title,
              style: const TextStyle(
                color: Color(0xFFA020F0),
                fontSize: 17.0,
                fontFamily: 'montserrat',
              )),
          centerTitle: false,
          // iconTheme: IconThemeData(color: Style.colors.logoRed),
          backgroundColor: Colors.white,
          // brightness: Brightness.light,
        ),
        body: Container(
          // color: Colors.white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: MediaQuery.of(context).size.height,
              margin: EdgeInsets.only(
                  top: 20.0, left: 20.0, right: 20.0, bottom: 20.0),
              child: HtmlWidget(
                htmlContent,
                // tagsList: Html.tags..addAll(["bird", "flutter"]),
                // style: {
                //   Style()
                // },
                // style: {
                //   "table": Style(fontFamily: 'montserrat', color: Colors.black
                //       // backgroundColor: Color.fromARGB(0x50, 0xee, 0xee, 0xee),
                //       ),
                //   "tr": Style(fontFamily: 'montserrat', color: Colors.black),
                //   "th": Style(fontFamily: 'montserrat', color: Colors.black),
                //   "td": Style(fontFamily: 'montserrat', color: Colors.black),
                //   'h5': Style(fontFamily: 'montserrat', color: Colors.black),
                // },
                // // customRender: {
                // //   "table": (context, child) {
                // //     return SingleChildScrollView(
                // //       scrollDirection: Axis.horizontal,
                // //       child: (context.tree as TableLayoutElement)
                // //           .toWidget(context),
                // //     );
                // //   },
                // //   "bird": (RenderContext context, Widget child) {
                // //     return TextSpan(text: "🐦");
                // //   },
                //   "flutter": (RenderContext context, Widget child) {
                //     return FlutterLogo(
                //       style: (context.tree.element!
                //                   .attributes['horizontal'] !=
                //               null)
                //           ? FlutterLogoStyle.horizontal
                //           : FlutterLogoStyle.markOnly,
                //       textColor: context.style.color!,
                //       // size: context.style.fontSize!.size! * 5,
                //     );
                //   },
                // },
                // onLinkTap: (url, _, __, ___) async {
                // await launchUrl(
                //   Uri.parse(url!),
                //   mode: LaunchMode.externalApplication,
                // );
                //   // debugPrint("Opening $url...");
                // },
                // onImageTap: (src, _, __, ___) {
                //   debugPrint(src);
                // },
                // onImageError: (exception, stackTrace) {
                //   debugPrint(exception);
                // },
                // onTapUrl: (){
                //   url
                // },
                // onTapUrl: (url) async {
                //   await launchUrl(
                //     Uri.parse(url),
                //     mode: LaunchMode.externalApplication,
                //   );
                //   debugPrint("Opening $url...");
                // },
                // onCssParseError: (css, messages) {
                //   debugPrint("css that errored: $css");
                //   debugPrint("error messages:");
                //   messages.forEach((element) {
                //     debugPrint(element.toString());
                //   });
                // },
              ),
            ),
          ),
        ));
  }

  aboutUsApi() async {
    // ProgressDialog().showLoaderDialog(context);
    Dio dio = Dio();
    // String regNo = await SharedPreference().getRegNo();

    // dio.options.contentType = Headers.formUrlEncodedContentType;

    debugPrint('response ' + ApiProvider.getHtmlContentApi + widget.htmlId);

    final response = await dio.get(
      ApiProvider.getHtmlContentApi + widget.htmlId,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.toString());
      HtmlContentModel aboutUsModel = HtmlContentModel.fromJson(map);

      if (aboutUsModel.nStatus == 1) {
        // ProgressDialog().dismissDialog(context);

        setState(() {
          title = aboutUsModel.jResult![0].cPages!;
          htmlContent = aboutUsModel.jResult![0].cDescription!;
          print("htmlcontent $htmlContent");
        });
      } else {
        ProgressDialog().dismissDialog(context);
        ToastHandler.showToast(message: aboutUsModel.cMessage!);
      }
    } else {
      ProgressDialog().dismissDialog(context);
      ToastHandler.showToast(message: "Bad Network Connection try again..");
    }
  }
}
