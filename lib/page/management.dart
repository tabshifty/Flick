import 'dart:async';

import 'package:Flick/helper/helper.dart';
import 'package:Flick/model/media_resource.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sqflite/sqflite.dart';
import 'package:Flick/widget/fullplayer.dart';

class Management extends StatefulWidget {
  final bool active;
  const Management({ super.key, required this.active });

  @override
  State<Management> createState() {
    return _ManagementState();
  }
}

class _ManagementState extends State<Management> {
  static const apiPrefix = '192.168.1.8';
  final List<MediaResource> _list = [];
  // bool _isLoading = false;
  bool _firstLoaded = false;

  Future<void> getMedia () async {
    // _isLoading = true;
    try {
      Database db = await Helper.db;
      final queryResult = await db.query('Media_Table');
      Helper.logger.i(queryResult);
      if (queryResult.isNotEmpty) {
        setState(() {
          if (!_firstLoaded) {
            _firstLoaded = true;
          }
          _list.addAll(queryResult.map((e) => MediaResource.fromMap(e)).toList());
        });
      }
    } catch (e) {
      //
    } finally {
      // _isLoading = false;
    }
  }

  Future<void> removeItem(String id, int index) async{
    // ?ApiKey=f2e09af4f8c845fa8bfca0bedb11407d //serverid=569efaacd6a641e5b0f29af671d671fd
    final String path = 'http://$apiPrefix:8096/Items/$id';
    try {
      await Helper.dio.delete(
        path,
        options: Options(
          headers: {
            "Authorization": 'MediaBrowser Token="8235814baade4c6aba9684ad82322ebf", Client="flip", Device="Jellyfin Server", DeviceId="569efaacd6a641e5b0f29af671d671fd"',
          }
        ),
        // queryParameters: {
        //   'ApiKey': 'f2e09af4f8c845fa8bfca0bedb11407d',
        // }
      );
      final db = await Helper.db;
      db.delete(
        'Media_Table',
        where: 'id = ?',
        whereArgs: [id],
      );
      _list.removeAt(index);
      setState(() {
        //
      });
    } catch(error) {
      Helper.logger.e(error);
    }
  }
  void clear(String id, int index) async {
    final db = await Helper.db;
      db.delete(
        'Media_Table',
        where: 'id = ?',
        whereArgs: [id],
      );
      _list.removeAt(index);
      setState(() {
        //
      });
  }
  Future<void> removeAllItems() async{
    // ?ApiKey=f2e09af4f8c845fa8bfca0bedb11407d //serverid=569efaacd6a641e5b0f29af671d671fd
    final String path = 'http://$apiPrefix:8096/Items';
    try {
      await Helper.dio.delete(
        path,
        queryParameters: {
          'ids': _list.map((item) => item.id).toList()
        },
        options: Options(
          headers: {
            "Authorization": 'MediaBrowser Token="8235814baade4c6aba9684ad82322ebf", Client="flip", Device="Jellyfin Server", DeviceId="569efaacd6a641e5b0f29af671d671fd"',
          }
        ),
        // queryParameters: {
        //   'ApiKey': 'f2e09af4f8c845fa8bfca0bedb11407d',
        // }
      );
      final db = await Helper.db;
      db.delete(
        'Media_Table',
      );
      _list.length = 0;
      setState(() {
        //
      });
    } catch(error) {
      Helper.logger.e(error);
    }
  }

  @override
  void initState() {
    if (widget.active) {
      getMedia();
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant Management oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_firstLoaded) {
      // _isFirstLoaded = true;
      getMedia();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      color: Colors.black,
      child: !_firstLoaded ?
        SizedBox.shrink():
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '待处理 (${_list.length})',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Helper.logger.d(_list.map((item) => item.id).toList());
                        Helper.showLoading(context);
                        removeAllItems().then((_) {
                          if(!mounted) return;
                          Navigator.of(context).pop();
                        }).catchError((error) {
                          if(!mounted) return;
                          Navigator.of(context).pop();
                        });
                      },
                      child: const Text(
                        '全部删除',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white
                        ),
                      ),
                    ),
                    
                  ],
                ),
              ),
              Expanded(child: 
                ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  itemCount: _list.length,
                  itemBuilder:(context, index) {
                    return Container(
                      height: 70,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(8))
                      ),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return FullPlayer(media: _list[index], vertical: true,);
                                  }
                                )
                              );
                            },
                            child: const Icon(
                              Icons.play_circle_outlined,
                              size: 30,
                            ),
                          ),
                          Expanded(child: SizedBox.expand()),
                          TextButton.icon(
                            onPressed: () {
                              clear(_list[index].id, index);
                            },
                            icon: Icon(Icons.cleaning_services_rounded),
                            label: Text('清除')
                          ),
                          TextButton.icon(
                            onPressed: () {
                              removeItem(_list[index].id, index);
                            },
                            icon: Icon(Icons.delete_sharp),
                            label: Text('删除')
                          ),
                        ],
                      ),
                    );
                  },
                )
              )
            ],
          )
        )
      ,
    );
  }
}