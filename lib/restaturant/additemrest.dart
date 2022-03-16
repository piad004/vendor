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
import 'package:vendor/Pages/SearchItemModel.dart';
import 'package:vendor/Routes/routes.dart';
import 'package:vendor/Themes/colors.dart';
import 'package:vendor/baseurl/baseurl.dart';
import 'package:vendor/orderbean/productbean.dart';
import 'package:vendor/orderbean/subcatbean.dart';
import 'package:vendor/restaturant/UnitModel.dart';

class AddItemRest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: kMainColor),
        title:
            Text(locale.addproduct, style: Theme.of(context).textTheme.bodyText1),
        titleSpacing: 0.0,
      ),
      body: AddRest(),
    );
  }
}

class AddRest extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddRestState();
  }
}

class AddRestState extends State<AddRest> {
  ProductBean productBean;
  dynamic currency;
  CategoryRestList subCatString;
  UnitModel unitModel;
  List<CategoryRestList> subCatList = [];
  List<UnitModel> unitType = [];
  bool _unitselected = false;
  var unit='';

  List<SearchItemModel> searchList = [];
  SearchItemModel product;
  // CategoryList catString;
  // List<CategoryList> catList = [];
  File _image;
  final picker = ImagePicker();
  TextEditingController productNameC = TextEditingController();
  TextEditingController productQuantityC = TextEditingController();
  TextEditingController productUnitC = TextEditingController();
  TextEditingController productMrpC = TextEditingController();
  TextEditingController productPriceC = TextEditingController();
  TextEditingController productDespC = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController productCat = TextEditingController();
  TextEditingController productSubCat = TextEditingController();

  // TextEditingController productStoreC = TextEditingController();

  AddRestState() {
    subCatString = CategoryRestList('', '', '', '');
    subCatList.add(subCatString);
  }

