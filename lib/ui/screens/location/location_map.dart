// ignore_for_file: non_constant_identifier_names, unused_field

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:imechano/localization/language_constrants.dart';
import 'package:imechano/ui/provider/theme_provider.dart';
import 'package:imechano/ui/screens/bottombar/bottom_bar.dart';
import 'package:imechano/ui/shared/widgets/appbar/custom_appbar_widget.dart';
import 'package:imechano/ui/shared/widgets/appbar/custom_drawer_widget.dart';
import 'package:imechano/ui/styling/colors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapLocation extends StatefulWidget {
  final Function? callBackFunction;

  const MapLocation({Key? key, this.callBackFunction}) : super(key: key);
  @override
  _MapLocationState createState() => _MapLocationState();
}

class _MapLocationState extends State<MapLocation> {
  int current_step = 0;
  LatLng? currentPosition;
  dynamic latitudeCurrentLocation;
  dynamic longtitudeCurrentLocation;
  bool mapLoad = false;
  bool loadAddress = false;

  void _getUserLocation() async {
    try {
      // iOS-friendly location fetching
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );
      setState(() {
        currentPosition = LatLng(position.latitude, position.longitude);
        latitudeCurrentLocation = currentPosition!.latitude;
        longtitudeCurrentLocation = currentPosition!.longitude;
        mapLoad = true;
      });
      marker();
    } catch (e) {
      print('Location error: $e');
      // Fallback to Mumbai coordinates if location fails
      setState(() {
        latitudeCurrentLocation = 19.0760;
        longtitudeCurrentLocation = 72.8777;
        mapLoad = true;
      });
      marker();
    }
  }

  List<Placemark>? placemarks;
  List<Marker> _markers = <Marker>[];
  var area;
  var street;
  var area2;
  var city;
  var state;
  var country;
  var postalCode;
  var fullAddress;

  addressGet() {
    setState(() {
      area = placemarks![0].name;
      street = placemarks![0].street;
      area2 = placemarks![0].subLocality;
      city = placemarks![0].locality;
      state = placemarks![0].administrativeArea;
      country = placemarks![0].isoCountryCode;
      postalCode = placemarks![0].postalCode;
      fullAddress = '$street' +
          '$area' +
          '$area2' +
          '$city' +
          '$state' +
          '$country' +
          '$postalCode';
    });
  }

  GoogleMapController? mapsController;
  LatLng? middlePointOfScreenOnMap;
  bool _isLocationLoading = false;

  // Helper method to update location data
  Future<void> _updateLocationData() async {
    try {
      placemarks = await placemarkFromCoordinates(
          latitudeCurrentLocation, longtitudeCurrentLocation);
      addressGet();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(
        'address',
        "${("$street, $area, $area2, $city, $state, $country, $postalCode")}",
      );
      prefs.setString('lontitude', "$longtitudeCurrentLocation");
      prefs.setString('latitude', "$latitudeCurrentLocation");

      setState(() {
        loadAddress = true;
      });

      widget.callBackFunction!(true);
      print("$longtitudeCurrentLocation data updated");
    } catch (e) {
      print("Error updating location data: $e");
    }
  }

  marker() async {
    _markers.clear(); // Clear existing markers
    _markers.add(Marker(
        markerId: MarkerId('SomeId'),
        draggable: true,
        onDragEnd: (value) async {
          latitudeCurrentLocation = value.latitude;
          longtitudeCurrentLocation = value.longitude;
          await _updateLocationData();
        },
        position: LatLng(latitudeCurrentLocation, longtitudeCurrentLocation),
        infoWindow: InfoWindow(title: 'Your Location')));

    await _updateLocationData();
  }

  String? currentVisibleRegion;
  GoogleMapController? mapController;
  LatLngBounds _visibleRegion = LatLngBounds(
    southwest: const LatLng(0, 0),
    northeast: const LatLng(0, 0),
  );

  @override
  void initState() {
    super.initState();
    permissionCheck();
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('Alert!',
          "Location services are disabled. Please enable the services",
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('Warning!', 'Location permissions are denied',
            backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Get.snackbar('Error!',
          'Location permissions are permanently denied, we cannot request permissions.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
    return true;
  }

  permissionCheck() async {
    final status = await _handleLocationPermission();

    _handleLocationPermission();
    if (status == true) {
      _getUserLocation();
    } else {
      latitudeCurrentLocation = 19.0760;
      longtitudeCurrentLocation = 72.8777;
      setState(() {
        mapLoad = true;
      });
    }
  }

  final GlobalKey<ScaffoldState> _key = GlobalKey();
  dynamic appModelTheme;

  @override
  Widget build(BuildContext context) {
    final appModel = Provider.of<AppModel>(context);

    appModelTheme = appModel;

    return ScreenUtilInit(
        designSize: Size(414, 896), // Updated to match other screens
        builder: (context, child) {
          return PopScope(
            canPop: true,
            onPopInvoked: (didPop) {
              if (!didPop) {
                if (Navigator.of(context).canPop()) {
                  Navigator.pop(context);
                } else {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => BottomBarPage(2)),
                      (Route<dynamic> route) => false);
                }
              }
            },
            child: Scaffold(
              key: _key,
              drawer: drawerpage(),
              appBar: WidgetAppBar(
                title: getTranslated('pickuplocation', context),
                menuItem: 'assets/svg/Menu.svg',
                imageicon: 'assets/svg/Arrow_alt_left.svg',
                home: 'assets/svg/homeicon.svg',
                //action2: 'assets/svg/ball.svg',
              ),
              body: SafeArea(
                  child: Container(
                child: Stack(
                  children: [
                    Container(
                        height: MediaQuery.of(context).size.height *
                            0.65, // More responsive
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(30.r),
                                topLeft: Radius.circular(30.r))),
                        child: Stack(
                          children: [
                            mapLoad == true
                                ? GoogleMap(
                                    markers: Set<Marker>.of(_markers),
                                    myLocationButtonEnabled: true,
                                    myLocationEnabled: true,
                                    onCameraIdle: () async {
                                      if (mapsController != null) {
                                        // Get center of screen when camera stops moving
                                        LatLngBounds bounds =
                                            await mapsController!
                                                .getVisibleRegion();
                                        LatLng center = LatLng(
                                          (bounds.northeast.latitude +
                                                  bounds.southwest.latitude) /
                                              2,
                                          (bounds.northeast.longitude +
                                                  bounds.southwest.longitude) /
                                              2,
                                        );

                                        // Update location when user stops dragging map
                                        if (!_isLocationLoading) {
                                          _isLocationLoading = true;
                                          latitudeCurrentLocation =
                                              center.latitude;
                                          longtitudeCurrentLocation =
                                              center.longitude;

                                          // Update address
                                          try {
                                            placemarks =
                                                await placemarkFromCoordinates(
                                                    latitudeCurrentLocation,
                                                    longtitudeCurrentLocation);
                                            addressGet();

                                            SharedPreferences prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            prefs.setString(
                                              'address',
                                              "${("$street, $area, $area2, $city, $state, $country, $postalCode")}",
                                            );
                                            prefs.setString('lontitude',
                                                "$longtitudeCurrentLocation");
                                            prefs.setString('latitude',
                                                "$latitudeCurrentLocation");

                                            setState(() {
                                              loadAddress = true;
                                            });

                                            widget.callBackFunction!(true);
                                          } catch (e) {
                                            print('Address fetch error: $e');
                                          }
                                          _isLocationLoading = false;
                                        }
                                      }
                                    },
                                    onCameraMove: (position) async {
                                      // Show that location is being updated
                                      setState(() {
                                        loadAddress = false;
                                      });
                                    },
                                    zoomControlsEnabled: true,
                                    mapType: MapType.normal,
                                    initialCameraPosition: CameraPosition(
                                      target: LatLng(latitudeCurrentLocation,
                                          longtitudeCurrentLocation),
                                      zoom: 16,
                                    ),
                                    onMapCreated:
                                        (GoogleMapController controller) {
                                      mapsController = controller;
                                    },
                                    onTap: (LatLng location) async {
                                      // Handle tap on map to select location
                                      if (!_isLocationLoading) {
                                        _isLocationLoading = true;
                                        latitudeCurrentLocation =
                                            location.latitude;
                                        longtitudeCurrentLocation =
                                            location.longitude;

                                        // Update marker
                                        _markers.clear();
                                        _markers.add(Marker(
                                          markerId:
                                              MarkerId('selectedLocation'),
                                          position: location,
                                          draggable: true,
                                          onDragEnd: (value) async {
                                            latitudeCurrentLocation =
                                                value.latitude;
                                            longtitudeCurrentLocation =
                                                value.longitude;
                                            await _updateLocationData();
                                          },
                                          infoWindow: InfoWindow(
                                              title: 'Selected Location'),
                                        ));

                                        await _updateLocationData();
                                        _isLocationLoading = false;
                                      }
                                    },
                                  )
                                : Center(
                                    child: CircularProgressIndicator(),
                                  ),

                            // Floating current location button
                            Positioned(
                              top: 20,
                              right: 20,
                              child: FloatingActionButton(
                                mini: true,
                                backgroundColor: Colors.white,
                                onPressed: () async {
                                  if (!_isLocationLoading) {
                                    setState(() {
                                      _isLocationLoading = true;
                                      loadAddress = false;
                                    });

                                    try {
                                      Position position =
                                          await Geolocator.getCurrentPosition(
                                        desiredAccuracy: LocationAccuracy.high,
                                        timeLimit: Duration(seconds: 10),
                                      );

                                      latitudeCurrentLocation =
                                          position.latitude;
                                      longtitudeCurrentLocation =
                                          position.longitude;

                                      // Update map camera
                                      if (mapsController != null) {
                                        await mapsController!.animateCamera(
                                          CameraUpdate.newLatLngZoom(
                                            LatLng(position.latitude,
                                                position.longitude),
                                            16,
                                          ),
                                        );
                                      }

                                      // Update marker
                                      _markers.clear();
                                      _markers.add(Marker(
                                        markerId: MarkerId('currentLocation'),
                                        position: LatLng(position.latitude,
                                            position.longitude),
                                        draggable: true,
                                        onDragEnd: (value) async {
                                          latitudeCurrentLocation =
                                              value.latitude;
                                          longtitudeCurrentLocation =
                                              value.longitude;
                                          await _updateLocationData();
                                        },
                                        infoWindow: InfoWindow(
                                            title: 'Current Location'),
                                      ));

                                      await _updateLocationData();
                                    } catch (e) {
                                      print(
                                          'Failed to get current location: $e');
                                      Get.snackbar('Error',
                                          'Failed to get current location',
                                          backgroundColor: Colors.red,
                                          colorText: Colors.white);
                                    }

                                    setState(() {
                                      _isLocationLoading = false;
                                    });
                                  }
                                },
                                child: _isLocationLoading
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2))
                                    : Icon(Icons.my_location, color: logoBlue),
                              ),
                            ),

                            // Center crosshair for better location selection
                            Center(
                              child: Icon(
                                Icons.add,
                                color: Colors.red,
                                size: 30,
                              ),
                            ),
                          ],
                        )),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                            decoration: BoxDecoration(
                                color: appModelTheme.darkTheme
                                    ? darkmodeColor
                                    : Colors.white,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(30.r),
                                    topLeft: Radius.circular(30.r))),
                            height: MediaQuery.of(context).size.height *
                                0.25, // Responsive height
                            width: double.infinity,
                            child: Bottomsheet())
                      ],
                    )
                  ],
                ),
              )),
            ),
          );
        });
  }

  Widget Bottomsheet() {
    return Column(
      children: [
        Divider(
          color: Colors.grey[300],
          height: 30.h,
          thickness: 5,
          indent: 90,
          endIndent: 90,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 25.w,
            ),
            Container(
              width: 20.w,
              alignment: Alignment.centerLeft,
              child: Container(
                child: DottedBorder(
                  color: greycolo,
                  borderType: BorderType.RRect,
                  radius: Radius.circular(12),
                  padding: EdgeInsets.all(6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    child: Container(
                      height: 10,
                      width: 10,
                      child: Icon(Icons.circle, size: 9, color: greycolo),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 8.0.w),
                    child: Text(
                      "Home",
                      style: TextStyle(fontFamily: "Poppins2"),
                    ),
                    alignment: Alignment.topLeft,
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      margin: EdgeInsets.symmetric(horizontal: 8.0.w),
                      child: loadAddress == true
                          ? Text(
                              "${("$street, $area, $area2, $city, $state, $country, $postalCode")}",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11.sp,
                                  fontFamily: "Poppins1"),
                            )
                          : Row(
                              children: [
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 1.5),
                                ),
                                SizedBox(width: 8),
                                Text("Getting address...",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 11.sp,
                                        fontFamily: "Poppins1")),
                              ],
                            )),
                  SizedBox(
                    height: 8.h,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 8.0.w),
                    child: Text(
                      "",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11.sp,
                          fontFamily: "Poppins1"),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: 0.9,
                    child: SizedBox(
                      height: 42.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: logoBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(
                              color: Color(0xff70bdf1),
                              width: 2.0,
                            ),
                          ),
                        ),
                        child: Text(
                          'Confirm your Location',
                          style: TextStyle(
                              fontFamily: "Poppins1",
                              color: Colors.white,
                              fontSize: 16.sp),
                        ),
                        onPressed: () async {
                          String latLong = latitudeCurrentLocation.toString() +
                              '/' +
                              longtitudeCurrentLocation.toString() +
                              '/' +
                              fullAddress;
                          if (Navigator.of(context).canPop()) {
                            Navigator.pop(context, latLong);
                          } else {
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => BottomBarPage(2)),
                                (Route<dynamic> route) => false);
                          }
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
