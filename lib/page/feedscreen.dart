import 'dart:math';
import 'package:Flick/model/media_resource.dart';
import 'package:flutter/material.dart';
import 'package:Flick/helper/helper.dart';
import 'package:Flick/widget/flickplayer.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:wakelock_plus/wakelock_plus.dart';


class FeedScreen extends StatefulWidget {
  final bool active;

  const FeedScreen({ super.key, required this.active});

  @override
  State<FeedScreen> createState() {
    return _FeedScreenState();
  }
}

class _FeedScreenState extends State<FeedScreen> {
  final List<MediaResource> _urls = [];
  final dio = Helper.dio;
  final asyncPrefs = Helper.asyncPrefs;
  int _count = 0;
  // bool _isFirstLoaded = false;
  bool _firstLoaded = false;
  // int _startIndex = 0;
  int _currentIndex = 0;
  bool _isLoading = false;

  Future<void> getList() async {
    int pageIndex = _count != 0 ? Random().nextInt(_count) : 0;
    try {
      _isLoading = true;
      final response = await dio.get(
        'http://$apiPrefix:8096/Users/4940978036c541dab9f28bca7cce44fb/Items',
        queryParameters: {
          'SortBy': 'SortName', //,SortName,ProductionYear,DateCreated
          'SortOrder': 'Descending',
          'IncludeItemTypes': 'Movie',
          'Recursive': true,
          'Fields': 'PrimaryImageAspectRatio,MediaSourceCount,BasicSyncInfo',
          'ImageTypeLimit': 1,
          'EnableImageTypes': 'Primary,Backdrop,Banner,Thumb',
          'StartIndex': pageIndex,
          'ParentId': 'ab332dbd7b3c753f3ef61a792bb73aa4', // 目录id
          'ApiKey':  'f2e09af4f8c845fa8bfca0bedb11407d',
          'Limit': 36,
        }
      );
      if (response.data != null) {
        _count = response.data['TotalRecordCount'];
        await asyncPrefs.setInt('count', _count);
        setState(() {
          if (!_firstLoaded) {
            _firstLoaded = true;
          }
          _urls.addAll(
            response.data["Items"].map<MediaResource>((item) {
              return MediaResource(id: item['Id'], aspectRatio: (item['PrimaryImageAspectRatio'])?.toDouble() ?? 1);
            }).toList()
          );
        });
      }
    } catch (error) {
      //
    } finally {
      _isLoading = false;
    }
  }

  Future<void> start() async {
    int? count = await asyncPrefs.getInt('count');
    _count = count??0;
      getList();
    // getList();
    // getRecentList();
  }

  @override
  void initState() { 
    start();
    WakelockPlus.enable();
    super.initState();
  }

  // @override
  // void didUpdateWidget(covariant FeedScreen oldWidget) {
  //   if (widget.active) {
  //     if(!WakelockPlus.enabled) {
  //       WakelockPlus.enable();
  //     }
  //   }
  //   super.didUpdateWidget(oldWidget);
  // }

  Widget buildPageView() {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      allowImplicitScrolling: true,
      onPageChanged: (value) {
        if (value > _urls.length - 3 && !_isLoading) {
          getList();
        } 
        setState(() {
          _currentIndex = value;
        });
      },
      itemCount: _urls.length,
      itemBuilder: (BuildContext context, int index) {
        return FlickPlayer(media: _urls[index], shouldPlay: index == _currentIndex && widget.active);
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: _firstLoaded ? buildPageView() : 
        LoadingAnimationWidget.flickr(leftDotColor: Color.fromRGBO(201,45,83,1), rightDotColor: Color.fromRGBO(248,193,31,1), size: 50),
      // child: LoadingAnimationWidget.flickr(leftDotColor: Color.fromRGBO(201,45,83,1), rightDotColor: Color.fromRGBO(248,193,31,1), size: 50),
    );
  }

}