  @override
  void initState() {
    getSubCategory();
    getUnit();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    clearProduct();
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

  void getSubCategory() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    // setState(() {
    //   curency = pref.getString('curency');
    // });
    var vendorId = pref.getInt('vendor_id');
    var client = http.Client();
    var todayOrderUrl = resturant_category;
    client
        .post(todayOrderUrl, body: {'vendor_id': '${vendorId}'}).then((value) {
      print('${value.body}');
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var jsonList = jsonData['data'] as List;
          List<CategoryRestList> catList =
              jsonList.map((e) => CategoryRestList.fromJson(e)).toList();
          if (catList.length > 0) {
            setState(() {
              subCatList.clear();
              subCatList = List.from(catList);
              subCatString = subCatList[0];
            });
          }
        }
      }
    }).catchError((e) => print(e));
  }

  void getUnit() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    // setState(() {
    //   curency = pref.getString('curency');
    // });
    var uiType = pref.getString('ui_type');
    var client = http.Client();
    var url = unitList;
    client
        .post(url, body: {'vendor_ui_type': '${uiType}'}).then((value) {
      print('unit ${value.body}');
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body) as List;
          List<UnitModel> catList =
          jsonData.map((e) => UnitModel.fromJson(e)).toList();
          if (catList.length > 0) {
            setState(() {
              unitType.clear();
              unitType = List.from(catList);
              //subCatString = subCatList[0];
            });
        }
      }
    }).catchError((e) => print(e));
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
                thickness: 8.0,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
                child: Column(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        locale.iteminfo,
                        style: Theme.of(context).textTheme.headline6.copyWith(
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.67,
                            color: kHintColor),
                      ),
                    ),
                    EntryField(
                      textCapitalization: TextCapitalization.words,
                      label: locale.itemtitle1,
                      hint: locale.itemtitle2,
                      controller: productNameC,
                      readOnly: true,
                      onTap: () {
                        Navigator.pushNamed(context, PageRoutes.searchItem).then((_) {
                          getProduct();
                        });
                      },
                    ),
                    // EntryField(
                    //   textCapitalization: TextCapitalization.words,
                    //   label: 'ITEM CATEGORY',
                    //   hint: 'Select Item Category',
                    // ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locale.itemcat,
                            style: TextStyle(fontSize: 13, color: kHintColor),
                          ),
                          EntryField(
                            textCapitalization: TextCapitalization.words,
                            label: 'Item category',
                            hint: 'Item category',
                            controller: productCat,
                            readOnly: true,
                          ),
                         /* DropdownButton<CategoryRestList>(
                            isExpanded: true,
                            value: subCatString,
                            underline: Container(
                              height: 1.0,
                              color: kMainTextColor,
                            ),
                            items: subCatList.map((values) {
                              return DropdownMenuItem<CategoryRestList>(
                                value: values,
                                child: Text(values.cat_name),
                              );
                            }).toList(),
                            onChanged: (area) {
                              setState(() {
                                subCatString = area;
                              });
                            },
                          )*/
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
                            child:
                    _image != null
                                ? product!=null?Image.network(
                              imageBaseUrl + product.productImage,
                              //product.productImage,
                              fit: BoxFit.fill,
                            ):Image.file(_image)
                                : Image.asset('images/user.png'),
                          ),
                         /* SizedBox(width: 30.0),
                          Icon(
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
                    // EntryField(
                    //   textCapitalization: TextCapitalization.words,
                    //   label: 'ITEM CATEGORY',
                    //   hint: 'Select Item Category',
                    // ),
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
                    /* DropdownButton(
                            isExpanded: true,
                          value: _unitselected==true?unit:null,
                            underline: Container(
                              height: 1.0,
                              color: kMainTextColor,
                            ),
                            items: unitType.map((values) {
                              return DropdownMenuItem<UnitModel>(
                                value: values,
                                child: Text(values.name,
                                  style: const TextStyle(color: Colors.black),
                              ));
                            }).toList(),
                       hint: Text(
                         "Select Unit",
                         style: TextStyle(
                             color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                       ),
                            onChanged: (area) {
                              setState(() {
                                unit = area.name;
                                _unitselected=true;
                              });
                            },
                          )*/
                  ],
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: BottomBar(
            text: locale.addproduct,
            onTap: () {
              showProgressDialog(locale.pw1, pr);
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

  void newHitService(ProgressDialog pr, BuildContext context, AppLocalizations locale) async {
    if (productNameC.text.isNotEmpty &&
        productMrpC.text.isNotEmpty &&
        productPriceC.text.isNotEmpty &&
        productUnitC.text.isNotEmpty &&
        productQuantityC.text.isNotEmpty &&
        productUnitC.text.isNotEmpty&&
        productDespC.text.isNotEmpty) {
      SharedPreferences profilePref = await SharedPreferences.getInstance();
      var storeId = profilePref.getInt("vendor_id");
      pr.show();

      var url = resturant_addnewproduct;
      http.post(url, body: {
        "vendor_id": storeId.toString(),
        "subcat_id": product.subcatId.toString(),
        "product_id": product.productId.toString(),
        "product_name": productNameC.text,
        "mrp": productMrpC.text,
        "price": productPriceC.text,
        "unit": productUnitC.text,
        //"unit": unit,
        "quantity": productQuantityC.text,
        "product_description": productDespC.text,
        //"product_image": '',
      }).then((response) {
        if (response.statusCode == 200) {
          var jsonData = jsonDecode(response.body);
          if (jsonData['status'] == "1") {
            Toast.show(locale.productadd, context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
            productNameC.clear();
            productDespC.clear();
            productPriceC.clear();
            productMrpC.clear();
            productQuantityC.clear();
            productUnitC.clear();
            productCat.clear();
            // productStoreC.clear();
            setState(() {
              _image = null;
              product = null;
            });
            pr.hide();
          } else {
            Toast.show(jsonData['message'], context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
            pr.hide();
          }
        } else {

          var jsonData = jsonDecode(response.body);
          Toast.show(locale.somethingwent, context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
          pr.hide();

        }

      }).catchError((e) {

        Toast.show(locale.somethingwent, context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
        pr.hide();
      });

  }
  }

/*
  void newHitService(ProgressDialog pr, BuildContext context, AppLocalizations locale) async {
    print('${subCatString.resturant_cat_id}');
    if (productNameC.text.isNotEmpty &&
        productMrpC.text.isNotEmpty &&
        productPriceC.text.isNotEmpty &&
        productUnitC.text.isNotEmpty &&
        productQuantityC.text.isNotEmpty &&
        productDespC.text.isNotEmpty) {
      SharedPreferences profilePref = await SharedPreferences.getInstance();
      var storeId = profilePref.getInt("vendor_id");
      pr.show();
      String fid = _image.path.split('/').last;
      var storeEditUrl = resturant_addnewproduct;
      var request = http.MultipartRequest("POST", storeEditUrl);
      request.fields["vendor_id"] = '${storeId}';
      //request.fields["subcat_id"] = '${subCatString.resturant_cat_id}';
      request.fields["subcat_id"] = '${product.subcatId}';
      request.fields["product_id"] = '${product.productId}';
      request.fields["product_name"] = '${productNameC.text}';
      request.fields["mrp"] = '${productMrpC.text}';
      request.fields["price"] = '${productPriceC.text}';
      request.fields["unit"] = '${productUnitC.text}';
      request.fields["quantity"] = '${productQuantityC.text}';
      request.fields["product_description"] = '${productDespC.text}';
      http.MultipartFile.fromPath("product_image", _image.path, filename: fid)
          .then((pic) {
       request.files.add(pic);
        request.send().then((values) {
         values.stream.toBytes().then((value) {
            var responseString = String.fromCharCodes(value);
            print('${responseString}');
            var jsonData = jsonDecode(responseString);
            if (jsonData['status'] == "1") {
              Toast.show(locale.productadd, context,
                  duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
              productNameC.clear();
              productDespC.clear();
              productPriceC.clear();
              productMrpC.clear();
              productQuantityC.clear();
              productUnitC.clear();
              productCat.clear();
              // productStoreC.clear();
              setState(() {
                _image = null;
              });
            } else {
              Toast.show(jsonData['message'], context,
                  duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
            }
          }).catchError((e) {
            print(e);
            Toast.show(locale.somethingwent, context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
            pr.hide();
          });
          pr.hide();
        }).catchError((e) {
          print(e);
          Toast.show(locale.somethingwent, context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
          pr.hide();
        });
      }).catchError((e1) {
        print(e1);
        Toast.show(locale.somethingwent, context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
        pr.hide();
      });
    } else {
      Toast.show(locale.addprodetail, context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
      pr.hide();
    }
  }
*/


  Future<void> getProduct() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    Map json = jsonDecode(pref.getString('product'));
    setState(() {
      product = SearchItemModel.fromJson(json);
      productNameC.text=product.productName;
      productCat.text=product.categoryName;
      productSubCat.text=product.subcatName;
       _image = File(product.productImage);

    });
  }

  Future<void> clearProduct() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('product','');
  }
}
