import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class LocalSongsPage extends StatefulWidget {
  const LocalSongsPage({Key? key}) : super(key: key);

  @override
  _LocalSongsPageState createState() => _LocalSongsPageState();
}

class _LocalSongsPageState extends State<LocalSongsPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSongs();
  }

  List<FileSystemEntity>? _files;
  List<FileSystemEntity> _songs = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void getSongs() async {
    final status = await Permission.storage.request();

    if (status.isGranted) {
      // final dir = await getApplicationDocumentsDirectory();
      // //From path_provider package
      // final savedDir = Directory(dir.parent.parent.path + '/Download');

      Directory savedDir = Directory('/storage/emulated/0/Download');
      print('aaaa save dir ${savedDir}');
      print('aaa length ${_songs.length}');
      _files = savedDir.listSync(recursive: true, followLinks: false);
      for (FileSystemEntity entity in _files!) {
        String path = entity.path;
        if (path.endsWith('.mp3') ||
            path.endsWith('flac') ||
            path.endsWith('m4a')) _songs.add(entity);
      }
      //print('aaaa ${_songs}');

    }
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()

    setState(() {
      _files = [];
      _songs = [];
      getSongs();
    });
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    //items.add((items.length+1).toString());

    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    // return RefreshConfiguration(
    //   footerTriggerDistance: 15,
    //   dragSpeedRatio: 0.91,
    //   headerBuilder: () => MaterialClassicHeader(),
    //   footerBuilder: () => ClassicFooter(),
    //   enableLoadingWhenNoData: false,
    //   enableRefreshVibrate: false,
    //   enableLoadMoreVibrate: false,
    //   shouldFooterFollowWhenNotFull: (state) {
    //     // If you want load more with noMoreData state ,may be you should return false
    //     return false;
    //   },
    return Scaffold(
        appBar: AppBar(
            title: Text("Audio File list from Storage"),
            backgroundColor: Colors.redAccent),
        body: SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            enablePullUp: false,
            header: WaterDropHeader(),
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: _songs == null
                ? Text("Searching Files")
                : ListView.builder(
                    //if file/folder list is grabbed, then show here
                    itemCount: _songs.length,
                    itemBuilder: (context, index) {
                      return Card(
                          child: ListTile(
                        title: Text(_songs[index].path.split('/').last),
                        leading: Icon(Icons.audiotrack),
                        trailing: Icon(
                          Icons.play_arrow,
                          color: Colors.redAccent,
                        ),
                        onTap: () {
                          // you can add Play/push code over here
                        },
                      ));
                    },
                  )));
    // );
  }
}
