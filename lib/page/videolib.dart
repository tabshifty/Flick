import 'package:Flick/helper/helper.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:Flick/model/video_resource.dart';
import 'package:Flick/widget/shrimmer.dart';
import 'package:Flick/widget/fullplayer.dart';

class VideoLibrary extends StatefulWidget{
  final bool active;
  const VideoLibrary({ super.key, required this.active });

  @override
  State<VideoLibrary> createState() => _VideoLibraryState();
}

class _VideoLibraryState extends State<VideoLibrary> {
  final List<VideoResource> _items = [];
  final dio = Helper.dio;
  final ScrollController _scrollController = ScrollController();
  int _total = 1;
  bool _isFirstLoaded = false;
  bool _isLoading = false;

  Future<void> getList() async {
    int pageIndex = _items.length;
    try {
      // setState(() {
      //   _isLoading = true;
      // });
      _isLoading = true;
      final response = await dio.get(
        'http://${Helper.apiPrefix}:8096/Users/4940978036c541dab9f28bca7cce44fb/Items',
        queryParameters: {
          'SortBy': 'DateCreated', //,SortName,ProductionYear,DateCreated
          'SortOrder': 'Descending', //Descending
          'IncludeItemTypes': 'Movie',
          'Recursive': true,
          'Fields': 'PrimaryImageAspectRatio,MediaSourceCount,BasicSyncInfo',
          'ImageTypeLimit': 1,
          'EnableImageTypes': 'Primary,Backdrop,Banner,Thumb',
          'StartIndex': pageIndex,
          'ParentId': '00c1c7c36a12e3a1a0539d7dfe59ad53',// 'fd1f57cc78a391d9bbc80930c7de76df', // 目录id
          'ApiKey': 'f2e09af4f8c845fa8bfca0bedb11407d',
          'Limit': 36,
        }
      );
      if (response.data != null) {
        // await asyncPrefs.setInt('count', _count);
        setState(() {
          if (!_isFirstLoaded) {
            _isFirstLoaded = true;
          }
          _total = response.data['TotalRecordCount'];
          _items.addAll(
            response.data["Items"].map<VideoResource>((item) {
              return VideoResource(
                id: item['Id'],
                aspectRatio: (item['PrimaryImageAspectRatio'])?.toDouble() ?? 1,
                name: item['Name'],
              );
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

  Widget buildListView() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      itemCount: _items.length + 1,
      cacheExtent: MediaQuery.of(context).size.height,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: index == _items.length ?
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _isLoading ? LoadingAnimationWidget.discreteCircle(color: Colors.white, size: 16) : SizedBox.shrink(),
                SizedBox(width: 8,),
                Text(
                  '加载中...',
                  style: TextStyle(color: Colors.white),
                ),
              ]
            ) : 
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return FullPlayer(media: _items[index]);
                    }
                  )
                );
              },
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Container(
                  // height: 50,
                  padding: const EdgeInsets.all(5),
                  color: Colors.white,
                  child: Stack(
                    // fit: StackFit.expand,
                    alignment: Alignment.bottomCenter,
                    children: [
                      Image.network(
                        'http://${Helper.apiPrefix}:8096/Items/${_items[index].id}/Images/Backdrop?quality=90',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return ShimmerLoading(
                            child: Container(
                              color: Colors.blueGrey,
                            )
                          );
                        },
                      ),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color.fromRGBO(0, 0, 0, 0),
                              Color.fromRGBO(0, 0, 0, 1),
                            ],
                          )
                        ),
                        child: Text(
                          _items[index].name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            )
        );
      }
    );
  }

  @override
  void initState() {
    if (widget.active) {
      getList();
    }
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if(!_isLoading && _items.length < _total) {
          getList();
        }
      }
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant VideoLibrary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_isFirstLoaded) {
      // _isFirstLoaded = true;
      getList();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        child: _isLoading ?
          LoadingAnimationWidget.flickr(leftDotColor: Color.fromRGBO(201,45,83,1), rightDotColor: Color.fromRGBO(248,193,31,1), size: 50) :
          buildListView()
      ),
    );
  }
}