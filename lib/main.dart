import 'dart:io';
import 'dart:convert';
import 'package:displayalbum/pages/bottompicker_sheet.dart';
import 'package:displayalbum/pages/comments.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:displayalbum/pages/AlertDialog.dart';
import 'package:displayalbum/pages/posts.dart';
import 'package:http/http.dart' as http;
import 'model/photo_model.dart';
import 'model/user_model.dart';
import 'pages/albums.dart';
import 'pages/photos.dart';
import 'model/comments_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  List<User>? users;
  MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  List<dynamic> albums = [];
  List<Photo> photos = [];
  List<dynamic> posts = [];
  List<Comment> comments = [];
  List<User> users = [];
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool uploadStatus = false;

  @override
  void initState() {
    super.initState();
    fetchAlbums();
    fetchPhotos();
    fetchPosts();
    fetchComments();
    fetchUsers();
  }

  Future<void> fetchAlbums() async {
    final response = await http
        .get(Uri.parse('https://jsonplaceholder.typicode.com/albums?userId=1'));
    if (response.statusCode == 200) {
      setState(() {
        albums = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load albums');
    }
  }

  Future<void> fetchPhotos() async {
    final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/photos?albumId=1'));
    if (response.statusCode == 200) {
      setState(() {
        photos = (json.decode(response.body) as List)
            .map((json) => Photo.fromJson(json))
            .toList();
      });
    } else {
      throw Exception('Failed to load photos');
    }
  }

  Future<void> fetchPosts() async {
    final response = await http
        .get(Uri.parse('https://jsonplaceholder.typicode.com/posts?userId=1'));
    if (response.statusCode == 200) {
      setState(() {
        posts = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<void> fetchComments() async {
    final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/comments?postId=1'));
    if (response.statusCode == 200) {
      setState(() {
        final List<dynamic> jsonComments = json.decode(response.body);
        comments = jsonComments
            .map((json) => Comment(name: json['name'], body: json['body']))
            .toList();
      });
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<void> fetchUsers() async {
    final response = await http
        .get(Uri.parse('https://jsonplaceholder.typicode.com/users?id=1'));
    if (response.statusCode == 200) {
      setState(() {
        users = (json.decode(response.body) as List)
            .map((json) => User.fromJson(json))
            .toList();
      });
    } else {
      throw Exception('Failed to load users');
    }
  }

  _imageFromCamera() async {
    final PickedFile? pickedImage =
        await _picker.getImage(source: ImageSource.camera, imageQuality: 50);
    if (pickedImage == null) {
      showAlertDialog(
          context: context,
          title: "Error Uploading!",
          content: "No Image was selected.");
      return;
    }
    final File fileImage = File(pickedImage.path);

    if (imageConstraint(fileImage)) {
      setState(() {
        _image = fileImage;
      });
    }
  }

  _imageFromGallery() async {
    final PickedFile? pickedImage =
        await _picker.getImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedImage == null) {
      showAlertDialog(
          context: context,
          title: "Error Uploading!",
          content: "No Image was selected.");
      return;
    }
    final File fileImage = File(pickedImage.path);
    if (imageConstraint(fileImage)) {
      setState(() {
        _image = fileImage;
      });
    }
  }

  bool imageConstraint(File image) {
    if (!['bmp', 'jpg', 'jpeg']
        .contains(image.path.split('.').last.toString())) {
      showAlertDialog(
          context: context,
          title: "Error Uploading!",
          content: "Image format should be jpg/jpeg/bmp.");
      return false;
    }
    if (image.lengthSync() > 100000) {
      showAlertDialog(
          context: context,
          title: "Error Uploading!",
          content: "Image Size should be less than 100KB.");
      return false;
    }
    return true;
  }

  uploadImage() async {
    if (_image == null) {
      showAlertDialog(
          context: context,
          title: "Error Uploading!",
          content: "No Image was selected.");
      return;
    }

    setState(() {
      uploadStatus = true;
    });
    var response = await http
        .post(Uri.parse('https://pcc.edu.pk/ws/file_upload.php'), body: {
      "image": _image!.readAsBytes().toString(),
      "name": _image!.path.split('/').last.toString()
    });
    if (response.statusCode != 200) {
      showAlertDialog(
          context: context,
          title: "Error Uploading!",
          content: "Server Side Error.");
    } else {
      var result = jsonDecode(response.body);
      showAlertDialog(
          context: context, title: "Image Sent!", content: result['message']);
    }
    setState(() {
      uploadStatus = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text('Adept Labz',
              style: TextStyle(
                color: Colors.white
              ),),
              backgroundColor: Colors.blueAccent,
            ),
            body: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(10.0),
                        // Display Progress Indicator if uploadStatus is true
                        child: uploadStatus
                            ? const SizedBox(
                                height: 100,
                                width: 100,
                                child: CircularProgressIndicator(
                                  strokeWidth: 7,
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        bottomPickerSheet(
                                            context,
                                            _imageFromCamera,
                                            _imageFromGallery);
                                      },
                                      child: CircleAvatar(
                                        radius:
                                            MediaQuery.of(context).size.width /
                                                6,
                                        backgroundColor: Colors.grey,
                                        backgroundImage: _image != null
                                            ? FileImage(_image!)
                                            : const AssetImage(
                                                    'assets/camera_img.png')
                                                as ImageProvider,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.blueAccent)),
                                      onPressed: () {
                                        _image != null
                                            ? showAlertDialog(
                                                context: context,
                                                title: "Notification!",
                                                content:
                                                    "Image uploaded successfully")
                                            : showAlertDialog(
                                                context: context,
                                                title: "Error Uploading!",
                                                content:
                                                    "No Image was selected.");
                                      },
                                      //uploadImage,
                                      child: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.file_upload,
                                            color: Colors.white),
                                            Text(
                                              'Upload Image',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                      ),
                                  Card(
                elevation: 50,
                surfaceTintColor: Colors.white,
                child: SizedBox(
                width: 300,
                height: 120,
                      child: ListTile(
                        title: Text(
                          users[index]
                              .name, // Accessing properties directly from User object
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Username: ${users[index].username}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              'Email: ${users[index].email}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              'Phone: ${users[index].phone}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              'Website: ${users[index].website}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Card(
                          elevation: 50,
                          surfaceTintColor: Colors.white,
                          child: SizedBox(
                            width: 150,
                            height: 130,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  const Text(
                                    'Albums',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ), //Text
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  //Text
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AlbumsScreen(albums: albums)),
                                      );
                                    },
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.blueAccent)),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Row(
                                        children: [
                                          Icon(Icons.album,
                                              color: Colors.white),
                                          Text(
                                            'Visit',
                                            style:
                                                TextStyle(color: Colors.white),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ), //Column
                            ), //Padding
                          ), //SizedBox//Card
                        ),
                        Card(
                          elevation: 50,
                          surfaceTintColor: Colors.white,
                          child: SizedBox(
                            width: 150,
                            height: 130,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  const Text(
                                    'Photos',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ), //Text
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  //Text
                                  ElevatedButton(
                                    onPressed: () => {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PhotosScreen(photos: photos)),
                                      )
                                    },
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.blueAccent)),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Row(
                                        children: [
                                          Icon(Icons.album,
                                              color: Colors.white),
                                          Text(
                                            'Visit',
                                            style:
                                                TextStyle(color: Colors.white),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ), //Column
                            ), //Padding
                          ), //SizedBox//Card
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Card(
                          elevation: 50,
                          surfaceTintColor: Colors.white,
                          child: SizedBox(
                            width: 150,
                            height: 130,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  const Text(
                                    'Posts',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ), //Text
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  //Text
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PostsScreen(posts: posts)),
                                      );
                                    },
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.blueAccent)),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Row(
                                        children: [
                                          Icon(Icons.album,
                                              color: Colors.white),
                                          Text(
                                            'Visit',
                                            style:
                                                TextStyle(color: Colors.white),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ), //Column
                            ), //Padding
                          ), //SizedBox//Card
                        ),
                        Card(
                          elevation: 50,
                          surfaceTintColor: Colors.white,
                          child: SizedBox(
                            width: 150,
                            height: 130,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  const Text(
                                    'Comments',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ), //Text
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  //Text
                                  ElevatedButton(
                                    onPressed: () {
                                      final commentsModel = CommentsScreenModel(
                                        title: 'Comments',
                                        comments: comments,
                                      );
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => CommentsScreen(model: commentsModel)),
                                      );
                                    },
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.blueAccent)),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Row(
                                        children: [
                                          Icon(Icons.album,
                                              color: Colors.white),
                                          Text(
                                            'Visit',
                                            style:
                                                TextStyle(color: Colors.white),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ), //Column
                            ), //Padding
                          ), //SizedBox//Card
                        ),
                      ],
                    ), //Center
                    // ListTile(
                    //   title: const Text('Albums'),
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //           builder: (context) =>
                    //               AlbumsScreen(albums: albums)),
                    //     );
                    //   },
                    // ),
                    // ListTile(
                    //   title: const Text('Photos'),
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //           builder: (context) =>
                    //               PhotosScreen(photos: photos)),
                    //     );
                    //   },
                    // ),
                    // ListTile(
                    //   title: const Text('Posts'),
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //           builder: (context) => PostsScreen(posts: posts)),
                    //     );
                    //   },
                    // ),
                    // ListTile(
                    //   title: const Text('Comments'),
                    //   onTap: () {
                    //     final commentsModel = CommentsScreenModel(
                    //       title: 'Comments',
                    //       comments: comments,
                    //     );
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //           builder: (context) =>
                    //               CommentsScreen(model: commentsModel)),
                    //     );
                    //   },
                    // ),
                    // ListTile(
                    //   title: const Text('Profile'),
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //           builder: (context) =>
                    //               ProfileScreen(users: users)),
                    //     );
                    //   },
                    // ),
                  ],
                );
              },
            )
            //     Column(
            //       children: [
            //         const SizedBox(height: 40),
            // //     Center(
            // //     child: Padding(
            // //     padding: const EdgeInsets.all(8.0),
            // //     // Display Progress Indicator if uploadStatus is true
            // //     child: uploadStatus
            // //         ? const SizedBox(
            // //       height: 100,
            // //       width: 100,
            // //       child: CircularProgressIndicator(
            // //         strokeWidth: 7,
            // //       ),
            // //     )
            // //         : Padding(
            // //       padding: const EdgeInsets.only(top: 40),
            // //       child: Column(
            // //         mainAxisAlignment: MainAxisAlignment.start,
            // //         crossAxisAlignment: CrossAxisAlignment.center,
            // //         children: [
            // //           GestureDetector(
            // //             onTap: () {
            // //               bottomPickerSheet(
            // //                   context, _imageFromCamera, _imageFromGallery);
            // //             },
            // //             child: CircleAvatar(
            // //               radius: MediaQuery.of(context).size.width / 6,
            // //               backgroundColor: Colors.grey,
            // //               backgroundImage: _image!= null
            // //                   ? FileImage(_image!)
            // //                   : const AssetImage('assets/camera_img.png') as ImageProvider,
            // //             ),
            // //           ),
            // //           const SizedBox(
            // //             height: 20,
            // //           ),
            // //           ElevatedButton(
            // //             onPressed: (){
            // //               _image!= null
            // //                   ? showAlertDialog(
            // //                   context: context, title: "Notification!", content: "Image uploaded successfully"
            // //               )
            // //                   :
            // //               showAlertDialog(
            // //                   context: context,
            // //                   title: "Error Uploading!",
            // //                   content: "No Image was selected.")
            // //
            // //               ;
            // //             },
            // //             //uploadImage,
            // //             child: const Padding(
            // //               padding: EdgeInsets.all(8.0),
            // //               child: Row(
            // //                 mainAxisSize: MainAxisSize.min,
            // //                 children: [
            // //                   Icon(Icons.file_upload),
            // //                   Text(
            // //                     'Upload Image',
            // //                   ),
            // //                 ],
            // //               ),
            // //             ),
            // //           )
            // //         ],
            // //       ),
            // //     ),
            // //   ),
            // // ),
            //
            // ]
            //   ),
            ));
  }
}
