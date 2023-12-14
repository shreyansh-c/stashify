// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:stashify/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double availableScreenWidth = 0;
  List<Map<String, dynamic>> files = [];
  double usedSpace = 0.0;

  @override
  void initState() {
    super.initState();
    fetchDataFromFirebase();
  }

  Future<void> fetchDataFromFirebase() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('your_actual_collection_name')
        .get();

    List<Map<String, dynamic>> fileData = querySnapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => {
              'fileName': doc.get('your_actual_file_name_field') as String,
              'docID': doc.id,
              'downloadURL': doc.get('downloadURL') as String,
              'fileSize': doc.get('fileSize') as int,
            })
        .toList();

    setState(() {
      files = fileData;
      usedSpace = files.fold<int>(
              0, (sum, file) => sum + (file['fileSize'] as int? ?? 0)) /
          (1024 * 1024);
    });
  }

  Future<void> uploadFile(File file) async {
    try {
      String actualFileName = file.path.split('/').last;
      int fileSize = file.lengthSync();

      Reference storageReference =
          FirebaseStorage.instance.ref().child(actualFileName);
      UploadTask uploadTask = storageReference.putFile(file);
      await uploadTask.whenComplete(() => null);

      String downloadURL = await storageReference.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('your_actual_collection_name')
          .add({
        'your_actual_file_name_field': actualFileName,
        'downloadURL': downloadURL,
        'fileSize': fileSize,
      });

      fetchDataFromFirebase();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File uploaded successfully',
              style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.grey,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      //print('Error uploading file: $e');
    }
  }

  Future<void> deleteFile(String docID, String fileName) async {
    try {
      await FirebaseStorage.instance.ref().child(fileName).delete();

      await FirebaseFirestore.instance
          .collection('your_actual_collection_name')
          .doc(docID)
          .delete();

      fetchDataFromFirebase();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File deleted successfully',
              style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.grey,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      //print('Error deleting file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    availableScreenWidth = MediaQuery.of(context).size.width - 50;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
            alignment: Alignment.bottomCenter,
            height: 170,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(35),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Stashify",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Cloud Storage",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.black.withOpacity(.05),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.key,
                          size: 28,
                          color: Colors.blue,
                        ),
                        onPressed: () async {
                          try {
                            await FirebaseAuth.instance.signOut();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Logged out successfully",
                                    style: TextStyle(color: Colors.black)),
                                backgroundColor: Colors.grey,
                                duration: Duration(seconds: 2),
                              ),
                            );
                            if (mounted) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                              );
                            }
                          } catch (e) {
                            //print('Error during logout: $e');
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              children: [
                RichText(
                  text: TextSpan(
                    text: "Storage ",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: "${usedSpace.toStringAsFixed(2)} MB / 5.0 GB",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              children: [
                buildFileSizeChart("Used Space", Colors.blue, usedSpace / 5.0),
              ],
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(25),
              children: [
                const Row(
                  children: [
                    Text(
                      "Files",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                files.isEmpty
                    ? const Center(
                        child: Text(
                          "Click on the + button to add files",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : Column(
                        children: files.map((fileData) {
                          return buildFileRow(
                            fileData['fileName'],
                            fileData['docID'],
                            fileData['downloadURL'],
                          );
                        }).toList(),
                      ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles();

          if (result != null) {
            File file = File(result.files.single.path!);
            await uploadFile(file);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Container buildFileRow(String fileName, String docID, String? downloadURL) {
    final truncatedFileName =
        fileName.length > 20 ? '${fileName.substring(0, 20)}...' : fileName;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 65,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.file_copy,
                color: Colors.blue.shade200,
              ),
              const SizedBox(
                width: 12,
              ),
              Text(
                truncatedFileName,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          Row(
            children: [
              if (downloadURL != null)
                IconButton(
                  onPressed: () {
                    launch(downloadURL);
                  },
                  icon: const Icon(Icons.download),
                  color: Colors.grey,
                ),
              IconButton(
                onPressed: () {
                  deleteFile(docID, fileName);
                },
                icon: const Icon(Icons.delete),
                color: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Column buildFileSizeChart(String title, Color color, double widthPercentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: availableScreenWidth * widthPercentage,
          height: 4,
          color: color,
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
