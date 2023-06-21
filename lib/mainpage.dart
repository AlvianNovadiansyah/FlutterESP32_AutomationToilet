import 'dart:async';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'CircleProgress.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin
{
  final user = FirebaseAuth.instance.currentUser!;
  int _counter = 0;
  bool _value = false;
  bool isLoading = false;
  late bool _ledV = false;
  late bool _fanV = false;
  late AnimationController progressController;
  late Animation<double> touchAnimation;
  late Animation<double> HumpAnimation;
  late Animation<double> DisAnimation;
  late StreamSubscription _ledSubscription;
  late StreamSubscription _fanSubscription;
  final DatabaseReference _testref = FirebaseDatabase.instance.ref();

  void _incrementCounter() {
    if(mounted){
      setState(() {
        _value = !_value;
        if (_value == true) {
          _counter = 1;
        }
        else {
          _counter = 0;
        }
      });
    }
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if(mounted){
        _retrievedata();
        _ledSubscription =
            _testref.ref.child("ESP32_DEVICE/SwitchLed").onValue.listen((event) {
          if(mounted){
            setState(() {
              String led1 = event.snapshot.value.toString();
              if(led1.toLowerCase() == "true"){
                _ledV = true;
                print(_ledV);
              }else{
                _ledV = false;
                print(_ledV);
              }
            });
          }
        });
        _fanSubscription =
            _testref.ref.child("ESP32_DEVICE/SwitchFan").onValue.listen((event) {
          if(mounted){
            setState(() {
              String fan1 = event.snapshot.value.toString();
              if(fan1.toLowerCase() == "true"){
                _fanV = true;
                print(_fanV);
              }else{
                _fanV = false;
                print(_fanV);
              }
            });
          }
        });
      }
    });
  }

  _retrievedata() async{
    _testref.child("ESP32_DEVICE").onValue.listen((event) {
      final user1 = event.snapshot.child('Temperature').value;
      final user2 = event.snapshot.child("Humidity").value;
      final user3 = event.snapshot.child("Distance").value;

      String simpan = user1.toString();
      String simpan1 = user2.toString();
      String simpan2 = user3.toString();
      double Temp = double.parse(simpan);
      double Hump = double.parse(simpan1);
      double Dist = double.parse(simpan2);

      isLoading = true;
      if(mounted){
        _MyHomePageInit(Temp, Hump, Dist);
      }
    });
  }

  _MyHomePageInit(double Temp, double Hump, double Dist) {
    if(mounted){
      progressController = AnimationController(
          vsync: this, duration: Duration(milliseconds: 2000)); //2s

      touchAnimation =
      Tween<double>(begin: 0, end: Temp).animate(progressController)
        ..addListener(() {
          if(mounted){
            setState(() {});
          }
        });

      HumpAnimation =
      Tween<double>(begin: 0, end: Hump).animate(progressController)
        ..addListener(() {
          if(mounted){
            setState(() {});
          }
        });

      DisAnimation =
      Tween<double>(begin: 0, end: Dist).animate(progressController)
        ..addListener(() {
          if(mounted){
            setState(() {});
          }
        });

      progressController.forward();
    }

  }

  @override
  void dispose() {
    if(mounted){
      _fanSubscription.cancel();
      _ledSubscription.cancel();
      progressController.dispose();
      super.dispose();
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("IoT Monitoring", style: TextStyle(color: Colors.lightBlueAccent),),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder (
          stream: _testref.child("ESP32_DEVICE").onValue,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if(snapshot.hasData && !snapshot.hasError) {
              return SingleChildScrollView(
                child: isLoading? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(minHeight: 50),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.lightBlueAccent,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(40.0),
                            topLeft: Radius.circular(40.0),
                            bottomLeft: Radius.circular(40.0),
                            bottomRight: Radius.circular(40.0),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                          child: Column(
                            children: [
                              SizedBox(height: 20,),
                              SafeArea(
                                child: Row(
                                  children: [
                                    Text("Welcome Back", style: TextStyle(
                                      fontSize: 20, color: Colors.grey[200],
                                    ),)
                                  ],
                                ),
                              ),
                              SizedBox(height: 8,),
                              SafeArea(
                                child: Wrap(
                                  children: [
                                    Text("Hello, ", style: TextStyle(fontSize: 28,
                                        fontWeight: FontWeight.bold), ),
                                    SizedBox(width: 12,),
                                    Text(user.email!, style: TextStyle(fontSize: 28,
                                        fontWeight: FontWeight.bold),),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20,),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                    minimumSize: Size.fromHeight(50),
                                    elevation: 0,
                                    backgroundColor: Colors.transparent,
                                    alignment: Alignment(-1, -1)
                                ), onPressed: () => FirebaseAuth.instance.signOut(),
                                icon: Icon(Icons.arrow_back) ,label: Text(
                                "Sign Out", style: TextStyle(fontSize: 24),
                              ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Row(
                      children: [
                        Padding(padding: EdgeInsets.symmetric(horizontal: 40),
                          child: Text("Smart Devices",
                            style: TextStyle(color: Colors.black, fontSize: 20),),
                        ),
                      ],
                    ),
                    SizedBox(height: 20,),
                   SingleChildScrollView(
                     scrollDirection: Axis.horizontal,
                     child: Padding(
                       padding: EdgeInsets.symmetric(horizontal: 40),
                       child: Row(
                         children: [
                           ConstrainedBox(
                             constraints: BoxConstraints(minHeight: 50),
                             child: DecoratedBox(
                               decoration: BoxDecoration(
                                 color: Colors.white,
                                 borderRadius: BorderRadius.all(Radius.circular(16)),
                               ),
                               child: Column(
                                 children: <Widget>[
                                   SizedBox(height: 10.0,),
                                   Text("Temperature Sensor",
                                     style: TextStyle(color: Colors.black
                                     ),
                                   ),
                                   Text("Device",
                                     style: TextStyle(color: Colors.black),),
                                   SizedBox(height: 10.0,),
                                   CustomPaint(
                                     foregroundPainter:
                                     CircleProgress(touchAnimation.value, true),
                                     child: Container(
                                       constraints: BoxConstraints(minWidth: 150, minHeight: 150),
                                       child: Center(
                                         child: Column(
                                           mainAxisAlignment: MainAxisAlignment.center,
                                           children: <Widget>[
                                             Text('TEmperature',
                                               style: TextStyle(color: Colors.black),),
                                             Container(
                                               child: Row(
                                                 mainAxisAlignment: MainAxisAlignment.center,
                                                 children: <Widget>[
                                                   Text(
                                                     '${touchAnimation.value.toInt()}',
                                                     style: TextStyle(
                                                         fontSize: 28,
                                                         fontWeight: FontWeight.bold,
                                                         color: Colors.black),
                                                   ),
                                                   Text(
                                                     'C',
                                                     style: TextStyle(
                                                         fontSize: 12,
                                                         fontWeight: FontWeight.bold
                                                         ,fontFeatures: [FontFeature.superscripts()],
                                                         color: Colors.black),
                                                   ),
                                                 ],
                                               ),
                                             )
                                           ],
                                         ),
                                       ),
                                     ),
                                   ),
                                   SizedBox(height: 10,),
                                 ],
                               ),
                             ),
                           ),
                           SizedBox(width: 20.0,),
                           ConstrainedBox(
                             constraints: BoxConstraints(minHeight: 50),
                             child: DecoratedBox(
                               decoration: BoxDecoration(
                                 color: Colors.white,
                                 borderRadius: BorderRadius.all(Radius.circular(16)),
                               ),
                               child: Column(
                                 children: <Widget>[
                                   SizedBox(height: 10,),
                                   Text("Humidity Sensor",
                                     style: TextStyle(color: Colors.black
                                     ),
                                   ),
                                   Text("Device",
                                     style: TextStyle(color: Colors.black
                                     ),
                                   ),
                                   SizedBox(height: 10,),
                                   CustomPaint(
                                     foregroundPainter:
                                     CircleProgress(HumpAnimation.value, false),
                                     child: Container(
                                       constraints: BoxConstraints(minHeight: 150, minWidth: 150),
                                       child: Center(
                                         child: Column(
                                           mainAxisAlignment: MainAxisAlignment.center,
                                           children: <Widget>[
                                             Text('Humidity',
                                               style: TextStyle(color: Colors.black),),
                                             Container(
                                               child: Row(
                                                 mainAxisAlignment: MainAxisAlignment.center,
                                                 children: <Widget>[
                                                   Text(
                                                     '${HumpAnimation.value.toInt()}',
                                                     style: TextStyle(
                                                         fontSize: 28,
                                                         fontWeight: FontWeight.bold,
                                                         color: Colors.black),
                                                   ),
                                                   Text(
                                                     '%',
                                                     style: TextStyle(
                                                         fontSize: 12,
                                                         fontWeight: FontWeight.bold
                                                         ,fontFeatures: [FontFeature.superscripts()],
                                                         color: Colors.black),
                                                   ),
                                                 ],
                                               ),
                                             )
                                           ],
                                         ),
                                       ),
                                     ),
                                   ),
                                   SizedBox(height: 10,),
                                 ],
                               ),
                             ),
                           ),
                         ],
                       ),
                     ),
                   ),
                    SizedBox(height: 20,),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(padding: EdgeInsets.symmetric(horizontal: 40.0),
                        child: Row(
                          children: [
                            Container(
                              constraints: BoxConstraints(minHeight: 150, minWidth: 150,),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(16)),
                                ),
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(height: 10,),
                                    Text("LED Device", style: TextStyle(color: Colors.black),
                                    ),
                                    SizedBox(height: 10,),
                                    Icon(Icons.lightbulb, size: 40,
                                      semanticLabel: "Light Bulb Icon Indicator",
                                      color: Colors.black,
                                    ),
                                    SizedBox(height: 10,),
                                    Text( _ledV? "Lampu ON" : "Lampu OFF",
                                      style: TextStyle(color: Colors.black),),
                                    SizedBox(height: 10,),
                                    FlutterSwitch(
                                      width: 125.0,
                                      height: 50.0,
                                      valueFontSize: 20.0,
                                      toggleSize: 40.0,
                                      value: _ledV,
                                      borderRadius: 30.0,
                                      padding: 8.0,
                                      activeColor: Colors.greenAccent,
                                      inactiveColor: Colors.redAccent,
                                      activeText: "ON",
                                      inactiveText: "OFF",
                                      showOnOff: true,
                                      activeTextColor: Colors.white,
                                      inactiveTextColor: Colors.white,
                                      activeIcon: Icon(Icons.done,
                                        color: Colors.greenAccent,),
                                      inactiveIcon: Icon(Icons.timer_off,
                                        color: Colors.redAccent,),
                                      onToggle: (val){
                                        if(mounted){
                                          setState(() {
                                            _ledV = val;
                                            WriteLed(val);
                                          });
                                        }
                                      },
                                    ),
                                    SizedBox(height: 10,),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 20.0,),
                            ConstrainedBox(
                              constraints: BoxConstraints(minHeight: 50),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(16)),
                                ),
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(height: 10,),
                                    Text("Distance Sensor",
                                      style: TextStyle(color: Colors.black
                                      ),
                                    ),
                                    Text("Device",
                                      style: TextStyle(color: Colors.black
                                      ),
                                    ),
                                    SizedBox(height: 10,),
                                    CustomPaint(
                                      foregroundPainter:
                                      CircleProgress(DisAnimation.value, false),
                                      child: Container(
                                        constraints: BoxConstraints(minHeight: 150, minWidth: 150),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text('Distance',
                                                style: TextStyle(color: Colors.black),),
                                              Container(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(
                                                      '${DisAnimation.value.toInt()}',
                                                      style: TextStyle(
                                                          fontSize: 28,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.black),
                                                    ),
                                                    Text(
                                                      'CM',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold
                                                          ,fontFeatures: [FontFeature.superscripts()],
                                                          color: Colors.black),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10,),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0,),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 40.0),
                      child: Row(
                        children: [
                          Container(
                            constraints: BoxConstraints(minHeight: 150, minWidth: 150,),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(16)),
                              ),
                              child: Column(
                                children: <Widget>[
                                  SizedBox(height: 10,),
                                  Text("Fan Device",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  SizedBox(height: 10,),
                                  Icon(Icons.settings_outlined,
                                    color: Colors.black,
                                    semanticLabel: "Fan Device Icon Indicator",
                                  size: 60.0,),
                                  SizedBox(height: 10,),
                                  Text( _fanV? "Kipas ON" : "Kipas OFF",
                                    style: TextStyle(color: Colors.black),),
                                  SizedBox(height: 10,),
                                  FlutterSwitch(
                                    width: 125.0,
                                    height: 50.0,
                                    valueFontSize: 20.0,
                                    toggleSize: 40.0,
                                    value: _fanV,
                                    borderRadius: 30.0,
                                    padding: 8.0,
                                    activeColor: Colors.greenAccent,
                                    inactiveColor: Colors.redAccent,
                                    activeText: "ON",
                                    inactiveText: "OFF",
                                    showOnOff: true,
                                    activeTextColor: Colors.white,
                                    inactiveTextColor: Colors.white,
                                    activeIcon: Icon(Icons.done,
                                      color: Colors.greenAccent,),
                                    inactiveIcon: Icon(Icons.timer_off,
                                      color: Colors.redAccent,),
                                    onToggle: (val){
                                      if(mounted){
                                        setState(() {
                                          _fanV = val;
                                          WriteFan();
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
                    : Center(
                      child: Text(
                          'Loading...',
                          style: TextStyle(fontSize: 30,
                           fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),

              );

            } else {
              return Container();
            }
          },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (){
          _incrementCounter();
          WriteData();
        },
        tooltip: 'Tombol Power',
        icon: _value ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off),
        label: _value ? Text("System ON") : Text("System OFF"),
      ),
    );
  }

  Future<void> WriteFan() async{
  _testref.update({"ESP32_DEVICE/SwitchFan" : _fanV});
  }

  Future<void> WriteLed(value) async {
    if(mounted){
      setState(() {
        _ledV = value;
      });
    }
    _testref.update({"ESP32_DEVICE/SwitchLed" : _ledV});
  }

  Future<void> WriteData() async {
    _testref.update({"SYSTEM" : _value});
    _testref.update({"Switch" : _counter});
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
