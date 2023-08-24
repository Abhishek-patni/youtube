// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube/Youtube/functions/snackbar.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:circle_progress_bar/circle_progress_bar.dart';
import 'package:lecle_downloads_path_provider/lecle_downloads_path_provider.dart';
import 'dart:ui_web';

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
    VideoQuality.high2160,
  ].toSet().toList();


  Future<void> _requestStoragePermissionAndDownload() async {
    PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      _downloadVideo();
    } else if (status.isDenied) {
      animatedSnackBar('Storage permission denied').show(context);
    } else if (status.isPermanentlyDenied) {
      animatedSnackBar(
              'Storage permission permanently denied. Open app settings to grant permission.')
          .show(context);
    }
  }

  void _downloadVideo() async {
    setState(() {
      _isDownloading = true;
      _progress = 0.0;
    });
    String query = _searchController.text.trim();

    if (query.isNotEmpty) {
      try {
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
            animatedSnackBar('Video downloaded successfully to $filePath')
                .show(context);
          } else{
            animatedSnackBar('Selected video quality is not available')
                .show(context);
          }
        } else {
          animatedSnackBar('No search results found').show(context);
        }
      } catch (e) {
        animatedSnackBar('Error downloading video: $e').show(context);
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
      animatedSnackBar('Error fetching video qualities: $e').show(context);
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
              height: 100,
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
                          _selectedQuality = availableQualities.first; // Set the selected quality to the first available quality
                        });
                      } else {
                        animatedSnackBar('No available video qualities').show(context);
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
            if (_isDownloading)
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

class AnimatedCount extends StatelessWidget {
  final double count;
  final String unit;
  final Duration duration;

  const AnimatedCount({
    super.key,
    required this.count,
    required this.unit,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: count),
      duration: duration,
      builder: (_, value, child) {
        final wholePart = value ~/ 1;
        final decimalPart = value - wholePart;
        return RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              TextSpan(
                text: '$wholePart',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: decimalPart.toStringAsFixed(2).substring(1)),
              TextSpan(text: ' $unit'),
            ],
          ),
        );
      },
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: DownloaderPage(),
  ));
}
