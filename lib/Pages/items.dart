import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:vendor/Components/custom_appbar.dart';
import 'package:vendor/Locale/locales.dart';
import 'package:vendor/Routes/routes.dart';
import 'package:vendor/Themes/colors.dart';
import 'package:vendor/Themes/style.dart';
import 'package:vendor/baseurl/baseurl.dart';
import 'package:vendor/orderbean/productbean.dart';
import 'package:vendor/orderbean/subcatbean.dart';

class ItemsPage extends StatefulWidget {
  @override
  _ItemsPageState createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage>
    with TickerProviderStateMixin {
  List<DropdownMenuItem<VarientList>> listDrop = [];
  List<ProductBean> productList = [];
  int selected = null;
  dynamic curency;

  List<SubcategoryList> subCatList = [];
  List<Tab> tabs = <Tab>[];
  TabController tabController;

  var value = 0;

  dynamic isFetch = false;
  dynamic isDelete = false;
  bool isSearchOpen = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    getSubCategory();
    super.initState();
  }

  void getSubCategory() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      isFetch = true;
      curency = pref.getString('curency');
    });
    var vendorId = pref.getInt('vendor_id');
    var client = http.Client();
    var todayOrderUrl = store_subcategoryall;
    client
        .post(todayOrderUrl, body: {'vendor_id': '${vendorId}'}).then((value) {
      print('${value.body}');
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var jsonList = jsonData['data'] as List;
          List<SubcategoryList> catList =
              jsonList.map((e) => SubcategoryList.fromJson(e)).toList();
          if (catList.length > 0) {
            List<Tab> tabss = <Tab>[];
            setState(() {
              for (SubcategoryList li in catList) {
                tabss.add(Tab(
                  text: '${li.subcat_name}',
                ));
              }
              tabs.clear();
              tabs = tabss;
              tabController = TabController(length: tabs.length, vsync: this);
              tabController.addListener(() {
                if (!tabController.indexIsChanging) {
                  productListM(subCatList[tabController.index].subcat_id);
                }
              });
              subCatList = List.from(catList);
            });
            productListM(subCatList[0].subcat_id);
          }
        }
      }
      setState(() {
        isFetch = false;
      });
    }).catchError((e) => {
              if (subCatList != null && subCatList.length > 0)
                productListM(subCatList[tabController.index].subcat_id),
              print(e),
              setState(() {
                isFetch = false;
              })
            });
  }

  void productListM(catid) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      isFetch = true;
      curency = pref.getString('curency');
      productList.clear();
    });
    var vendorId = pref.getInt('vendor_id');
    var client = http.Client();
    var storeProduct = store_subcategoryproduct;
    client.post(storeProduct, body: {
      'vendor_id': '${vendorId}',
      'subcat_id': '${catid}'
    }).then((value) {
      print('${value.body}');
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body) as List;
        List<ProductBean> listBean =
            jsonData.map((e) => ProductBean.fromJson(e)).toList();
        if (listBean.length > 0) {
          setState(() {
            productList = List.from(listBean);
          });
        }
      }
      setState(() {
        isFetch = false;
      });
    }).catchError((e) {
      setState(() {
        isFetch = false;
      });
    });
  }

  void productSearch(catid, keyword) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      isFetch = true;
      curency = pref.getString('curency');
      productList.clear();
    });
    var vendorId = pref.getInt('vendor_id');
    var client = http.Client();
    var storeProduct = store_subcategoryproduct;
    client.post(storeProduct, body: {
      'keyword': '${keyword}',
      'vendor_id': '${vendorId}',
      'subcat_id': '${catid}'
    }).then((value) {
      print('${value.body}');
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body) as List;
        List<ProductBean> listBean =
        jsonData.map((e) => ProductBean.fromJson(e)).toList();
        if (listBean.length > 0) {
          setState(() {
            productList = List.from(listBean);
          });
        }
      }
      setState(() {
        isFetch = false;
      });
    }).catchError((e) {
      setState(() {
        isFetch = false;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100.0),
          child: CustomAppBar(
            titleWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Visibility(
                    visible: isSearchOpen,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 27,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 52,
                          padding: EdgeInsets.only(left: 5),
                          decoration: BoxDecoration(
                            color: scaffoldBgColor,
                            // borderRadius: BorderRadius.circular(50)
                          ),
                          child: TextFormField(
                            controller: searchController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.search,
                                color: kHintColor,
                              ),
                              hintText: 'Search product...',
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isSearchOpen = false;
                                    searchController.clear();
                                  });
                                  /* Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        //builder: (context) => SearchPage('["shop"]',categoryLists[0].vendor_id)))
                                          builder: (context) => SearchPage('["all"]',uiType,vendorCategoryId,vendor_id.toString(),'')))
                                      .then((value) {
                                    getCartCount();
                                  });*/
                                },
                                icon: Icon(
                                  Icons.close,
                                  color: kHintColor,
                                ),
                              ),
                            ),
                            cursorColor: kMainColor,
                            autofocus: false,
                            onChanged: (value) {
                              productSearch(
                                  subCatList[tabController.index]
                                      .subcat_id,
                                  value);
                              setState(() {
                                /* categoryLists = categoryListsSearch
                                    .where((element) => element.category_name
                                    .toString()
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                    .toList();*/
                              });
                            },
                          ),
                        )
                      ],
                    )),
                Center(
                    child: Text(
                  locale.myproduct,
                  style: TextStyle(color: kMainTextColor),
                )),
              ],
            ),
            actions: <Widget>[
              Visibility(
                  visible: (isSearchOpen) ? false : true,
                  child: Row(children: [
                    IconButton(
                        icon: Icon(
                          Icons.search,
                          color: kMainColor,
                        ),
                        onPressed: () {
                          setState(() {
                            isSearchOpen = true;
                            searchController.clear();
                          });
                        }),
                    IconButton(
                        icon: Icon(
                          Icons.refresh,
                          color: kMainColor,
                        ),
                        onPressed: () {
                          getSubCategory();
                        }),
                  ])),
             /* IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: kMainColor,
                  ),
                  onPressed: () {
                    *//* if(subCatList!=null && tabController!=null)
                    productListM(subCatList[tabController.index].subcat_id);
                    else*//*
                    getSubCategory();
                  }),*/
            ],
            bottom: TabBar(
              controller: tabController,
              tabs: tabs,
              isScrollable: true,
              labelColor: kMainColor,
              unselectedLabelColor: kLightTextColor,
            ),
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  flex: 9,
                  child: TabBarView(
                    controller: tabController,
                    children: tabs.map((tab) {
                      return (productList != null && productList.length > 0)
                          ? ListView.separated(
                              itemCount: productList.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    /*Navigator.pushNamed(
                                        context, PageRoutes.editItem,
                                        arguments: {
                                          'selectedItem': productList[index],
                                          'currency': curency
                                        }).then((value) {
                                      productListM(
                                          subCatList[tabController.index]
                                              .subcat_id);
                                    });*/
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Stack(
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 20.0,
                                                top: 30.0,
                                                right: 14.0),
                                            child: GestureDetector(
                                              onTap: (){
                                                Navigator.pushNamed(
                                                    context, PageRoutes.editItem,
                                                    arguments: {
                                                      'selectedItem': productList[index],
                                                      'currency': curency
                                                    }).then((value) {
                                                  productListM(
                                                      subCatList[tabController.index]
                                                          .subcat_id);
                                                });
                                              },
                                              child: (productList != null &&
                                                    productList.length > 0)
                                                ? Image.network(
                                                    imageBaseUrl +
                                                        productList[index]
                                                            .product_image,
//                                scale: 2.5,
                                                    height: 93.3,
                                                    width: 93.3,
                                                errorBuilder: (context, error, stackTrace) => Image(
                                                  image: AssetImage(
                                                      'images/logos/logo_store.png'),
                                                  height: 93.3,
                                                  width: 93.3,
                                                ),
                                                  )
                                                : Image(
                                                    image: AssetImage(
                                                        'images/logos/logo_store.png'),
                                                    height: 93.3,
                                                    width: 93.3,
                                                  ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 8,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 20),
                                                        child: Text(
                                                            productList[index]
                                                                .product_name,
                                                            maxLines: 2,
                                                            style:
                                                                bottomNavigationTextStyle
                                                                    .copyWith(
                                                                        fontSize:
                                                                            13)),
                                                      ),
                                                      SizedBox(
                                                        height: 8.0,
                                                      ),
                                                      Text(
                                                          '$curency ${(productList[index].varient_details != null && productList[index].varient_details.length > 0) ? productList[index].varient_details[productList[index].selectedItem].price : 0}',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .caption),
                                                      SizedBox(
                                                        height: 20.0,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.pushNamed(
                                                            context,
                                                            PageRoutes
                                                                .addVaraintItem,
                                                            arguments: {
                                                              'productId':
                                                                  productList[
                                                                          index]
                                                                      .product_id,
                                                              'currency':
                                                                  curency
                                                            }).then((value) {
                                                          productListM(subCatList[
                                                                  tabController
                                                                      .index]
                                                              .subcat_id);
                                                        });
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    10.0,
                                                                vertical: 10),
                                                        margin: EdgeInsets.only(
                                                            left: 5.0,
                                                            right: 10),
                                                        decoration: BoxDecoration(
                                                            color: kMainColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            50))),
                                                        child: Text(
                                                          locale.addvariant,
                                                          style: TextStyle(
                                                              fontSize: 10.0,
                                                              color:
                                                                  kWhiteColor),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 15,
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        showAlertDialog(
                                                            context,
                                                            (productList[index]
                                                                            .varient_details !=
                                                                        null &&
                                                                productList[index]
                                                                    .varient_details.isNotEmpty &&
                                                                    productList[index]
                                                                            .varient_details
                                                                            .length >
                                                                        1)
                                                                ? productList[
                                                                        index]
                                                                    .varient_details[
                                                                        productList[index]
                                                                            .selectedItem]
                                                                    .varient_id
                                                                : productList[
                                                                        index]
                                                                    .product_id,
                                                            (productList[index]
                                                                            .varient_details !=
                                                                        null &&
                                                                productList[index]
                                                                    .varient_details.isNotEmpty &&
                                                                    productList[index]
                                                                            .varient_details
                                                                            .length >
                                                                        1)
                                                                ? true
                                                                : false);
                                                      },
                                                      child: Icon(
                                                        Icons.delete,
                                                        color: kMainColor,
                                                        size: 20,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Positioned(
                                        left: 120,
                                        bottom: 5,
                                        child: InkWell(
                                          onTap: () {},
                                          child: Container(
                                            height: 30.0,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12.0),
                                            decoration: BoxDecoration(
                                              color: kCardBackgroundColor,
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                            ),
                                            child: (productList[index]
                                                            .varient_details !=
                                                        null &&
                                                    productList[index]
                                                            .varient_details
                                                            .length >
                                                        0)
                                                ? DropdownButton<VarientList>(
                                                    underline: Container(
                                                      height: 0.0,
                                                      color:
                                                          kCardBackgroundColor,
                                                    ),
                                                    value: productList[index]
                                                            .varient_details[
                                                        productList[index]
                                                            .selectedItem],
                                                    items: productList[index]
                                                        .varient_details
                                                        .map((e) {
                                                      return DropdownMenuItem<
                                                          VarientList>(
                                                        child: Text(
                                                          '${e.quantity} ${e.unit}',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .caption,
                                                        ),
                                                        value: e,
                                                      );
                                                    }).toList(),
                                                    onChanged: (vale) {
                                                      setState(() {
                                                        int indexd =
                                                            productList[index]
                                                                .varient_details
                                                                .indexOf(vale);
                                                        if (indexd != -1) {
                                                          productList[index]
                                                                  .selectedItem =
                                                              indexd;
                                                        }
                                                      });
                                                    })
                                                : Text(''),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        height: 30,
                                        right: 0.0,
                                        bottom: 5,
                                        child: GestureDetector(
                                          onTap: () {
                                            hitStockChange(
                                                context,
                                                productList[index]
                                                    .varient_details[
                                                        productList[index]
                                                            .selectedItem]
                                                    .varient_id,
                                                (productList[index]
                                                                .varient_details !=
                                                            null &&
                                                        productList[index]
                                                                .varient_details
                                                                .length >
                                                            0 &&
                                                        int.parse(
                                                                '${productList[index].varient_details[productList[index].selectedItem].stock}') !=
                                                            0)
                                                    ? 'outstock'
                                                    : 'instock');
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10.0, vertical: 10),
                                            margin: EdgeInsets.only(
                                                left: 5.0, right: 10),
                                            decoration: BoxDecoration(
                                                color: kMainColor,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(50))),
                                            child: Text(
                                              (productList[index]
                                                              .varient_details !=
                                                          null &&
                                                      productList[index]
                                                              .varient_details
                                                              .length >
                                                          0 &&
                                                      int.parse(
                                                              '${productList[index].varient_details[productList[index].selectedItem].stock}') !=
                                                          0)
                                                  ? 'In Stock'
                                                  : 'Out Stock',
                                              style: TextStyle(
                                                  fontSize: 10.0,
                                                  color: kWhiteColor),
                                            ),
                                          ),
                                        ),
                                      ),
                                      /*Positioned(
                                        height: 30,
                                        right: 20.0,
                                        bottom: 5,
                                        child: Text((productList[index]
                                                        .varient_details !=
                                                    null &&
                                                productList[index]
                                                        .varient_details
                                                        .length >
                                                    0 &&
                                                int.parse(
                                                        '${productList[index].varient_details[productList[index].selectedItem].stock}') !=
                                                    0)
                                            ? 'In Stock'
                                            : 'Out Stock'),
                                      ),*/
                                      // Positioned(
                                      //   top: 20,
                                      //     right: 5,
                                      //     child: ),
                                    ],
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return SizedBox(
                                  height: 5,
                                );
                              },
                            )
                          : isFetch
                              ? Container(
                                  width: MediaQuery.of(context).size.width,
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(horizontal: 30),
                                  child: Row(
                                    children: [
                                      CupertinoActivityIndicator(
                                        radius: 20,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: Text(
                                          locale.fetchingpro,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 25,
                                              color: kMainColor,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(horizontal: 30),
                                  child: Text(
                                    locale.nodatacat,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 25,
                                        color: kMainColor,
                                        fontWeight: FontWeight.w600),
                                  ),
                                );
                    }).toList(),
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Container(
                      height: 10.0,
                    ))
              ],
            ),
            Visibility(
              visible: isDelete,
              child: GestureDetector(
                onTap: () {},
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: MediaQuery.of(context).size.height - 110,
                  width: MediaQuery.of(context).size.width,
                  color: Color.fromRGBO(253, 254, 254, 0.3),
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () =>
              Navigator.pushNamed(context, PageRoutes.addItem).then((value) {
            /* if(subCatList!=null && tabController!=null)
                  productListM(subCatList[tabController.index].subcat_id);
                else*/
            getSubCategory();
          }),
          tooltip: 'ADD PRODUCT',
          child: Icon(
            Icons.add,
            size: 15.7,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void hitDeleteButton(
      BuildContext context, product_id, isVaraint, AppLocalizations locale) {
    setState(() {
      isDelete = true;
    });
    var client = http.Client();
    // final product_id = 'govadiyo';
    var storeProduct;
    if (isVaraint) {
      storeProduct = store_deletevariant;
    } else {
      storeProduct = store_deleteproduct;
    }
    final url = Uri.encodeFull('$storeProduct/${product_id}');
    client.post(Uri.parse(storeProduct),body: {
      'varient_id':product_id.toString()
    }).then((value) {
      var jsonData1 = (value.body);
      print('${value.body}');
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          Toast.show(jsonData['message'], context,
              gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
          productListM(subCatList[tabController.index].subcat_id);
        } else {
          Toast.show(locale.somethingwent, context,
              gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
        }
      } else {
        Toast.show(locale.somethingwent, context,
            gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
      }
      setState(() {
        isDelete = false;
      });
    }).catchError((e) {
      Toast.show(locale.somethingwent, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
      setState(() {
        isDelete = false;
      });
      print(e);
    });
  }

  void hitStockChange(BuildContext context, varient_id, stockType) {
    setState(() {
      isFetch = true;
    });
    var client = http.Client();
    var url = store_stockchange;
    client.post(url, body: {
      'varient_id': varient_id.toString(),
      'type': stockType
    }).then((value) {
      print('${value.body}');
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          Toast.show(jsonData['message'], context,
              gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
          productListM(subCatList[tabController.index].subcat_id);
        } else {
          Toast.show(jsonData['message'], context,
              gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
        }
      }else
        Toast.show('Something went wrong!', context,
            gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);

      setState(() {
        isFetch = false;
      });
    }).catchError((e) {
      Toast.show('Something went wrong!', context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
      setState(() {
        isFetch = false;
      });
      print(e);
    });
  }

  showAlertDialog(BuildContext context, product_id, isVaraint) {
    var locale = AppLocalizations.of(context);
    Widget clear = GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        hitDeleteButton(context, product_id, isVaraint, locale);
      },
      child: Material(
        elevation: 2,
        clipBehavior: Clip.hardEdge,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Text(
            locale.yes1,
            style: TextStyle(fontSize: 13, color: kWhiteColor),
          ),
        ),
      ),
    );

    Widget no = GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        clipBehavior: Clip.hardEdge,
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Text(
            locale.no1,
            style: TextStyle(fontSize: 13, color: kWhiteColor),
          ),
        ),
      ),
    );

    AlertDialog alert = AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      title: Text(locale.alert),
      content: Text(locale.delpro),
      actions: [clear, no],
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
}
