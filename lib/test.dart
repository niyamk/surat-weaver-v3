import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/utils.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:surat_weavers_v3/main.dart';

class TestingScreen extends StatefulWidget {
  const TestingScreen(
      {required this.companyName,
      required this.gstNo,
      required this.mobile,
      required this.address,
      required this.rating});

  final String companyName;
  final String gstNo;
  final String mobile;
  final String address;
  final double rating;
  @override
  State<TestingScreen> createState() => _TestingScreenState();
}

late String currentGstNo;
var _data;

class _TestingScreenState extends State<TestingScreen> {
  double mainRating = 0;
  TextEditingController commentController = TextEditingController();
  @override
  void initState() {
    mainRating = widget.rating;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: BackButton(),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        width: 100.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            Text(
              widget.companyName,
              style: TextStyle(fontSize: 20),
            ),
            Text(
              widget.gstNo,
              style: TextStyle(fontSize: 20),
            ),
            Text(
              widget.mobile,
              style: TextStyle(fontSize: 20),
            ),
            Text(
              widget.address,
              style: TextStyle(fontSize: 20),
            ),
            RatingBar.builder(
              allowHalfRating: true,
              glow: false,
              initialRating: mainRating,
              itemBuilder: (context, index) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (double value) {
                log(value.toString());
                setState(() {
                  mainRating = value;
                });
              },
            ),
            ElevatedButton(
                onPressed: () async {
                  var ref = await FirebaseFirestore.instance
                      .collection("rating")
                      .doc(widget.gstNo)
                      .get();
                  List comments = ref['comments'] ?? [];
                  comments.add({
                    'who commented': widget.gstNo,
                    'comment': commentController.text.trim() == ''
                        ? '-no comment'
                        : commentController.text.trim(),
                    'rating star': mainRating,
                    'date of edit': DateFormat('dd-MM-yyyy')
                        .format(DateTime.now())
                        .toString(),
                  });
                  await FirebaseFirestore.instance
                      .collection('rating')
                      .doc(widget.gstNo)
                      .update({'comments': comments});
                },
                child: Text("Save")),
            TextField(
              controller: commentController,
              maxLines: 4,
              minLines: 1,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'comment (optional)',
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    width: 2,
                    color: PhoenixThemeColor(),
                  ),
                ),
              ),
            ),
            Text(" ---- Rate and Reviews ---- "),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('rating')
                  .doc(widget.gstNo)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var data = snapshot.data!['comments'] ?? [];
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text("${data[index]['comment']}"),
                      );
                    },
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  onEdit() {
    FocusManager.instance.primaryFocus?.unfocus();
    final editTextController = TextEditingController();
    List typeList = ['Company Name', 'Address', 'Mobile no.'];
    List adminTypeList = [
      'party_company_name',
      'party_address',
      'party_mobile'
    ];
    List typeListWithDetails = [
      widget.companyName,
      widget.address,
      widget.mobile
    ];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select what you want to edit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Company Name :- ${widget.companyName}'),
              Text('Current Address :- ${widget.address}'),
              Text('Current Mobile no. :- ${widget.mobile}'),
              SizedBox(height: 10),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  typeList.length,
                  (index) => GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Enter correct ${typeList[index]}'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                /*Text(
                                                        'Old ${typeList[index]} :- ${typeListWithDetails[index]}'),*/
                                SizedBox(height: 10),
                                TextField(
                                  controller: editTextController,
                                  decoration:
                                      InputDecoration(hintText: 'enter here'),
                                ),
                              ],
                            ),
                            actions: [
                              OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('cancel')),
                              OutlinedButton(
                                  onPressed: () async {
                                    // log('${editTextController.text.trim() == typeListWithDetails[index]}');
                                    if (editTextController.text.isNotEmpty) {
                                      // launch(
                                      //     'https://wa.me/+91 9727872141?text= { ${widget.gstNo} } *${typeList[index]}* OLD ~${typeListWithDetails[index]}~ - *NEW* _${editTextController.text}_');

                                      await FirebaseFirestore.instance
                                          .collection('EditRequest')
                                          .doc(
                                              '${currentGstNo}-${widget.gstNo}')
                                          .set({
                                        'editor': currentGstNo,
                                        'being edited': widget.gstNo,
                                        'type_of_edit': adminTypeList[index],
                                        'old_entry': typeListWithDetails[index],
                                        'new_entry':
                                            editTextController.text.trim(),
                                      });
                                    }
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: Text('Send Request')),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        border:
                            Border.all(color: PhoenixThemeColor(), width: 2),
                      ),
                      child: ListTile(
                        title: Text(
                          typeList[index],
                        ),
                        trailing: Icon(Icons.arrow_forward_ios_sharp),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('cancel'))
          ],
        );
      },
    );
  }
}
