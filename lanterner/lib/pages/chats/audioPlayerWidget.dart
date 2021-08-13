import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder2/flutter_audio_recorder2.dart';
import 'package:lanterner/models/message.dart';
import 'package:lanterner/models/user.dart';
import 'package:lanterner/providers/messages_provider.dart';
import 'package:lanterner/services/databaseService.dart';
import 'package:lanterner/widgets/nestedWillPopScope.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeatureButtonsView extends StatefulWidget {
  final Function onUploadComplete;
  final Function onFocusChange;
  final Function toggleTextField;
  final User peer;
  final String uid;

  const FeatureButtonsView(
      {Key key,
      this.onUploadComplete,
      this.peer,
      this.uid,
      this.onFocusChange,
      @required this.toggleTextField})
      : super(key: key);
  @override
  _FeatureButtonsViewState createState() => _FeatureButtonsViewState();
}

class _FeatureButtonsViewState extends State<FeatureButtonsView> {
  bool _isPlaying;
  bool _isUploading;
  bool _isRecorded;
  bool _isRecording;

  AudioPlayer _audioPlayer;
  String _filePath;
  Duration _duration = new Duration();
  Duration _position = new Duration();

  FlutterAudioRecorder2 _audioRecorder;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _isPlaying = false;
    _isUploading = false;
    _isRecorded = false;
    _isRecording = false;
    _audioPlayer = AudioPlayer();
    _audioPlayer.onDurationChanged.listen((d) {
      setState(() {
        _duration = d;
      });
    });
    _audioPlayer.onAudioPositionChanged.listen((p) {
      setState(() {
        _position = p;
      });
    });
    focusNode.addListener(() {
      setState(() {
        widget.onFocusChange();
      });
    });
  }

  updaterecordertimer() async {
    Recording current = await _audioRecorder.current(channel: 0);

    _duration = current.duration;
    if (_duration.inSeconds >= 59) {
      _audioRecorder.stop();
      _isRecording = false;
      _isRecorded = true;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    // _audioRecorder.stop();
    focusNode.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NestedWillPopScope(
      onWillPop: () async {
        if (_isRecording) {
          setState(() {
            _isRecording = false;
            _duration = Duration();
          });
          _audioRecorder.stop();
          widget.toggleTextField(true);
          widget.onFocusChange();
          return false;
        } else if (_isRecorded) {
          setState(() {
            _isRecorded = false;
            _duration = Duration();
            _audioPlayer.stop();
            _isPlaying = false;
          });

          widget.toggleTextField(true);
          widget.onFocusChange();
          return false;
        } else {
          return true;
        }
      },
      child: Center(
        child: _isRecorded
            ? _isUploading
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: LinearProgressIndicator()),
                      Text('Uplaoding...'),
                    ],
                  )
                : Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                '00:' +
                                    _position
                                        .toString()
                                        .split(".")[0]
                                        .split(':')[2],
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[100]),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                ' - 00:' +
                                    _duration
                                        .toString()
                                        .split(".")[0]
                                        .split(':')[2],
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[350]),
                              ),
                            ),
                          ],
                        ),
                        Flexible(child: SizedBox(height: 20)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              margin: EdgeInsets.only(bottom: 5),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(50)),
                              child: IconButton(
                                icon: Icon(
                                  _isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.grey[350],
                                ),
                                onPressed: _onPlayButtonPressed,
                              ),
                            ),
                            Container(
                              height: 50,
                              width: 50,
                              margin: EdgeInsets.only(bottom: 5),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(50)),
                              child: IconButton(
                                icon:
                                    Icon(Icons.delete, color: Colors.grey[350]),
                                onPressed: () {
                                  setState(() {
                                    _isRecorded = false;
                                    _duration = Duration();
                                  });
                                  widget.toggleTextField(true);
                                  widget.onFocusChange();
                                },
                              ),
                            ),
                            Container(
                              height: 50,
                              width: 50,
                              margin: EdgeInsets.only(bottom: 5),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(50)),
                              child: IconButton(
                                icon: Icon(Icons.send_rounded,
                                    color: Colors.grey[350]),
                                onPressed: _onFileUploadButtonPressed,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _isRecording
                      ? Flexible(
                          child: TimerBuilder.periodic(Duration(seconds: 1),
                              builder: (context) {
                          updaterecordertimer();
                          int recordedSeconds = _duration.inSeconds + 1;
                          return Text(recordedSeconds.toString());
                        }))
                      : Container(),
                  Flexible(child: SizedBox(height: 20)),
                  Flexible(
                    child: Container(
                      // height: 50,
                      // width: 50,
                      // constraints: BoxConstraints(maxHeight: 50, maxWidth: 50),
                      margin: EdgeInsets.only(bottom: 5),
                      decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(50)),
                      child: IconButton(
                        icon: _isRecording
                            ? Icon(Icons.pause, color: Colors.grey[350])
                            : Icon(Icons.mic, color: Colors.grey[350]),
                        onPressed: _onRecordButtonPressed,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _onFileUploadButtonPressed() async {
    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    setState(() {
      _isUploading = true;
    });
    try {
      TaskSnapshot storageSnap = await firebaseStorage
          .ref('chats/audio/')
          .child(
              _filePath.substring(_filePath.lastIndexOf('/'), _filePath.length))
          .putFile(File(_filePath));

      String downloadUrl = await storageSnap.ref.getDownloadURL();
      final messageId = Uuid().v4();

      Message message = Message(
        messageId: messageId,
        content: downloadUrl,
        timeStamp: DateTime.now().toUtc().toString(),
        senderId: widget.uid,
        peerId: widget.peer.uid,
        type: 'audio',
      );

      DatabaseService db = DatabaseService();
      context.read(messagesProvider.notifier).add(message);
      await db.sendMessage(message, widget.peer);

      widget.onUploadComplete();
    } catch (error) {
      print('Error occured while uplaoding to Firebase ${error.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error occured while uplaoding'),
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
        _isRecorded = false;
        widget.toggleTextField(true);
        widget.onFocusChange();
      });
    }
  }

  Future<void> _onRecordButtonPressed() async {
    if (_isRecording) {
      _audioRecorder.stop();
      _isRecording = false;
      _isRecorded = true;
    } else {
      widget.toggleTextField(false);
      _isRecorded = false;
      _isRecording = true;

      await _startRecording();
    }
    setState(() {});
  }

  void _onPlayButtonPressed() {
    if (!_isPlaying) {
      _isPlaying = true;

      _audioPlayer.play(_filePath, isLocal: true);
      _audioPlayer.onPlayerCompletion.listen((duration) {
        setState(() {
          _isPlaying = false;
        });
      });
    } else {
      _audioPlayer.pause();
      _isPlaying = false;
    }
    setState(() {});
  }

  Future<void> _startRecording() async {
    final bool hasRecordingPermission =
        await FlutterAudioRecorder2.hasPermissions;

    if (hasRecordingPermission ?? false) {
      Directory directory = await getApplicationDocumentsDirectory();
      String filepath = directory.path +
          '/' +
          DateTime.now().millisecondsSinceEpoch.toString() +
          '.aac';
      _audioRecorder =
          FlutterAudioRecorder2(filepath, audioFormat: AudioFormat.AAC);
      await _audioRecorder.initialized;
      _audioRecorder.start();
      _filePath = filepath;
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Center(child: Text('Please enable recording permission'))));
    }
  }
}

