import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopping_app/services/database.dart';
import 'package:shopping_app/widget/support_widget.dart';

class AllOrders extends StatefulWidget {
  const AllOrders({super.key});

  @override
  State<AllOrders> createState() => _AllOrdersState();
}

class _AllOrdersState extends State<AllOrders> {
  Stream? orderStream;

  getontheload() async {
    orderStream = await DatabaseMethods().allOrders();
    setState(() {});
  }

  @override
  void initState() {
    getontheload();
    // TODO: implement initState
    super.initState();
  }

  Widget allOrders() {
    return StreamBuilder(
        stream: orderStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      child: Material(
                        elevation: 3.0,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: EdgeInsets.only(
                              left: 10.0, top: 10.0, bottom: 10.0),
                          width: MediaQuery.of(context).size.width - 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.network(
                                    ds["Image"],
                                    height: 90,
                                    width: 90,
                                    fit: BoxFit.cover,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Name: " + ds["Name"],
                                          style:
                                              AppWidget.semiboldTextFieldStyle()
                                                  .copyWith(
                                            fontSize:
                                                16, // Kiểm tra kích thước phông chữ
                                            height:
                                                1.2, // Kiểm tra chiều cao dòng
                                          ),
                                        ),
                                        SizedBox(
                                            height:
                                                5), // Khoảng cách giữa Name và Email
                                        Text(
                                          "Email: " + ds["Email"],
                                          style: AppWidget.lightTextFieldStyle()
                                              .copyWith(
                                            fontSize:
                                                16, // Kiểm tra kích thước phông chữ
                                            height:
                                                1.2, // Kiểm tra chiều cao dòng
                                          ),
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Text(
                                          ds["Product"],
                                          style:
                                              AppWidget.semiboldTextFieldStyle()
                                                  .copyWith(
                                            fontSize:
                                                16, // Kiểm tra kích thước phông chữ
                                            height:
                                                1.2, // Kiểm tra chiều cao dòng
                                          ),
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("\$" + ds["Price"],
                                                style: TextStyle(
                                                    color: Color(0xFFfd6f3e),
                                                    fontSize: 20.0,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            GestureDetector(
                                              onTap: () async {
                                                await DatabaseMethods()
                                                    .updateStatus(ds.id);
                                                    setState(() {
                                                      
                                                    });
                                              },
                                              child: Container(
                                                margin:
                                                    EdgeInsets.only(right: 20),
                                                width: 80,
                                                decoration: BoxDecoration(
                                                    color: Color(0xFFfd6f3e),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Center(
                                                    child: Text(
                                                  "Done",
                                                  style: AppWidget
                                                      .semiboldTextFieldStyle(),
                                                )),
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  })
              : Container();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "All Orders",
          style: AppWidget.boldTextFieldStyle(),
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(left: 20.0, right: 20.0),
        child: Column(
          children: [Expanded(child: allOrders())],
        ),
      ),
    );
  }
}
