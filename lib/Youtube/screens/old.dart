/*
// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:circle_progress_bar/circle_progress_bar.dart';
import 'package:lecle_downloads_path_provider/lecle_downloads_path_provider.dart';

class DownloaderPage extends StatefulWidget {
  const DownloaderPage({Key? key}) : super(key: key);
  @override
  _DownloaderPageState createState() => _DownloaderPageState();
}

class _DownloaderPageState extends State<DownloaderPage> {
  double _progress = 0.0;
  bool _isDownloading = false;
  final TextEditingController _searchController = TextEditingController();
  final YoutubeExplode _youtube = YoutubeExplode();
  VideoQuality? _selectedQuality;

  List<VideoQuality> _availableQualities = [
    VideoQuality.low144,
    VideoQuality.low240,
    VideoQuality.medium360,
    VideoQuality.medium480,
    VideoQuality.high720,
    VideoQuality.high1080,
    VideoQuality.high1440,
    VideoQuality.high2160, // Remove or reorder this line as needed
  ];

  Future<void> _requestStoragePermissionAndDownload() async {
    PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      _downloadVideo();
    } else if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied')),
      );
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Storage permission permanently denied. Open app settings to grant permission.'),
        ),
      );
    }
  }

  void _downloadVideo() async {
    setState(() {
      _isDownloading = true;
      _progress = 0.0;
    });
    String query = _searchController.text.trim();

    if (query.isNotEmpty) {
      var searchResults = await _youtube.search.getVideos(query);
      if (searchResults.isNotEmpty) {
        var selectedVideo = searchResults.first;
        var videoStreams =
        await _youtube.videos.streamsClient.getManifest(selectedVideo.id);

        var availableVideoStreams = videoStreams.muxed.where(
              (stream) => stream.videoQuality == _selectedQuality,
        );
        if (availableVideoStreams.isNotEmpty) {
          var selectedVideoStream = availableVideoStreams.first;

          String videoTitle = selectedVideo.title;
          String sanitizedTitle =
          videoTitle.replaceAll(RegExp(r'[^\w\s]+'), '');
          String fileName = '$sanitizedTitle.mp4';
          final directory = await DownloadsPath.downloadsDirectory();
          String filePath = '${directory?.path}/$fileName';
          print(filePath);

          Dio dio = Dio();
          Response response = await dio.get(
            selectedVideoStream.url.toString(),
            options: Options(responseType: ResponseType.bytes),
            onReceiveProgress: (received, total) {
              if (total != -1) {
                double progress = (received / total) * 100;
                print(progress);
                setState(() {
                  _progress = progress;
                  print(progress);
                });
              }
            },
          );

          File file = File(filePath);
          await file.writeAsBytes(response.data);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Video downloaded successfully to $filePath')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Selected video quality is not available')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No search results found')),
        );
      }
    }
    setState(() {
      _isDownloading = false;
    });
  }

  String extractVideoId(String youtubeUrl) {
    RegExp regExp = RegExp(
        r"^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^\#\&\?]*).*");
    Match? match = regExp.firstMatch(youtubeUrl);
    if (match != null && match.groupCount >= 7) {
      return match.group(7)!;
    } else {
      throw ArgumentError('Invalid YouTube URL');
    }
  }

  Future<List<VideoQuality>> fetchAvailableQualities(String youtubeUrl) async {
    try {
      var videoId = extractVideoId(youtubeUrl);
      var videoStreams =
      await _youtube.videos.streamsClient.getManifest(videoId);
      var availableVideoStreams = videoStreams.muxed;
      return availableVideoStreams
          .map((stream) => stream.videoQuality)
          .toList();
    } catch (e) {
      // print("Error fetching video qualities: $e");
      //use further
      return [];
    }
  }

  @override
  void dispose() {
    _youtube.close();
    super.dispose();
  }


  Widget _buildQualityDropdown() {
    return DropdownButton<VideoQuality>(
      underline: Container(),
      hint: const Text("Choose Quality"),
      value: _selectedQuality,
      onChanged: (newValue) {
        setState(() {
          _selectedQuality = newValue!;
        });
      },
      items: _availableQualities.map<DropdownMenuItem<VideoQuality>>((quality) {
        return DropdownMenuItem<VideoQuality>(
          value: quality,
          child: Text(quality.toString().split('.').last),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: GestureDetector(
                onTap: () {
                  //not any use till now
                },
                child: const Icon(Icons.ac_unit)),
          ),
        ],
        title: const Text(
          "Downloader",
          style: TextStyle(fontFamily: 'Gyahegi'),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextFormField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: "Enter url",
                  prefixIcon: Icon(Icons.format_underline_outlined),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    String youtubeUrl = _searchController.text.trim();
                    if (youtubeUrl.isNotEmpty) {
                      List<VideoQuality> availableQualities =
                      await fetchAvailableQualities(youtubeUrl);
                      if (availableQualities.isNotEmpty) {
                        setState(() {
                          _availableQualities = availableQualities;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('No available video qualities')),
                        );
                      }
                    }
                  },
                  child: const Text("Search"),
                ),
                Container(
                  child: _buildQualityDropdown(),
                ),
              ],
            ),
            const SizedBox(
              height: 60,
            ),
            ElevatedButton(
              onPressed: () {
                if (_selectedQuality != null) {
                  _requestStoragePermissionAndDownload();
                }
              },
              child: const Text("Download"),
            ),
            const SizedBox(
              height: 40,
            ),
            if(_isDownloading)
              SizedBox(
                width: 100,
                child: CircleProgressBar(
                  foregroundColor: Colors.blue,
                  backgroundColor: Colors.black12,
                  value: _progress,
                  child: Center(
                    child: AnimatedCount(
                      count: _progress * 100,
                      unit: '%',
                      duration: const Duration(milliseconds: 500),
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
*/