class AudioFile extends StatefulWidget {
  // AudioPlayer audioPlayer;
  final Message message;
  final String uid;
  AudioFile({Key key, this.message, this.uid}) : super(key: key);

  @override
  _AudioFileState createState() => _AudioFileState();
}

class _AudioFileState extends State<AudioFile> {
  Duration _duration = new Duration();
  Duration _position = new Duration();
  bool isPlaying = false;
  bool isPaused = false;
  bool isRepeat = false;
  Color color = Colors.black;

  DatabaseService db = DatabaseService();
  List<IconData> _icons = [
    Icons.play_arrow_rounded,
    Icons.pause_circle_filled_rounded,
  ];

  AudioPlayer audioPlayer;

  @override
  void initState() {
    super.initState();

    audioPlayer = AudioPlayer();
    audioPlayer.onDurationChanged.listen((d) {
      setState(() {
        _duration = d;
      });
    });
    audioPlayer.onAudioPositionChanged.listen((p) {
      setState(() {
        _position = p;
      });
    });

    audioPlayer.setUrl(this.widget.message.content);
    audioPlayer.onPlayerCompletion.listen((event) {
      setState(() {
        _position = Duration(seconds: 0);
        if (isRepeat == true) {
          isPlaying = true;
        } else {
          isPlaying = false;
          isRepeat = false;
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.dispose();
  }

  Widget btnStart() {
    return IconButton(
      // padding: const EdgeInsets.only(bottom: 10),
      icon: isPlaying == false
          ? Icon(
              _icons[0],
              size: 25,
              color: Colors.white,
            )
          : Icon(_icons[1], size: 25, color: Colors.white),
      onPressed: () {
        if (isPlaying == false) {
          audioPlayer.play(this.widget.message.content);
          // increment the audio listened counter only if its not yours
          if (widget.message.senderId != widget.uid) {
            db.incrementAudioListened(widget.uid);
          }
          setState(() {
            isPlaying = true;
          });
        } else if (isPlaying == true) {
          audioPlayer.pause();
          setState(() {
            isPlaying = false;
          });
        }
      },
    );
  }

  Widget slider() {
    double maxValue;
    maxValue =
        _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 0;
    var progress =
        _duration.inSeconds.toDouble() > _position.inSeconds.toDouble()
            ? _position.inSeconds.toDouble()
            : _duration.inSeconds.toDouble();
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 1.0,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5),
      ),
      child: Slider(
          activeColor: Colors.white,
          inactiveColor: Colors.grey[400],
          value: progress,
          min: 0.0,
          max: maxValue,
          onChanged: (double value) {
            setState(() {
              changeToSecond(value.toInt());
              value = value;
            });
          }),
    );
  }

  void changeToSecond(int second) {
    Duration newDuration = Duration(seconds: second);
    audioPlayer.seek(newDuration);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        audioPlayer.stop();
        return true;
      },
      child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          decoration: BoxDecoration(
              color: widget.uid == widget.message.senderId
                  ? Theme.of(context).accentColor.withOpacity(0.8)
                  : Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(40)),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  btnStart(),
                  slider(),
                  isPlaying
                      ? Text(
                          '00:' +
                              _position.toString().split(".")[0].split(':')[2],
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[100]),
                        )
                      : Text(
                          '00:' +
                              _duration.toString().split(".")[0].split(':')[2],
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[350]),
                        ),
                ],
              ),
            ],
          )),
    );
  }
}
