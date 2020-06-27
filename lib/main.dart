import 'dart:async';
import 'package:flutter/material.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';

import 'CircularProgress.dart';

const String kTitle = 'Mauvaise surprise';
enum PlayerState { stopped, playing, paused }

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        fontFamily: 'FredokaOne',
      ),
      home: MyHomePage(title: kTitle),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AudioCache audioCache;
  AudioPlayer audioPlayer;

  PlayerState playerState = PlayerState.stopped;
  StreamSubscription _audioPlayerStateSubscription;

  final String dogSound = 'sounds/barkingdog.mp3';
  final String barkingDogImagepath = 'assets/images/barkingdog.gif';
  final String stillDogImagepath = 'assets/images/barkingdog.jpg';
  final int delay = 7000;
  bool displayProgress = false;

  Timer barkingTimer;
  String buttonImagePath;

  @override
  void initState() {
    super.initState();
    buttonImagePath = stillDogImagepath;
    initAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayerStateSubscription.cancel();
    audioPlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Center(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                displayProgress
                    ? CircularProgress(
                        size: 250,
                        duration: Duration(milliseconds: delay),
                        color: Colors.blue,
                      )
                    : Container(width: 250),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        if (playerState == PlayerState.playing) {
                          displayProgress = false;
                          stop();
                          barkingTimer?.cancel();
                        } else {
                          displayProgress = true;
                          barkingTimer = Timer(Duration(milliseconds: delay), () {
                            play();
                          });
                        }
                      });
                    }
                  },
                  child: AnimatedContainer(
                    width: 250,
                    height: 250,
                    duration: Duration(milliseconds: 400),
                    curve: Curves.bounceOut,
                    decoration: BoxDecoration(
                      color: Colors.yellow[500],
                      borderRadius: BorderRadius.circular(130.0),
                      image: DecorationImage(
                        image: AssetImage(buttonImagePath),
                        fit: BoxFit.fill,
                      ),
                      border: Border.all(color: Colors.yellow, width: 2.0, style: BorderStyle.solid),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.4),
                          offset: Offset(0, 10.0),
                          blurRadius: 10.0,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void initAudioPlayer() {
    audioPlayer = AudioPlayer();
    audioCache = AudioCache(fixedPlayer: audioPlayer);
    audioCache.load(dogSound);

    _audioPlayerStateSubscription = audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.PLAYING) {
        setState(() => buttonImagePath = barkingDogImagepath);
      } else if (s == AudioPlayerState.STOPPED || s == AudioPlayerState.COMPLETED) {
        setState(() {
          playerState = PlayerState.stopped;
          buttonImagePath = stillDogImagepath;
        });
      }
    }, onError: (msg) {
      setState(() {
        playerState = PlayerState.stopped;
      });
    });
  }

  Future play() async {
    audioPlayer = await audioCache.play(dogSound);
    setState(() {
      playerState = PlayerState.playing;
      displayProgress = false;
    });
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() => playerState = PlayerState.paused);
  }

  Future stop() async {
    await audioPlayer.stop();
    setState(() {
      playerState = PlayerState.stopped;
    });
  }
}
