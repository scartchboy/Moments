import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_vision/google_ml_vision.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moments/constants/string_constants.dart';
import 'package:moments/views/widgets/face_painter.dart';

import 'dart:ui' as ui;

import 'package:moments/views/widgets/stars.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;
  File? _imageFile;
  ui.Image? _image;
  List<Face>? _faces;
  int? selectingIndex = 0;
  int count = 10;
  bool? isEnd = false;
  bool? isFast = false;
  String title = "";
  ConfettiController controllerBottomCenter =
      ConfettiController(duration: const Duration(seconds: 5));
  final Random random = Random();

  @override
  Widget build(BuildContext context) {
    Size? size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.indigo,
        appBar: AppBar(
          backgroundColor: Colors.indigo,
          elevation: 0.5,
          title: Text(title),
        ),
        floatingActionButton: floatingButtons(),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : (_imageFile == null)
                ? const Center(
                    child: Text(
                    AppStrings.takeSnap,
                    style: TextStyle(color: Colors.white, fontSize: 45),
                  ))
                : _faces!.isEmpty
                    ? Center(child: Image.file(_imageFile!))
                    : Stack(
                        children: [
                          Center(
                              child: FittedBox(
                            child: SizedBox(
                              width: _image!.width.toDouble(),
                              height: _image!.height.toDouble(),
                              child: CustomPaint(
                                painter: FacePainter(
                                    _image!, _faces![selectingIndex!], isEnd),
                              ),
                            ),
                          )),
                          confetti(size),
                        ],
                      ));
  }

  Container confetti(Size size) {
    return Container(
      alignment: Alignment.topCenter,
      height: size.height * 0.6,
      child: ConfettiWidget(
        confettiController: controllerBottomCenter,
        blastDirection: -pi / 2.6,
        blastDirectionality: BlastDirectionality.explosive,
        shouldLoop: false,
        colors: const [
          Colors.green,
          Colors.blue,
          Colors.pink,
          Colors.orange,
          Colors.purple
        ],
        createParticlePath: drawStar,
      ),
    );
  }

  Row floatingButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          onPressed: getImageFromCamera,
          child: const Icon(Icons.camera),
        ),
        const SizedBox(
          width: 15,
        ),
        FloatingActionButton(
          onPressed: getImageFromGallery,
          child: const Icon(Icons.add_a_photo),
        ),
      ],
    );
  }

  detectFaces(XFile? imageFile) async {
    setState(() => isLoading = true);
    final GoogleVisionImage visionImage =
        GoogleVisionImage.fromFile(File(imageFile!.path));
    final FaceDetector faceDetector = GoogleVision.instance.faceDetector();
    final List<Face> faces = await faceDetector.processImage(visionImage);
    if (mounted) {
      setState(() {
        _imageFile = File(imageFile.path);
        _faces = faces;
        _loadImage(File(imageFile.path));
      });
    }
    if (_faces!.isNotEmpty) {
      title = "";
      selectRandomFace();
    } else {
      setState(() {
        title = AppStrings.unableToRecognize;
      });
    }
  }

  getImageFromGallery() async {
    XFile? imageFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    return detectFaces(imageFile!);
  }

  getImageFromCamera() async {
    XFile? imageFile = await _picker.pickImage(
      source: ImageSource.camera,
    );
    return detectFaces(imageFile!);
  }

  selectRandomFace() {
    int countDown = 5;
    setState(() {
      controllerBottomCenter.stop();
    });
    Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        countDown--;
      });
    });

    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (countDown != 0) {
        setState(() {
          selectingIndex = random.nextInt(_faces!.length);
        });
      } else {
        setState(() {
          isEnd = true;
          controllerBottomCenter.play();
          timer.cancel();
        });
      }
    });
  }

  _loadImage(File file) async {
    final data = await file.readAsBytes();
    await decodeImageFromList(data).then((value) => setState(() {
          _image = value;
          isLoading = false;
        }));
  }
}
