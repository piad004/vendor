import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vendor/Components/bottom_bar.dart';
import 'package:vendor/Components/custom_appbar.dart';
import 'package:vendor/Locale/locales.dart';
import 'package:vendor/Routes/routes.dart';
import 'package:vendor/Themes/colors.dart';
import 'package:vendor/baseurl/baseurl.dart';
import 'package:vendor/orderbean/todayorderbean.dart';
import 'package:vendor/orderbean/vendorboy.dart';

class OrderInfo extends StatefulWidget {
  @override
  _OrderInfoState createState() => _OrderInfoState();
}

class _OrderInfoState extends State<OrderInfo> {
  TodayOrderDetails orderDetails;
  dynamic curency;
bool isDismiss = false;

  @override
  void dispose() {
    isDismiss = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);

    final Map<String, Object> dataObject =
        ModalRoute.of(context).settings.arguments;
    setState(() {
      if(!isDismiss){
        orderDetails = dataObject['orderdetails'];
        curency = dataObject['curency'];
      }
    });

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight((orderDetails.order_status.toString().trim().toUpperCase() == 'PENDING')
            ? 200
            : 150),
        child: CustomAppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: kMainColor,
              size: 24,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          titleWidget: Text(
            '${locale.orderid1} #${orderDetails.cart_id}',
            style: Theme.of(context)
                .textTheme
                .headline4
                .copyWith(fontSize: 13.3, letterSpacing: 0.07),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 10, top: 10, bottom: 10),
              child:
              RaisedButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(
                      PageRoutes.invoicepdf,
                      arguments: {
                        'inv_details': orderDetails,
                      })
                      .then((value) {})
                      .catchError((e) {});
                },
                child: Text(
                  locale.invoiceprint,
                  style: TextStyle(
                      color: kWhiteColor, fontWeight: FontWeight.w400),
                ),
                color: kMainColor,
                highlightColor: kMainColor,
                focusColor: kMainColor,
                splashColor: kMainColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(0.0),
            child: Column(
              children: [
            Visibility(
            visible: ((orderDetails.order_status.toString().trim().toUpperCase() == 'PENDING') ||
                (orderDetails.order_status.toString().trim().toUpperCase() == 'CANCEL'))
              ? true
              : false,
            child:
                Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceAround,
            children: [
                RaisedButton(
                  onPressed: () {
                    /* Navigator.of(context)
                      .pushNamed(
                      PageRoutes.invoicepdf,
                      arguments: {
                        'inv_details': orderDetails,
                      })
                      .then((value) {})
                      .catchError((e) {});*/

                    _showCancelDialog(pr);
                  },
                  child: Text(
                    'Cancel order',
                    style: TextStyle(
                        color: kWhiteColor, fontWeight: FontWeight.w400),
                  ),
                  color: kMainColor,
                  highlightColor: kMainColor,
                  focusColor: kMainColor,
                  splashColor: kMainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              RaisedButton(
                onPressed: () {
                  getReviewOrders("Pending",'',pr);
                },
                child: Text(
                  "Accept",
                  style: TextStyle(
                      color: kWhiteColor, fontWeight: FontWeight.w400),
                ),
                color: kMainColor,
                highlightColor: kMainColor,
                focusColor: kMainColor,
                splashColor: kMainColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ]),
            ),
            Hero(
              tag: locale.customer,
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: ListTile(
                  leading: Image.asset(
                    'images/user.png',
                    scale: 2.5,
                    height: 42.3,
                    width: 33.7,
                  ),
                  title: Text(
                    '${orderDetails.user_name}',
                    style: Theme.of(context)
                        .textTheme
                        .headline4
                        .copyWith(fontSize: 13.3, letterSpacing: 0.07),
                  ),
                  subtitle: Text(
                    '${orderDetails.delivery_date} | ${orderDetails.time_slot}',
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(fontSize: 11.7, letterSpacing: 0.06),
                  ),
                  trailing: FittedBox(
                    fit: BoxFit.fill,
                    child: Row(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(
                            Icons.phone,
                            color: kWhiteColor,
                            size: 0.0,
                          ),
                          onPressed: () {
                           /* if (orderDetails.user_number != null &&
                                orderDetails.user_number.toString().length >
                                    9) {
                              _launchURL("tel:${orderDetails.user_number}");
                            }*/
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ]),
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          ListView(
            primary: true,
            children: <Widget>[
              Divider(
                color: kCardBackgroundColor,
                thickness: 8.0,
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                child: Text(locale.item,
                    style: Theme.of(context).textTheme.headline6.copyWith(
                        color: Color(0xffadadad), fontWeight: FontWeight.bold)),
                color: Colors.white,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.0),
                child: ListView.builder(
                    itemCount: orderDetails.order_details.length,
                    shrinkWrap: true,
                    primary: false,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          ListTile(
                            title: Text(
                              '${orderDetails.order_details[index].product_name}\n${orderDetails.order_details[index].description}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4
                                  .copyWith(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              '${orderDetails.order_details[index].quantity} ${orderDetails.order_details[index].unit} x ${orderDetails.order_details[index].qty}',
                              style: Theme.of(context).textTheme.caption,
                            ),
                            trailing: Text(
                              '${curency} ${orderDetails.order_details[index].price}',
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ),
                          Divider(
                            color: kCardBackgroundColor,
                            thickness: 1.0,
                          ),
                        ],
                      );
                    }),
              ),
              Divider(
                color: kCardBackgroundColor,
                thickness: 8.0,
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                child: Text(locale.payementinfo,
                    style: Theme.of(context).textTheme.headline6.copyWith(
                        color: kDisabledColor, fontWeight: FontWeight.bold)),
                color: Colors.white,
              ),
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 20.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        locale.subtotal,
                        style: Theme.of(context).textTheme.caption,
                      ),
                      Text(
                        '${curency} ${orderDetails.price_without_delivery}',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ]),
              ),
              Divider(
                color: kCardBackgroundColor,
                thickness: 1.0,
              ),
             /* Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 20.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        locale.servicefee,
                        style: Theme.of(context).textTheme.caption,
                      ),
                      Text(
                        '${curency} ${orderDetails.delivery_charge}',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ]),
              ),
              Divider(
                color: kCardBackgroundColor,
                thickness: 1.0,
              ),
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 20.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        locale.orderprice,
                        style: Theme.of(context)
                            .textTheme
                            .caption
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${curency} ${orderDetails.total_price}',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ]),
              ),
              Divider(
                color: kCardBackgroundColor,
                thickness: 1.0,
              ),
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 20.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        locale.remainamt,
                        style: Theme.of(context)
                            .textTheme
                            .caption
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${curency} ${orderDetails.remaining_price}',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ]),
              ),
              Divider(
                color: kCardBackgroundColor,
                thickness: 1.0,
              ),*/
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 20.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        locale.paymethod,
                        style: Theme.of(context).textTheme.caption.copyWith(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        '${orderDetails.payment_method}',
                        style: Theme.of(context).textTheme.caption.copyWith(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ]),
              ),
              Divider(
                color: kCardBackgroundColor,
                thickness: 1.0,
              ),
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 20.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        locale.paystatus,
                        style: Theme.of(context).textTheme.caption.copyWith(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        '${orderDetails.payment_status}',
                        style: Theme.of(context).textTheme.caption.copyWith(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ]),
              ),
              SizedBox(
                height: 7.0,
              ),
              Container(
                height: 180.0,
                color: kCardBackgroundColor,
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  color: kWhiteColor,
                  padding: EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 22.0,
                      backgroundImage: AssetImage('images/profile.png'),
                    ),
                    title: Text(
                      '${orderDetails.delivery_boy_name != null ? orderDetails.delivery_boy_name : 'Not Assigned Yet'}',
                      style: Theme.of(context).textTheme.headline4.copyWith(
                          fontSize: 15.0, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      locale.delpartner,
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(fontSize: 11.7, letterSpacing: 0.06),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.call,
                        color: kMainColor,
                        size: (orderDetails.delivery_boy_num != null &&
                            orderDetails.delivery_boy_num.toString().length >
                                9)?17.0:0.0,
                      ),
                      onPressed: () {
                        if (orderDetails.delivery_boy_num != null &&
                            orderDetails.delivery_boy_num.toString().length >
                                9) {
                         // _launchURL("tel:+${orderDetails.delivery_boy_num}");
                          _launchURL("${orderDetails.delivery_boy_num}");
                        }
                      },
                    ),
                  ),
                ),
                BottomBar(
                    text:
                        '${orderDetails.delivery_boy_name != null ? orderDetails.delivery_boy_name : 'Not Assigned Yet'}',
                    onTap: () {
                      if (orderDetails.order_status == "pending" ||
                          orderDetails.order_status == "Pending") {
                        hitFindDriver(context, pr, locale);
                      } else {
                        Toast.show('Already assign to ${orderDetails.delivery_boy_name}', context,
                            duration: Toast.LENGTH_SHORT);
                      }
                      // Navigator.pop(context);
                    })
              ],
            ),
          )
        ],
      ),
    );
  }


  Future<void> _showCancelDialog(pr) async {
    var reason="";
    var isVisible=true;

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 300,
              child: Padding(
                padding: const EdgeInsets.only(left:12.0,right: 12,bottom: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order Cancel',style: TextStyle(color: Colors.green,fontSize: 18,
                      fontWeight: FontWeight.bold, ),),
                    /*SizedBox(
                  height: 10,
                ),*/
                    TextFormField(
                      minLines: 4,
                      maxLines: 4,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                            borderSide: BorderSide(color: Colors.blue)),
                        // hintText: 'Review',
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                            borderSide: BorderSide(color: Colors.blue)),
                        filled: true,
                        contentPadding:
                        EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
                        labelText: 'Reason',
                      ),
                      initialValue: reason,
                      //validator: widget.ongoingOrders,
                      onChanged: (String newValue) {
                        reason=newValue;
                      },
                    ),
                    /* SizedBox(
                      height: 10,
                    ),*/

                    Container(color: kMainColor,
                      width: MediaQuery.of(context).size.width-80,
                      height: 1,),
                    SizedBox(
                      height: 5,
                    ),
                    /* SizedBox(
                      height: 10,
                    ),*/
                    Visibility(
                        visible: isVisible,
                        child: SizedBox(
                          width: 320.0,
                          height: 40,
                          child: RaisedButton(
                            onPressed: () {
                              if(reason!="")
                              getReviewOrders('Cancelled',reason,pr);
                              else
                                Toast.show("Empty reason!!", context,
                                    duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
                            },
                            child: Text(
                              "Save",
                              style: TextStyle(color: Colors.white),
                            ),
                            color: const Color(0xFF1BC0C5),
                          ),
                        )
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  showDialogList(
      context, List<DeliveryBoyList> list, lat, lng, ProgressDialog pr) {
    var locale = AppLocalizations.of(context);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 500,
              color: kWhiteColor,
              padding: EdgeInsets.symmetric(vertical: 20),
              child: ListView.separated(
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                      showProgressDialog('Please wait assiging driver', pr);
                      pr.show();
                      hitAssignOrder(
                          context,
                          pr,
                          list[index].delivery_boy_id,
                          list[index].delivery_boy_name,
                          list[index].delivery_boy_phone);
                    },
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${locale.delboy}- ${list[index].delivery_boy_name} (${list[index].delivery_boy_status})\nPhone - ${list[index].delivery_boy_phone}',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: kMainTextColor),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 6,
                    color: kCardBackgroundColor,
                  );
                },
                itemCount: list.length,
              ),
            ),
          );
        });
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

  void hitFindDriver(context, ProgressDialog pr, AppLocalizations locale) async {
    showProgressDialog('Please wait finding delivery boy', pr);
    pr.show();
    SharedPreferences pref = await SharedPreferences.getInstance();
    var vendorId = pref.getInt('vendor_id');
    var client = http.Client();
    var assignUrl = store_delivery_boy;
    client.post(assignUrl, body: {'vendor_id': '${vendorId}'}).then((value) {
      pr.hide();
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var jsond = jsonData['data'] as List;
          List<DeliveryBoyList> delList =
              jsond.map((e) => DeliveryBoyList.fromJson(e)).toList();
          if (delList != null && delList.length > 0) {
            showDialogList(
                context, delList, pref.getString('lat'), pref.get('lng'), pr);
          } else {
            Toast.show(locale.deliveryboy1, context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
          }
        } else {
          Toast.show(locale.deliveryboy1, context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        }
      }
    }).catchError((e) {
      print(e);
    });
  }

  void hitAssignOrder(context, ProgressDialog pr, dBoyId, delivery_boy_name,
      delivery_phone) async {
    var client = http.Client();
    var assignUrl = assigned_store_order;
    client.post(assignUrl, body: {
      'delivery_boy_id': '${dBoyId}',
      'order_id': '${orderDetails.order_id}'
    }).then((value) {
      pr.hide();
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          setState(() {
            if(!isDismiss){
              orderDetails.delivery_boy_name = delivery_boy_name;
              orderDetails.delivery_boy_num = delivery_phone;
            }

          });
          if(!isDismiss){
            Toast.show(jsonData['message'], context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
          }
          Navigator.of(context).pop();
        }
      }
    }).catchError((e) {
      print(e);
      pr.hide();
    });
  }

  _launchURL(url) async {

    final Uri launchUri = Uri(
      scheme: 'tel',
      path: url,
    );
    await launch(launchUri.toString());
    /*if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }*/
  }

  void getReviewOrders(type,review,ProgressDialog pr) {
    pr.show();
    var client = http.Client();
    var assignUrl = orderCancel;
    client.post(assignUrl, body: {
      //'delivery_boy_id': '${dBoyId}',
      'cart_id': '${orderDetails.cart_id}',
      'cause': '${review}',
      'type': '${type}'
    }).then((value) {
      pr.hide();
      print(value.body);
      var jsonData = jsonDecode(value.body);
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        Toast.show(jsonData['message'], context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        if (jsonData['status'] == "1") {
          Navigator.of(context).pop();
        }
        if (type=='Cancelled') {
          Navigator.of(context).pop();
        }
      }else{
        Toast.show('Something went wrong!', context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      }
    }).catchError((e) {
      print(e);
      pr.hide();
      Toast.show('Server error!', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    });
  }
}
