import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:unisoft/widgets/Projects/project_badge.dart';
import '../../Values/values.dart';
import '../../constants/app_constans.dart';

class ProjectCardVertical extends StatelessWidget {
  final String projectName;
  final String idk;
  final String teamName;
  final String projeImagePath;
  final DateTime endDate;
  final DateTime startDate;
  final String status;

  ProjectCardVertical({
    Key? key,
    required this.idk,
    required this.status,
    required this.projeImagePath,
    required this.projectName,
    required this.teamName,
    required this.endDate,
    required this.startDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: HexColor.fromHex("20222A"),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ProjectBadge(projeImagePath: projeImagePath),
          const SizedBox(height: 10),
          _TaskToDoRow(projectName: projectName),
          const SizedBox(height: 10),
          _TeamAndStatusRow(teamName: teamName, status: status),
          const SizedBox(height: 10),
          _DateRow(
            label: AppConstants.start_date_key.tr,
            date: startDate,
          ),
          const SizedBox(height: 10),
          _DateRow(
            label: AppConstants.end_date_key.tr,
            date: endDate,
          ),
          const SizedBox(height: 10),
          _FileUploadSection(ProjectId: idk, endDate: endDate,),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _ProjectBadge extends StatelessWidget {
  final String projeImagePath;

  _ProjectBadge({required this.projeImagePath});

  @override
  Widget build(BuildContext context) {
    return ColouredProjectBadge(projeImagePath: projeImagePath);
  }
}

class _TaskToDoRow extends StatelessWidget {
  final String projectName;

  _TaskToDoRow({required this.projectName});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Task ToDo: ',
          style: GoogleFonts.laila(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          projectName,
          style: GoogleFonts.laila(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _TeamAndStatusRow extends StatelessWidget {
  final String teamName;
  final String status;

  _TeamAndStatusRow({required this.teamName, required this.status});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          child: Text(
            "${AppConstants.team_key.tr} : ",
            style: const TextStyle(
              color: Colors.amberAccent,
            ),
          ),
        ),
        Text(
          teamName,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 20),
        Text(
          AppConstants.status_key.tr,
          style: GoogleFonts.laila(
            color: Colors.amberAccent,
          ),
        ),
        Text(
          status,
          style: GoogleFonts.laila(
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _DateRow extends StatelessWidget {
  final String label;
  final DateTime date;

  _DateRow({required this.label, required this.date});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "${label} : ",
          style: GoogleFonts.laila(
            color: Colors.amberAccent,
          ),
        ),
        Text(
          DateFormat('dd/MM h:mm a').format(date),
          style: GoogleFonts.laila(
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _FileUploadSection extends StatefulWidget {
  final String ProjectId;
  final DateTime endDate;
  _FileUploadSection({
    required this.ProjectId,
    required this.endDate,
  });
  @override
  __FileUploadSectionState createState() => __FileUploadSectionState();
}

class __FileUploadSectionState extends State<_FileUploadSection> {
  final _picker = ImagePicker();
  bool _uploading = false; // Set initial state to false
  List<File> _files = [];
  List<FileInfo> _fileInfos = [];

  final _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _fetchFiles();
  }

  Future<void> _fetchFiles() async {
    try {
      final storageReference =
          _storage.ref().child('project_attachments/${widget.ProjectId}');

      final ListResult result = await storageReference.listAll();

      final urls = await Future.wait(result.items.map((ref) async {
        return ref.getDownloadURL();
      }));

      setState(() {
        _files = urls.map((url) => File(url)).toList();
      });

      final fileInfos = await FirebaseFirestore.instance
          .collection('project_attachments')
          .doc(widget.ProjectId)
          .collection('files')
          .get()
          .then((querySnapshot) {
        return querySnapshot.docs.map((doc) {
          final fileSizeInBytes = doc['size'];

          final fileSizeInMB =
              fileSizeInBytes / (1024 * 1024); // convert bytes to MB

          return FileInfo(
            fileName: doc['fileName'],
            fileSizeInMB: fileSizeInMB,
          );
        }).toList();
      });

      setState(() {
        _fileInfos = fileInfos;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching files: $e'),
        ),
      );
    }
  }

  Future<void> _uploadFile(File file) async {
    final fileName = path.basename(file.path);
    final reference = _storage
        .ref()
        .child('project_attachments/${widget.ProjectId}/$fileName');

    final metadata = SettableMetadata(contentType: 'application/octet-stream');

    setState(() {
      _uploading = true;
    });

    try {
      await reference.putFile(file, metadata);
      final downloadURL = await reference.getDownloadURL();

      // Store file metadata in Firestore
      await FirebaseFirestore.instance
          .collection('project_attachments')
          .doc(widget.ProjectId)
          .collection('files')
          .doc(fileName)
          .set({
        'fileName': fileName,
        'fileUrl': downloadURL,
        'size': await file.length(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File uploaded successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading file: $e'),
        ),
      );
    } finally {
      setState(() {
        _uploading = false;
      });
      _fetchFiles();
    }
  }
  @override
  Widget build(BuildContext context) {
    final currentDate = DateTime.now();
    final isPastDueDate = currentDate.isAfter(widget.endDate);
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${AppConstants.file_key.tr} ",
              style: GoogleFonts.laila(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w500,
              ),
            ),
            ElevatedButton(
              style: _buttonStyle2,
              onPressed: _getImageFromGallery,
              child: Text(
                AppConstants.choose_key.tr.toUpperCase(),
                style: _buttonTextStyle,
              ),
            ),
            const SizedBox(height: 10),
            // Display selected file immediately after selection
            const Text('Submitted Work',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w300,
                color: Colors.white70,
              ),),
            const SizedBox(height: 5),
            // Display file information in capsule-like shape
            if (_fileInfos.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                itemCount: _fileInfos.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Image.asset(
                          _getFileIcon(_fileInfos[index].fileName),
                          fit: BoxFit.fill,
                          width: 60,
                          height: 60,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: const EdgeInsets.all(5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _fileInfos[index].fileName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${_fileInfos[index].fileSizeInMB.toStringAsFixed(2)} MB',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            if (_uploading)
              const CircularProgressIndicator(),
            // Conditionally show the submit button if not past due date and not uploading
            if (!isPastDueDate && !_uploading)
              ElevatedButton(
                style: _buttonStyle,
                onPressed: _files.isEmpty ? null : () => _uploadFile(_files.last),
                child: Text(
                  AppConstants.upload_key.tr.toUpperCase(),
                  style: _buttonTextStyle,
                ),
              )
            else
              Container(

                child: const Center(
                  child: Text(
                    textAlign: TextAlign.center,
                    "Due date has passed Contact Project Manager for Task submissions",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ),
            const Text(
              'Maximum File size Limit is 1 GB allowed (PPT, DOC/DOCX, PDF, ZIP)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }


  final _buttonStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: Colors.blue,
  );
  final _buttonStyle2 = ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: Colors.blueGrey,
  );

  final _buttonTextStyle = const TextStyle(
    color: Colors.white,
  );

  Future<void> _getImageFromGallery() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['ppt', 'pdf', 'jpg', 'jpeg', 'png', 'zip'],
      allowMultiple: true,
    );
    if (result != null) {
      String fileName = result.files.single.name;
      String fileExtension = fileName.split('.').last.toLowerCase();
      if (!['ppt', 'pdf', 'jpg', 'jpeg', 'png', 'zip']
          .contains(fileExtension)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Only PPT, PDF, JPG, JPEG, PNG, and ZIP files are allowed'),
          ),
        );
        return;
      }
      File file = File(result.files.single.path!);

      if (file.lengthSync() > 1073741824) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File size exceeds 1 GB'),
          ),
        );

        return;
      }

      setState(() {
        _files.add(file);
      });
    }
  }

  String _getFileIcon(String fileName) {
    final extension = path.extension(fileName);
    switch (extension) {
      case '.pdf':
        return 'assets/pdf.png';
      case '.doc':
      case '.docx':
        return 'assets/doc.png';
      case '.zip':
        return 'assets/zip.png';
      case '.ppt':
        return 'assets/ppt.png';
      case '.jpg':
      case '.png':
      case '.jpeg':
        return 'assets/image.png';
      default:
        return 'assets/uk.png';
    }
  }
}

class FileInfo {
  final String fileName;
  final double fileSizeInMB;
  FileInfo({required this.fileName, required this.fileSizeInMB});
}
