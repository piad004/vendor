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
import 'package:vendor/Pages/SearchItemModel.dart';
import 'package:vendor/Pages/SearchItem.dart';
import 'package:vendor/Components/bottom_bar.dart';
import 'package:vendor/Components/entry_field.dart';
import 'package:vendor/Locale/locales.dart';
import 'package:vendor/Routes/routes.dart';
import 'package:vendor/Themes/colors.dart';
import 'package:vendor/baseurl/baseurl.dart';
import 'package:vendor/orderbean/categorybean.dart';
import 'package:vendor/orderbean/productbean.dart';
import 'package:vendor/orderbean/subcartbean.dart';

class AddItem extends StatelessWidget {
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
      body: Add(),
    );
  }
}

class Add extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddState();
  }
}

class AddState extends State<Add> {
  ProductBean productBean;
  dynamic currency;
  SubCategoryList subCatString;
  List<SubCategoryList> subCatList = [];
  CategoryList catString;
  List<CategoryList> catList = [];
  List<SearchItemModel> searchList = [];
  SearchItemModel product;
  File _image;
  bool isFetch = false;
  final picker = ImagePicker();
  TextEditingController productNameC = TextEditingController();
  TextEditingController productQuantityC = TextEditingController();
  TextEditingController productUnitC = TextEditingController();
  TextEditingController productMrpC = TextEditingController();
  TextEditingController productPriceC = TextEditingController();
  TextEditingController productDespC = TextEditingController();
  TextEditingController productStoreC = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController productCat = TextEditingController();
  TextEditingController productSubCat = TextEditingController();

  AddState() {
    catString = CategoryList('', '', '', '', '', '', '', '');
    catList.add(catString);
    subCatString = SubCategoryList('', '', '', '', '', '');
    subCatList.add(subCatString);
  }

  @override
  void initState() {
    getCategoryList();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    clearProduct();
  }

