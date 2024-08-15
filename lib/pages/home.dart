import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopping_app/pages/category_products.dart';
import 'package:shopping_app/pages/product_detail.dart';
import 'package:shopping_app/services/database.dart';
import 'package:shopping_app/services/shared_prefs.dart';
import 'package:shopping_app/widget/support_widget.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool search = false;
  List categories = [
    "images/headphone_icon.png",
    "images/laptop.png",
    "images/watch.png",
    "images/TV.png"
  ];

  List categoryname = [
    "Headphones",
    "Laptop",
    "Watch",
    "TV",
  ];

  var queryResultSet = [];
  var tempSearchStore = [];
  TextEditingController searchController = new TextEditingController();

  initiateSearch(String value) {
    // Khởi tạo lại danh sách kết quả tìm kiếm và danh sách tạm thời
    queryResultSet = [];
    tempSearchStore = [];

    if (value.isEmpty) {
      setState(() {
        search = false;
      });
      return;
    }

    setState(() {
      search = true;
    });

    var capitalizedValue =
        value.substring(0, 1).toUpperCase() + value.substring(1);

    // Thực hiện tìm kiếm từ cơ sở dữ liệu nếu danh sách kết quả tìm kiếm trống và có một ký tự nhập vào
    if (value.length == 1) {
      DatabaseMethods().search(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.docs.length; ++i) {
          print(docs.docs[i].data()); // Debug
          queryResultSet.add(docs.docs[i].data());
        }
        // Cập nhật trạng thái sau khi lấy dữ liệu từ cơ sở dữ liệu
        filterSearchResults(capitalizedValue);
      });
    } else {
      filterSearchResults(capitalizedValue);
    }
  }

// Hàm để lọc kết quả tìm kiếm
  void filterSearchResults(String capitalizedValue) {
    tempSearchStore = queryResultSet.where((element) {
      return element['UpdatedName'].startsWith(capitalizedValue);
    }).toList();

    setState(() {});
  }

  String? name, image;

  getthesharedpref() async {
    name = await SharedPreferenceHelper().getUserName();
    image = await SharedPreferenceHelper().getUserImage();
    setState(() {});
  }

  ontheload() async {
    await getthesharedpref();
    setState(() {});
  }

  @override
  void initState() {
    ontheload();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff2f2f2),
      body: name == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hey, " + name!,
                              style: AppWidget.boldTextFieldStyle(),
                            ),
                            Text(
                              "Good Morning",
                              style: AppWidget.lightTextFieldStyle(),
                            )
                          ],
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.network(image!,
                              height: 50, width: 50, fit: BoxFit.cover),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 20.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0)),
                      width: MediaQuery.of(context).size.width,
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          initiateSearch(value.toUpperCase());
                        },
                        decoration: (InputDecoration(
                          border: InputBorder.none,
                          hintText: "Search Products",
                          hintStyle: AppWidget.lightTextFieldStyle(),
                          prefixIcon: search
                              ? GestureDetector(
                                  onTap: () {
                                    search = false;
                                    tempSearchStore = [];
                                    queryResultSet = [];
                                    searchController.text = "";
                                    setState(() {});
                                  },
                                  child: Icon(Icons.close))
                              : Icon(Icons.search, color: Colors.black),
                        )),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    search
                        ? ListView(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            primary: false,
                            shrinkWrap: true,
                            children: tempSearchStore.map((element) {
                              return buildResultCard(element);
                            }).toList(),
                          )
                        : Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 20.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Categories",
                                      style: AppWidget.semiboldTextFieldStyle(),
                                    ),
                                    Text(
                                      "see all",
                                      style: TextStyle(
                                          color: Color(0xFFfd6f3e),
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(height: 20.0),
                              Row(
                                children: [
                                  Container(
                                    height: 130,
                                    padding: EdgeInsets.all(20.0),
                                    margin: EdgeInsets.only(right: 20.0),
                                    decoration: BoxDecoration(
                                        color: Color(0xFFFD6F3E),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Center(
                                      child: Text(
                                        "All",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: SizedBox(
                                      height: 130,
                                      child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          itemCount: categories.length,
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (context, index) {
                                            return CategoryTitle(
                                              image: categories[index],
                                              name: categoryname[index],
                                            );
                                          }),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "All Products",
                                    style: AppWidget.semiboldTextFieldStyle(),
                                  ),
                                  Text(
                                    "see all",
                                    style: TextStyle(
                                        color: Color(0xFFfd6f3e),
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                              SizedBox(height: 30.0),
                              SizedBox(
                                height: 240,
                                child: ListView(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(right: 20.0),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Column(
                                        children: [
                                          Image.asset("images/headphone2.png",
                                              height: 150,
                                              width: 150,
                                              fit: BoxFit.cover),
                                          Text(
                                            "Headphones",
                                            style: AppWidget
                                                .semiboldTextFieldStyle(),
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Text("\$100",
                                                  style: TextStyle(
                                                      color: Color(0xFFfd6f3e),
                                                      fontSize: 22.0,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              SizedBox(width: 50.0),
                                              Container(
                                                  padding: EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                      color: Color(0xFFfd6f3e),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              7)),
                                                  child: Icon(
                                                    Icons.add,
                                                    color: Colors.white,
                                                  ))
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(right: 20.0),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Column(
                                        children: [
                                          Image.asset("images/watch2.png",
                                              height: 150,
                                              width: 150,
                                              fit: BoxFit.cover),
                                          Text(
                                            "Apple Watch",
                                            style: AppWidget
                                                .semiboldTextFieldStyle(),
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Text("\$300",
                                                  style: TextStyle(
                                                      color: Color(0xFFfd6f3e),
                                                      fontSize: 22.0,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              SizedBox(width: 50.0),
                                              Container(
                                                padding: EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                    color: Color(0xFFfd6f3e),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7)),
                                                child: Icon(
                                                  Icons.add,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(right: 20.0),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Column(
                                        children: [
                                          Image.asset("images/laptop.png",
                                              height: 150,
                                              width: 150,
                                              fit: BoxFit.cover),
                                          Text(
                                            "Laptop",
                                            style: AppWidget
                                                .semiboldTextFieldStyle(),
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Text("\$1000",
                                                  style: TextStyle(
                                                      color: Color(0xFFfd6f3e),
                                                      fontSize: 22.0,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              SizedBox(width: 50.0),
                                              Container(
                                                padding: EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                    color: Color(0xFFfd6f3e),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7)),
                                                child: Icon(
                                                  Icons.add,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildResultCard(data) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetail(
              image: data["Image"],
              name: data["Name"],
              detail: data["Detail"],
              price: data["Price"],
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.only(left: 20.0),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        height: 100,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                data["Image"],
                height: 70,
                width: 70,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              width: 20.0,
            ),
            Text(
              data["Name"],
              style: AppWidget.semiboldTextFieldStyle(),
            )
          ],
        ),
      ),
    );
  }
}

class CategoryTitle extends StatelessWidget {
  String image, name;
  CategoryTitle({required this.image, required this.name});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CategoryProduct(category: name)));
      },
      child: Container(
        padding: EdgeInsets.all(20.0),
        margin: EdgeInsets.only(right: 20.0),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(image, height: 50, width: 50, fit: BoxFit.cover),
            Icon(Icons.arrow_forward)
          ],
        ),
      ),
    );
  }
}
