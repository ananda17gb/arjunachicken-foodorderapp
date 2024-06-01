import 'dart:convert' as convert;

import 'package:arjunaschiken/googlesheets.dart';
import 'package:arjunaschiken/ordersheetscolumn.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:arjunaschiken/models/menu_model.dart';
import 'package:arjunaschiken/models/order_model.dart';
import 'package:http/http.dart' as myHttp;
import 'package:arjunaschiken/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  await Order.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => CartProvider())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.green),
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController orderController = TextEditingController();
  TextEditingController totalPriceController = TextEditingController();
  int currentBadgeCount = 0;

  GlobalKey<badges.BadgeState> badgeKey = GlobalKey<badges.BadgeState>();

  final String urlMenu =
      "https://script.googleusercontent.com/macros/echo?user_content_key=N9rQ6lzPEQOkUArRjYDG2go2mTLQPsStOHK43fz7NdNR7AxWiSuiE-QptMHT63YERcQMVyimoBgr8eUHUdgLVwwy7eZ2Or85m5_BxDlH2jW0nuo2oDemN9CCS2h10ox_1xSncGQajx_ryfhECjZEnEHzRHiTvmafifvZvhI5BsoZIM0E6Gf2ARWZBSbs4htNkktPt8ngni84z_0p0g-lT4OTgoGLpoj-j514DE5u0ArKy3xW3KWyVg&lib=MBYGDeHNMlncPc1KEfNvrnXITz066uR_0";

  Future<List<MenuModel>> getAllData() async {
    List<MenuModel> listMenu = [];
    var response = await myHttp.get(Uri.parse(urlMenu));
    List data = convert.json.decode(response.body);

    data.forEach((element) {
      listMenu.add(MenuModel.fromJson(element));
    });

    return listMenu;
  }

  Future<List<Welcome>> getAllOrders() async {
    List<Welcome> listOrders = [];
    var response = await myHttp.get(Uri.parse(urlOrder));
    List data = convert.json.decode(response.body);

    data.forEach((element) {
      listOrders.add(Welcome.fromJson(element));
    });

    return listOrders;
  }

  Future<void> _refreshData() async {
    // Perform the data fetching operation here
    await Future.delayed(Duration(seconds: 2)); // Simulate some delay

    setState(() {
      // Update the UI with the new data
    });
  }

  static const String urlOrder =
      "https://script.google.com/macros/s/AKfycbzfV05i-lPNYYc-j2X19z4c73zZYkDF7SNvCdcnBXK5mQoWrdy0OF_bQQAn5JmITBFJjg/exec"; // Update this URL with your order endpoint
  Future<void> sendOrderToSheets(
      String name, String orders, double totalPrice) async {
    // Create the order data payload
    final orderData = {
      SheetsColumn.name: name,
      SheetsColumn.orders: orders,
      SheetsColumn.total_price: totalPrice.toString(),
    };

    // Send data to the Order.insert method
    try {
      await Order.insert([orderData]);

      // Clear the cart after successful order
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.clearCart();

      // Trigger a rebuild of the UI (replace with your logic)
      setState(() {
        // Add any UI update logic here
      });
    } catch (e) {
      // Handle any exceptions that occurred during the insertion
      print('Error sending order data: $e');
    }
  }

  void openDialogue() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Container(
                height: 172,
                child: Column(
                  children: [
                    Text(
                      "Enter Customer Name:",
                      style: GoogleFonts.montserrat(),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Close the dialog
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.montserrat(),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Get the entered name
                            final name = nameController.text;

                            // Show order details dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: Container(
                                    height: 200,
                                    child: Column(
                                      children: [
                                        Text(
                                          "Customer Name: $name",
                                          style: GoogleFonts.montserrat(),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "Orders: ${cartProvider.getCartAsString()}",
                                          style: GoogleFonts.montserrat(),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "Total Price: Rp. ${cartProvider.getTotalPrice()}",
                                          style: GoogleFonts.montserrat(),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                // Close the dialog
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                "Cancel",
                                                style: GoogleFonts.montserrat(),
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () async {
                                                // Trigger the order sending process
                                                await sendOrderToSheets(
                                                    name,
                                                    cartProvider
                                                        .getCartAsString(),
                                                    cartProvider
                                                        .getTotalPrice());

                                                // Reset the badge count
                                                setState(() {
                                                  currentBadgeCount = 0;
                                                });

                                                // Clear the cart after successful order
                                                cartProvider.clearCart();

                                                // Close the dialog
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                "Confirm Order",
                                                style: GoogleFonts.montserrat(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Text(
                            "Add Order",
                            style: GoogleFonts.montserrat(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: Text(
          "Arjuna's Chicken",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Change this to your desired icon color
        ),
        // Add a refresh icon to manually trigger data fetching
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
        // Add a hamburger icon to open the drawer
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: const Color.fromARGB(255, 190, 190, 190),
        // Add items to your drawer here
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 10.0),
          child: ListView(
            children: [
              ListTile(
                title: Text(
                  'Access Menu Spreadsheet',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  // Add your logic for adding a menu
                  Navigator.pop(context); // Close the Drawer
                  final Uri urlmenu = Uri.parse(
                      'https://docs.google.com/spreadsheets/d/1lhunhqOvy89t6E_Jfu6r_XYd1bzEZFkXCiLXTFUcZGM/edit?hl=id#gid=0');
                  if (!await launchUrl(urlmenu)) {
                    throw Exception('Could not launch $urlmenu');
                  }
                },
              ),
              ListTile(
                title: Text(
                  'Access Order Spreadsheet',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  // Add your logic for adding a menu
                  Navigator.pop(context); // Close the Drawer
                  final Uri urlorder = Uri.parse(
                      'https://docs.google.com/spreadsheets/d/1gUx7u1OzxSPPKRMwtZoiaqqkLqRGvJsVlPrz6BHMVic/edit#gid=0');
                  if (!await launchUrl(urlorder)) {
                    throw Exception('Could not launch $urlorder');
                  }
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 75.0, // Adjust as needed
            right: 0.0, // Adjust as needed
            child: FloatingActionButton(
              onPressed: () {
                openDialogue();
              },
              backgroundColor: Colors.grey,
              child: badges.Badge(
                badgeContent: Consumer<CartProvider>(
                  builder: (context, value, _) {
                    int totalOrderQuantity = value.cart
                        .map((cartItem) => cartItem.quantity)
                        .fold(0, (sum, quantity) => sum + quantity);

                    return Text(
                      (totalOrderQuantity > 0)
                          ? totalOrderQuantity.toString()
                          : "",
                      style: GoogleFonts.montserrat(color: Colors.white),
                    );
                  },
                ),
                child: Icon(
                  Icons.shopping_bag,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<List<MenuModel>>(
                future: getAllData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    if (snapshot.hasData) {
                      return Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            MenuModel menu = snapshot.data![index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Container(
                                      width: 90,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(menu.image),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          menu.name,
                                          style: GoogleFonts.montserrat(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          menu.description,
                                          textAlign: TextAlign.left,
                                          style: GoogleFonts.montserrat(
                                            fontSize: 13,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 12,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Rp. " + menu.price.toString(),
                                              style: GoogleFonts.montserrat(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                SizedBox(width: 10),
                                                Consumer<CartProvider>(
                                                  builder: (context, value, _) {
                                                    var id =
                                                        value.cart.indexWhere(
                                                      (element) =>
                                                          element.menuId ==
                                                          snapshot
                                                              .data![index].id,
                                                    );
                                                    int itemQuantity =
                                                        (id == -1)
                                                            ? 0
                                                            : value.cart[id]
                                                                .quantity;

                                                    return Row(
                                                      children: [
                                                        IconButton(
                                                          onPressed: () {
                                                            Provider.of<CartProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .addRemove(
                                                              menu.name,
                                                              menu.id,
                                                              false,
                                                              menu.price,
                                                            );
                                                          },
                                                          icon: Icon(
                                                            Icons.remove_circle,
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                        SizedBox(width: 10),
                                                        Text(
                                                          itemQuantity
                                                              .toString(),
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                        SizedBox(width: 10),
                                                        IconButton(
                                                          onPressed: () {
                                                            Provider.of<CartProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .addRemove(
                                                              menu.name,
                                                              menu.id,
                                                              true,
                                                              menu.price,
                                                            );
                                                          },
                                                          icon: Icon(
                                                            Icons.add_circle,
                                                            color: Colors.green,
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    } else {
                      return Center(
                        child: Text("No Data"),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
