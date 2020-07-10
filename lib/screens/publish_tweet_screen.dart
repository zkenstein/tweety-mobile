import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tweety_mobile/blocs/auth_profile/auth_profile_bloc.dart';

class PublishTweetScreen extends StatefulWidget {
  PublishTweetScreen({Key key}) : super(key: key);

  @override
  _PublishTweetScreenState createState() => _PublishTweetScreenState();
}

class _PublishTweetScreenState extends State<PublishTweetScreen> {
  final TextEditingController _bodyController = TextEditingController();
  double characterLmitValue = 0;
  double limit = 255;

  File _image;
  bool _imageInProcess = false;

  @override
  void initState() {
    _bodyController.addListener(_onBodyChanged);

    super.initState();
  }

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  void _onBodyChanged() {
    setState(() {
      updateCharacterLimit();
    });
  }

  updateCharacterLimit() {
    if (_bodyController.text.length == 0) {
      characterLmitValue = 0.0;
    }
    if (_bodyController.text.length > limit) {
      characterLmitValue = 1.0;
    }
    characterLmitValue = (_bodyController.text.length * 100) / 25500.0;
  }

  reachWarningLimit() {
    return _bodyController.text.length > (limit - 21);
  }

  reachErrorLimit() {
    return _bodyController.text.length > (limit + 9);
  }

  reachInitailErrorLimit() {
    return _bodyController.text.length > limit &&
        _bodyController.text.length < (limit + 9);
  }

  getIndicatorColor() {
    if (reachInitailErrorLimit()) {
      return Colors.red[400];
    }

    if (reachWarningLimit()) {
      return Colors.orange;
    }

    return Theme.of(context).primaryColor;
  }

  Future _getImage(ImageSource source) async {
    final picker = ImagePicker();

    setState(() {
      _imageInProcess = true;
    });

    final pickedFile = await picker.getImage(source: source);

    File image = File(pickedFile.path);

    if (image != null) {
      File croppedImage = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 100,
        compressFormat: ImageCompressFormat.png,
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Edit image',
          toolbarColor: Theme.of(context).scaffoldBackgroundColor,
          activeControlsWidgetColor: Theme.of(context).primaryColor,
        ),
      );

      setState(() {
        _image = croppedImage;
        _imageInProcess = false;
      });
    } else {
      setState(() {
        _imageInProcess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancel',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                      FlatButton(
                        onPressed: () {},
                        color: Theme.of(context).primaryColor,
                        disabledColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Text(
                          'Publish',
                          style: Theme.of(context).textTheme.button.copyWith(
                                color: Colors.white,
                              ),
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _userAvatar(),
                      Column(
                        children: <Widget>[
                          Container(
                            width: 320.0,
                            height: null,
                            child: SingleChildScrollView(
                              child: TextFormField(
                                controller: _bodyController,
                                autofocus: true,
                                maxLines: null,
                                style: Theme.of(context).textTheme.subtitle1,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,

                                  hintText: "What's up,doc?",
                                  // errorStyle: TextStyle(fontFamily: 'Poppins-Medium'),
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          _image != null ? _tweetImage() : Container(),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 50.0,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(-10, -10),
                      blurRadius: 10.0,
                    )
                  ],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              _getImage(ImageSource.camera);
                            },
                            child: Container(
                              height: 40.0,
                              child: Icon(
                                Icons.camera,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          InkWell(
                            onTap: () {
                              _getImage(ImageSource.gallery);
                            },
                            child: Container(
                              height: 40.0,
                              child: Icon(
                                Icons.image,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      _characterLimitIndicator(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tweetImage() {
    return Stack(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Image(
            image: FileImage(_image),
            width: 320.0,
          ),
        ),
        Positioned(
            top: 8.0,
            right: 8.0,
            child: InkWell(
              onTap: () {
                setState(() {
                  _image = null;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(
                    .65,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(3.0),
                  child: Icon(
                    Icons.close,
                    color: Colors.grey[300],
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget _userAvatar() {
    return BlocBuilder<AuthProfileBloc, AuthProfileState>(
      builder: (context, state) {
        if (state is AvatarLoaded) {
          return CircleAvatar(
            radius: 20.0,
            backgroundColor: Theme.of(context).cardColor,
            backgroundImage: NetworkImage(state.avatar),
          );
        }

        if (state is AuthProfileLoaded) {
          return CircleAvatar(
            radius: 20.0,
            backgroundColor: Theme.of(context).cardColor,
            backgroundImage: NetworkImage(state.user.avatar),
          );
        }
        return CircleAvatar(
          radius: 20.0,
          backgroundColor: Colors.white,
        );
      },
    );
  }

  Widget _characterLimitIndicator() {
    return _bodyController.text != null && reachErrorLimit()
        ? Padding(
            padding: EdgeInsets.only(right: 10),
            child: Text(
              '${limit.toInt() - _bodyController.text.length}',
              style: TextStyle(
                color: Colors.red[400],
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          )
        : Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                height: 25.0,
                width: 25.0,
                child: CircularProgressIndicator(
                  value: characterLmitValue,
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    getIndicatorColor(),
                  ),
                ),
              ),
              reachWarningLimit()
                  ? Text(
                      '${limit.toInt() - _bodyController.text.length}',
                      style: TextStyle(
                        color: getIndicatorColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Text(
                      '',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
            ],
          );
  }
}