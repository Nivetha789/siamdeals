import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:siamdealz/core/ApiProvider/api_provider.dart';
import 'package:siamdealz/utils/ProgressDialog.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ResponseModule/HtmlContentModel.dart';
import '../utils/check_internet.dart';
import '../utils/handler/toast_handler.dart';

class HtmlScreen extends StatefulWidget {
  String htmlId;

  HtmlScreen(this.htmlId);

  HtmlScreenState createState() => HtmlScreenState();
}

class HtmlScreenState extends State<HtmlScreen> {
  String htmlContent = "";
  String title = "";

  @override
  void initState() {
    super.initState();
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
          leading: const BackButton(),
          title: Text(title,
              style: const TextStyle(
                // color: Style.colors.logoRed,
                fontSize: 17.0,
                fontFamily: 'montserrat',
              )),
          centerTitle: false,
          // iconTheme: IconThemeData(color: Style.colors.logoRed),
          backgroundColor: Colors.white,
          // brightness: Brightness.light,
        ),
        body: Container(
          color: Colors.white,
          child: Stack(
            children: [
              ListView(
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        top: 20.0, left: 20.0, right: 20.0, bottom: 20.0),
                    child: Html(
                      anchorKey: staticAnchorKey,
                      data: htmlContent,
                      // tagsList: Html.tags..addAll(["bird", "flutter"]),
                      // style: {
                      //   Style()
                      // },
                      style: {
                        "table": Style(
                          fontFamily: 'montserrat',
                          // backgroundColor:
                          //     Color.fromARGB(0x50, 0xee, 0xee, 0xee),
                        ),
                        "tr": Style(
                          fontFamily: 'montserrat',
                        ),
                        "th": Style(
                          fontFamily: 'montserrat',
                        ),
                        "td": Style(
                          fontFamily: 'montserrat',
                        ),
                        'h5': Style(
                          fontFamily: 'montserrat',
                        ),
                      },
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
                      //   // print("Opening $url...");
                      // },
                      // onImageTap: (src, _, __, ___) {
                      //   print(src);
                      // },
                      // onImageError: (exception, stackTrace) {
                      //   print(exception);
                      // },
                      onLinkTap: (url, _, __) async {
                          await launchUrl(
                          Uri.parse(url!),
                          mode: LaunchMode.externalApplication,
                        );
                        debugPrint("Opening $url...");
                      },
                      onCssParseError: (css, messages) {
                        print("css that errored: $css");
                        print("error messages:");
                        messages.forEach((element) {
                          print(element);
                        });
                      },
                    ),
                  )
                ],
              ),
            ],
          ),
        ));
  }

  aboutUsApi() async {
    ProgressDialog().showLoaderDialog(context);
    Dio dio = new Dio();
    // String regNo = await SharedPreference().getRegNo();

    // dio.options.contentType = Headers.formUrlEncodedContentType;

    print('response ' + ApiProvider.getHtmlContentApi + widget.htmlId);

    final response = await dio.get(
      ApiProvider.getHtmlContentApi + widget.htmlId,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.toString());
      HtmlContentModel aboutUsModel = HtmlContentModel.fromJson(map);

      if (aboutUsModel.nStatus == 1) {
        ProgressDialog().dismissDialog(context);

        setState(() {
          title = aboutUsModel.jResult![0].cPages!;
          htmlContent = aboutUsModel.jResult![0].cDescription!;
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
