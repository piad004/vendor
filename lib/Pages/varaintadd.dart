import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:vendor/Components/bottom_bar.dart';
import 'package:vendor/Components/entry_field.dart';
import 'package:vendor/Locale/locales.dart';
import 'package:vendor/Themes/colors.dart';
import 'package:vendor/baseurl/baseurl.dart';
import 'package:vendor/orderbean/productbean.dart';

class AddVaraintItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    Map<String, dynamic> dataLis = ModalRoute.of(context).settings.arguments;
    dynamic productId = dataLis['productId'];
    dynamic currency = dataLis['currency'];
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: kMainColor),
        title: Text(locale.addprovariant,
            style: Theme.of(context).textTheme.bodyText1),
        titleSpacing: 0.0,
      ),
      body: AddVaraint(productId, currency),
    );
  }
}

class AddVaraint extends StatefulWidget {
  final dynamic productId;
  final dynamic currency;

  AddVaraint(this.productId, this.currency);

  @override
  State<StatefulWidget> createState() {
    return AddVaraintState();
  }
}

class AddVaraintState extends State<AddVaraint> {
  ProductBean productBean;
  dynamic currency;
  File _image;
  final picker = ImagePicker();
  TextEditingController productNameC = TextEditingController();
  TextEditingController productQuantityC = TextEditingController();
  TextEditingController productUnitC = TextEditingController();
  TextEditingController productMrpC = TextEditingController();
  TextEditingController productPriceC = TextEditingController();
  TextEditingController productDespC = TextEditingController();
  TextEditingController productStoreC = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  _imgFromCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  _imgFromGallery() async {
    picker.getImage(source: ImageSource.gallery).then((pickedFile) {
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {
          print('No image selected.');
        }
      });
    }).catchError((e) => print(e));
  }

  void _showPicker(context, AppLocalizations locale) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text(locale.photolibrary),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text(locale.Camera),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: <Widget>[
              Divider(
                color: kCardBackgroundColor,
                thickness: 6.7,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          locale.itemimg,
                          style: Theme.of(context).textTheme.headline6.copyWith(
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.67,
                              color: kHintColor),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                       // _showPicker(context,locale);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            height: 99.0,
                            width: 99.0,
                            color: kCardBackgroundColor,
                            child: _image != null
                                ? Image.file(_image)
                                : Image.asset('images/user.png'),
                          ),
                          SizedBox(width: 30.0),
                        /*  Icon(
                            Icons.camera_alt,
                            color: kMainColor,
                            size: 19.0,
                          ),
                          SizedBox(width: 14.3),
                          Text(locale.uploadpic,
                              style: Theme.of(context)
                                  .textTheme
                                  .caption
                                  .copyWith(color: kMainColor)),*/
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 25.3,
                    )
                  ],
                ),
              ),
              Divider(
                color: kCardBackgroundColor,
                thickness: 8.0,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
                child: Column(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        locale.itemcat2,
                        style: Theme.of(context).textTheme.headline6.copyWith(
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.67,
                            color: kHintColor),
                      ),
                    ),
                    EntryField(
                      textCapitalization: TextCapitalization.words,
                      label: locale.itemcat2,
                      hint: locale.itemcat21,
                      controller: productDespC,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ),
              Divider(
                color: kCardBackgroundColor,
                thickness: 8.0,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
                child: Column(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        locale.itemcat3,
                        style: Theme.of(context).textTheme.headline6.copyWith(
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.67,
                            color: kHintColor),
                      ),
                    ),
                    EntryField(
                      textCapitalization: TextCapitalization.words,
                      label: locale.itemprice1,
                      hint: locale.itemprice2,
                      controller: productPriceC,
                      keyboardType: TextInputType.number,
                    ),
                    EntryField(
                      textCapitalization: TextCapitalization.words,
                      label: locale.itemmrp1,
                      hint: locale.itemmrp2,
                      controller: productMrpC,
                      keyboardType: TextInputType.number,
                    ),
                    EntryField(
                      textCapitalization: TextCapitalization.words,
                      label: locale.itemqnt1,
                      hint: locale.itemqnt2,
                      controller: productQuantityC,
                      keyboardType: TextInputType.number,
                    ),
                    EntryField(
                      textCapitalization: TextCapitalization.words,
                      label: locale.itemunit1,
                      controller: productUnitC,
                      hint: locale.itemunit2,
                    ),
                    EntryField(
                      textCapitalization: TextCapitalization.words,
                      label: locale.stock1,
                      controller: productStoreC,
                      hint: locale.stock2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: BottomBar(
            text: locale.addpv,
            onTap: () {
              showProgressDialog(locale.addpv1, pr);
              newHitService(pr, context,locale);
            },
          ),
        )
      ],
    );
  }

  showProgressDialog(String text, ProgressDialog pr) {
    pr.style(
        message: '${text}',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));
  }

  void newHitService(ProgressDialog pr, contexts, AppLocalizations locale) async {
    if (productMrpC.text.isNotEmpty &&
        productPriceC.text.isNotEmpty &&
        productStoreC.text.isNotEmpty &&
        productUnitC.text.isNotEmpty &&
        productQuantityC.text.isNotEmpty &&
        productDespC.text.isNotEmpty) {
      SharedPreferences profilePref = await SharedPreferences.getInstance();
      var storeId = profilePref.getInt("vendor_id");
      pr.show();
      String fid = '';
      if (_image != null) {
        fid = _image.path.split('/').last;
      }
      var storeEditUrl = store_addnewvariant;
      var request = http.MultipartRequest("POST",storeEditUrl);
      request.fields["vendor_id"] = '${storeId}';
      request.fields["product_id"] = '${widget.productId}';
      request.fields["strick_price"] = '${productMrpC.text}';
      request.fields["price"] = '${productPriceC.text}';
      request.fields["stock"] = '${productStoreC.text}';
      request.fields["unit"] = '${productUnitC.text}';
      request.fields["quantity"] = '${productQuantityC.text}';
      request.fields["description"] = '${productDespC.text}';
      if (_image != null) {
        http.MultipartFile.fromPath("varient_image", _image.path, filename: fid)
            .then((pic) {
          request.files.add(pic);
          request.send().then((values) {
            values.stream.toBytes().then((value) {
              var responseString = String.fromCharCodes(value);
              print('${responseString}');
              var jsonData = jsonDecode(responseString);
              pr.hide();
              if (jsonData['status'] == "1") {
                Toast.show(locale.provaradd, contexts,
                    duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
                // productNameC.clear();
                productDespC.clear();
                productPriceC.clear();
                productMrpC.clear();
                productQuantityC.clear();
                productUnitC.clear();
                productStoreC.clear();
                setState(() {
                  _image = null;
                });
                Navigator.of(context).pop();
              } else {
                Toast.show(locale.somethingwent, contexts,
                    duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
              }
            });
          }).catchError((e) {
            print(e);
            Toast.show(locale.somethingwent, contexts,
                duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
            pr.hide();
          });
        }).catchError((e1) {
          print(e1);
          Toast.show(locale.somethingwent, contexts,
              duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
          pr.hide();
        });
      } else {
        request.fields["varient_image"] = '';
        request.send().then((values) {
          values.stream.toBytes().then((value) {
            var responseString = String.fromCharCodes(value);
            print('${responseString}');
            var jsonData = jsonDecode(responseString);
            pr.hide();
            if (jsonData['status'] == "1") {
              Toast.show(locale.provaradd, contexts,
                  duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
              // productNameC.clear();
              productDespC.clear();
              productPriceC.clear();
              productMrpC.clear();
              productQuantityC.clear();
              productUnitC.clear();
              productStoreC.clear();
              setState(() {
                _image = null;
              });
              Navigator.of(context).pop();
            } else {
              Toast.show(locale.somethingwent, contexts,
                  duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
            }
          });
        }).catchError((e) {
          print(e);
          Toast.show(locale.somethingwent, contexts,
              duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
          pr.hide();
        });
      }
    } else {
      pr.hide();
      Toast.show(locale.enterpro1, contexts,
          duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
    }
  }
}
