import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class KaKaoPage extends StatefulWidget {
  const KaKaoPage({Key? key}) : super(key: key);

  @override
  State<KaKaoPage> createState() => _KaKaoPageState();
}

final FeedTemplate defaultFeed = FeedTemplate(
  content: Content(
    title: '딸기 치즈 케익',
    description: '#케익 #딸기 #삼평동 #카페 #분위기 #소개팅',
    imageUrl: Uri.parse(
        'https://mud-kage.kakao.com/dn/Q2iNx/btqgeRgV54P/VLdBs9cvyn8BJXB3o7N8UK/kakaolink40_original.png'),
    link: Link(
        webUrl: Uri.parse('https://developers.kakao.com'),
        mobileWebUrl: Uri.parse('https://developers.kakao.com')),
  ),
  itemContent: ItemContent(
    profileText: 'Kakao',
    profileImageUrl: Uri.parse(
        'https://mud-kage.kakao.com/dn/Q2iNx/btqgeRgV54P/VLdBs9cvyn8BJXB3o7N8UK/kakaolink40_original.png'),
    titleImageUrl: Uri.parse(
        'https://mud-kage.kakao.com/dn/Q2iNx/btqgeRgV54P/VLdBs9cvyn8BJXB3o7N8UK/kakaolink40_original.png'),
    titleImageText: 'Cheese cake',
    titleImageCategory: 'cake',
    items: [
      ItemInfo(item: 'cake1', itemOp: '1000원'),
      ItemInfo(item: 'cake2', itemOp: '2000원'),
      ItemInfo(item: 'cake3', itemOp: '3000원'),
      ItemInfo(item: 'cake4', itemOp: '4000원'),
      ItemInfo(item: 'cake5', itemOp: '5000원')
    ],
    sum: 'total',
    sumOp: '15000원',
  ),
  social: Social(likeCount: 286, commentCount: 45, sharedCount: 845),
  buttons: [
    Button(
      title: '웹으로 보기',
      link: Link(
        webUrl: Uri.parse('https: //developers.kakao.com'),
        mobileWebUrl: Uri.parse('https: //developers.kakao.com'),
      ),
    ),
    Button(
      title: '앱으로보기',
      link: Link(
        androidExecutionParams: {'key1': 'value1', 'key2': 'value2'},
        iosExecutionParams: {'key1': 'value1', 'key2': 'value2'},
      ),
    ),
  ],
);

class _KaKaoPageState extends State<KaKaoPage> {
  void _checkKaKao() async {
    var result = await LinkClient.instance.isKakaoLinkAvailable();
    if (result) {
      Uri uri = await LinkClient.instance.defaultTemplate(template: defaultFeed);
      await LinkClient.instance.launchKakaoTalk(uri);
    } else {
      _openKaKao();
    }
  }

  void _openKaKao() async {
    try {
      var rng = new Random();
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      File file = new File('$tempPath' + (rng.nextInt(100).toString() + '.jpg'));
      http.Response response = await http.get(Uri.parse('http://192.168.0.91:3000/?action=capture'));
      await file.writeAsBytes(response.bodyBytes);
      ImageUploadResult imageUploadResult = await LinkClient.instance.uploadImage(image: file);
      print('이미지 업로드 성공 \n${imageUploadResult.infos.original}');
    } catch (e) {
      print('이미지 업로드 실패 $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: ElevatedButton(child: Text('share'), onPressed: () {
      _checkKaKao();
    },),);
  }
}