  void getCategoryList() async {
    SharedPreferences profilePref = await SharedPreferences.getInstance();
    var storeId = profilePref.getInt("vendor_id");
    var catUrl = store_category;
    var client = http.Client();
    client.post(catUrl, body: {'vendor_id': '${storeId}'}).then((value) {
      print('${value.body}');
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        var jsonList = jsonData['data'] as List;
        List<CategoryList> catbean =
            jsonList.map((e) => CategoryList.fromJson(e)).toList();
        if (catbean.length > 0) {
          catList.clear();
          setState(() {
            catString = catbean[0];
            catList = List.from(catbean);
          });
          getSubCategoryList(catList[0].category_id);
        }
      }
    }).catchError((e) {
      print(e);
    });
  }

  void getSubCategoryList(catId) async {
    var catUrl = store_subcategory;
    var client = http.Client();
    client.post(catUrl, body: {'category_id': '${catId}'}).then((value) {
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        var jsonList = jsonData['data'] as List;
        List<SubCategoryList> catbean =
            jsonList.map((e) => SubCategoryList.fromJson(e)).toList();
        if (catbean.length > 0) {
          subCatList.clear();
          setState(() {
            subCatString = catbean[0];
            subCatList = List.from(catbean);
          });
        }
      }
    }).catchError((e) {
      print(e);
    });
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

                      /*  Navigator.push(
                            context, MaterialPageRoute(builder: (context) => SearchItem()));*/
                        //showItemList(context,"Search item");
                      },
                    ),
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
                          /*DropdownButton<CategoryList>(
                            isExpanded: true,
                            value: catString,
                            underline: Container(
                              height: 1.0,
                              color: kMainTextColor,
                            ),
                            items: catList.map((values) {
                              return DropdownMenuItem<CategoryList>(
                                value: values,
                                child: Text(values.category_name),
                              );
                            }).toList(),
                            onChanged: (area) {
                              setState(() {
                                catString = area;
                              });
                              getSubCategoryList(area.category_id);
                            },
                          )*/
                          EntryField(
                            textCapitalization: TextCapitalization.words,
                            label: 'Item category',
                            hint: 'Item category',
                            controller: productCat,
                            readOnly: true,
                          ),
                        ],
                      ),
                    ),
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
                            locale.itemcat1,
                            style: TextStyle(fontSize: 13, color: kHintColor),
                          ),
                          /*DropdownButton<SubCategoryList>(
                            value: subCatString,
                            isExpanded: true,
                            underline: Container(
                              height: 1.0,
                              color: kMainTextColor,
                            ),
                            items: subCatList.map((values) {
                              return DropdownMenuItem<SubCategoryList>(
                                value: values,
                                child: Text(values.subcat_name),
                              );
                            }).toList(),
                            onChanged: (area) {
                              setState(() {
                                subCatString = area;
                              });
                            },
                          )*/
                          EntryField(
                            textCapitalization: TextCapitalization.words,
                            label: 'Item sub category',
                            hint: 'Item sub category',
                            controller: productSubCat,
                            readOnly: true,
                          ),
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
                        //_showPicker(context,locale);
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
                                ? product!=null?Image.network(
                              imageBaseUrl + product.productImage,
                              fit: BoxFit.fill,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image(
                                    image: AssetImage(
                                        'images/logos/logo_store.png'),
                                    height: 93.3,
                                    width: 93.3,
                                  ),
                            ):Image.file(_image)
                                : Image.asset('images/logos/logo_store.png'),
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
            text: locale.addproduct,
            onTap: () {
              showProgressDialog(locale.pw1, pr,locale);
              newHitService(pr, context,locale);
            },
          ),
        )
      ],
    );
  }


  showItemList(BuildContext context, String messageData) {
    // set up the buttons
    Widget remindButton = FlatButton(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Text(""),
      onPressed: () {
        //Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('$messageData'),
      content: Text(''),
      actions: [
        /*remindButton,*/
        Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.9,
                height: 48,
                padding: EdgeInsets.only(left: 5),
                decoration: BoxDecoration(
                    color: kWhiteColor, borderRadius: BorderRadius.circular(5)),
                child: TextFormField(
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.search,
                      color: kHintColor,
                    ),
                    //hintText: locale.searchStoreText,
                    hintText: "Search item",
                  ),
                  controller: searchController,
                  cursorColor: kMainColor,
                  autofocus: false,
                  onChanged: (value) {
                                hitSearchItem(value);
                  },
                ),
              ),
              Container(
                //height: MediaQuery.of(context).size.height - 200,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      (searchList != null && searchList.length > 0)
                          ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: ListView.separated(
                            shrinkWrap: true,
                            primary: false,
                            scrollDirection: Axis.vertical,
                            itemCount: searchList.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Material(
                                  elevation: 2,
                                  shadowColor: white_color,
                                  clipBehavior: Clip.hardEdge,
                                  borderRadius: BorderRadius.circular(10),
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width,
                                        color: white_color,
                                        padding: EdgeInsets.only(
                                            left: 20.0, top: 15, bottom: 15),
                                        child: Row(
                                          children: <Widget>[
                                            Container(
                                              width: 93.3,
                                              height: 93.3,
                                              child: Image.network( imageBaseUrl +
                                                    searchList[index]
                                                        .productImage,
                                                width: 93.3,
                                                height: 93.3,
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                            SizedBox(width: 13.3),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                     searchList[index]
                                                          .productName,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle2
                                                          .copyWith(
                                                          color:
                                                          kMainTextColor,
                                                          fontSize: 18)),
                                                  SizedBox(height: 8.0),
                                                  Row(
                                                    children: <Widget>[
                                                      Icon(
                                                        Icons
                                                            .shopping_bag_outlined,
                                                        color: kIconColor,
                                                        size: 15,
                                                      ),
                                                      SizedBox(width: 5.0),
                                                      Expanded(
                                                        child: Text(
                                                            'Store - ${searchList[index].categoryName}',
                                                            maxLines: 2,
                                                            style: Theme.of(
                                                                context)
                                                                .textTheme
                                                                .caption
                                                                .copyWith(
                                                                color:
                                                                kLightTextColor,
                                                                fontSize:
                                                                13.0)),
                                                      ),
                                                      Text(' |   ',
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .caption
                                                              .copyWith(
                                                              color:
                                                              kMainColor,
                                                              fontSize:
                                                              13.0)),
                                                      Expanded(
                                                        child: Text(
                                                            '${searchList[index].categoryName}',
                                                            maxLines: 2,
                                                            style: Theme.of(
                                                                context)
                                                                .textTheme
                                                                .caption
                                                                .copyWith(
                                                                color:
                                                                kLightTextColor,
                                                                fontSize:
                                                                13.0)),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 6),

                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return SizedBox(
                                height: 10,
                              );
                            }),
                      )
                          : Container(
                        height: MediaQuery.of(context).size.height / 2,
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            isFetch
                                ? CircularProgressIndicator()
                                : Container(
                              width: 0.5,
                            ),
                            isFetch
                                ? SizedBox(
                              width: 10,
                            )
                                : Container(
                              width: 0.5,
                            ),
                            Text(
                              (!isFetch) ? "No data found!" : "Searching...",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: kMainTextColor),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showProgressDialog(String text, ProgressDialog pr, AppLocalizations locale) {
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

  void hitSearchItem(var searchValue) async {
    SharedPreferences profilePref = await SharedPreferences.getInstance();
    var storeId = profilePref.getInt("vendor_id");

    var url = search_product;
    http.post(url, body: {
      "keyword": '${searchValue.toString()}',
      "vendor_category_id": '13',
    }).then((response) {
      if (response.statusCode == 200) {
        var ab = response.body;
        var jsonData = jsonDecode(response.body);

        //if (jsonData['status'] == "1") {
        var tagObjsJson = jsonDecode(response.body) as List;
        List<SearchItemModel> tagObjs =
        tagObjsJson.map((tagJson) => SearchItemModel.fromJson(tagJson)).toList();

        if (tagObjs.isNotEmpty) {
          setState(() {
            searchList.clear();
            searchList = tagObjs;
          });
        }
      } else {


      }

    }).catchError((e) {

    });
  }


  void newHitService(ProgressDialog pr, BuildContext context, AppLocalizations locale) async {
    if (productNameC.text.isNotEmpty &&
        productMrpC.text.isNotEmpty &&
        productPriceC.text.isNotEmpty &&
        productUnitC.text.isNotEmpty &&
        productQuantityC.text.isNotEmpty &&
        productStoreC.text.isNotEmpty &&
        productDespC.text.isNotEmpty) {
      SharedPreferences profilePref = await SharedPreferences.getInstance();
      var storeId = profilePref.getInt("vendor_id");
      pr.show();

      var url = store_addnewproduct;
      http.post(url, body: {
        "vendor_id": storeId.toString(),
        "subcat_id": product.subcatId.toString(),
        "cat_id": product.categoryId.toString(),
        "product_id": product.productId.toString(),
        "product_name": productNameC.text,
        "strick_price": productMrpC.text,
        "price": productPriceC.text,
        "stock": productStoreC.text,
        "unit": productUnitC.text,
        "quantity": productQuantityC.text,
        "description": productDespC.text,
      }).then((response) {
        var jsonData = jsonDecode(response.body);
        if (response.statusCode == 200) {
          var jsonData = jsonDecode(response.body);
          if (jsonData['status'] == "1") {
            Toast.show(jsonData['message'], context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
            productNameC.clear();
            productDespC.clear();
            productPriceC.clear();
            productMrpC.clear();
            productQuantityC.clear();
            productUnitC.clear();
            productStoreC.clear();
            productCat.clear();
            productSubCat.clear();
            setState(() {
              _image = null;
            });
          } else {
            Toast.show(jsonData['message'], context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
          }
          clearProduct();
        }
        else{
        Toast.show(locale.somethingwent, context,
        duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
        }
        pr.hide();
      }).catchError((e) {
        print(e);
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

  /*void newHitService(ProgressDialog pr, BuildContext context, AppLocalizations locale) async {
    if (productMrpC.text.isNotEmpty &&
        productPriceC.text.isNotEmpty &&
        productStoreC.text.isNotEmpty &&
        productUnitC.text.isNotEmpty &&
        productQuantityC.text.isNotEmpty &&
        productDespC.text.isNotEmpty) {
      SharedPreferences profilePref = await SharedPreferences.getInstance();
      var storeId = profilePref.getInt("vendor_id");
      pr.show();
      String fid = _image.path.split('/').last;
      var storeEditUrl = store_addnewproduct;
      var request = http.MultipartRequest("POST",storeEditUrl);
      request.fields["vendor_id"] = '${storeId}';
      //request.fields["subcat_id"] = '${subCatString.subcat_id}';
      request.fields["subcat_id"] = '${product.subcatId}';
      request.fields["cat_id"] = '${product.categoryId}';
      request.fields["product_id"] = '${product.productId}';
      request.fields["product_name"] = '${productNameC.text}';
      request.fields["strick_price"] = '${productMrpC.text}';
      request.fields["price"] = '${productPriceC.text}';
      request.fields["stock"] = '${productStoreC.text}';
      request.fields["unit"] = '${productUnitC.text}';
      request.fields["quantity"] = '${productQuantityC.text}';
      request.fields["description"] = '${productDespC.text}';
      http.MultipartFile.fromPath("product_image", _image.path, filename: fid)
          .then((pic) {
        //request.files.add(pic);
        request.send().then((values) {
          values.stream.toBytes().then((value) {
            var responseString = String.fromCharCodes(value);
            var jsonData = jsonDecode(responseString);
            if (jsonData['status'] == "1") {
              Toast.show(jsonData['message'], context,
                  duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
              productNameC.clear();
              productDespC.clear();
              productPriceC.clear();
              productMrpC.clear();
              productQuantityC.clear();
              productUnitC.clear();
              productStoreC.clear();
              productCat.clear();
              productSubCat.clear();
              setState(() {
                _image = null;
              });
            } else {
              Toast.show(jsonData['message'], context,
                  duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
            }
            clearProduct();
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
  }*/

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
