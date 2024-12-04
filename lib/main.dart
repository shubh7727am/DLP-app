import 'package:dlp/about_us.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:web_socket_channel/io.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(

          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          useMaterial3: true,
        ),
        routes: {
          "/" : (context)=> const MyHomePage(title: "Tilt Rotor Mechanism"),

        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double rotorSpeed = 0;
  double tiltAngle = 0;
  double rollAngle = 0;
  bool startSystem = false;
  int approximatedRotorSpeed = 0;
  int approximatedTiltAngle = 0;
  TextEditingController rollAngleTextController = TextEditingController();
  TextEditingController tiltAngleTextController = TextEditingController();

  var channel = IOWebSocketChannel.connect('ws://192.168.163.209/ws');
  bool changeIpAddress = false;
  String counterText = "ENTER VALID IP ADDRESS";
  TextEditingController ipAddressController = TextEditingController() ;
  TextEditingController inputVoltageController = TextEditingController();
  TextEditingController tiltAngleController = TextEditingController();
  TextEditingController rollAngleController = TextEditingController();
  double inputVoltage = 11.1;
  int tiltAngleCalib = 90;
  int rollAngleCalib = 90;
  int approximatedRollAngle = 0;


  void convertRotorSpeed(double speed) async{
    double newRotorSpeed = speed*(1000)*(inputVoltage);

    setState(() {
      approximatedRotorSpeed = newRotorSpeed.toInt();
    });

  }
  void convertRollAngle(double angle) async{
    double newRollAngle = angle*rollAngleCalib;

    setState(() {
      approximatedRollAngle = newRollAngle.toInt();
    });

  }
  void convertTitleAngle(double angle) async{
    double newTiltAngle = tiltAngle*(2*tiltAngleCalib);


    setState(() {
      approximatedTiltAngle = newTiltAngle.toInt();
    });

  }
  int countIpDots(String ipAddressInput) {
    int count = 0;
    for (int k = 0; k < ipAddressInput.length; k++) {
      if (ipAddressInput[k] == ".") {
        count++;
      }
    }
    return count;
  }

  int pwmValueMotorSpeed(int rpm , double inputVoltage ){
    int pwmValue = 0;
    double pwmSlot = inputVoltage/255;
    pwmValue = rpm~/(1000*pwmSlot);
    return pwmValue;
  }
  
  @override
  Widget build(BuildContext context) {
   
    return StreamBuilder(
      stream: channel.stream,
      builder: (context, snap){
        return Stack(
            children: [Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                leading: ZoomTapAnimation(onTap: (){
                  Navigator.push(context,MaterialPageRoute(builder: (context) => const  Info()));

                },child: const Icon(Icons.info_outline)),

                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10))),

                title: Text(widget.title,style: const TextStyle(color: Colors.black),),
                centerTitle: true,
              ),
              body: Center(
                // Center is a layout widget. It takes a single child and positions it
                // in the middle of the parent.
                child: Column(

                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'RotorSpeed :  $approximatedRotorSpeed RPM ',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Slider(thumbColor: Colors.blue.shade900,activeColor: Colors.white,inactiveColor: Colors.grey,label: "Throttle",value: rotorSpeed, onChangeEnd: (value){

                      int pwmValueNow = pwmValueMotorSpeed(approximatedRotorSpeed, inputVoltage);
                      channel.sink.add("S$pwmValueNow");

                    },onChanged: (value){
                      setState(() {
                        rotorSpeed = value.toDouble();
                        convertRotorSpeed(rotorSpeed);
                      });

                    }),
                    Text(
                      'RollAngle :  $approximatedRollAngle degree ',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Slider(thumbColor: Colors.green.shade900,activeColor: Colors.white,inactiveColor: Colors.grey,label: "Throttle2",value: rollAngle, onChangeEnd: (value){


                      channel.sink.add("R$approximatedRollAngle");

                    },onChanged: (value){
                      setState(() {
                        rollAngle = value.toDouble();
                        convertRollAngle(rollAngle);
                      });

                    }),
                    Text(
                      'Tilt angle :  $approximatedTiltAngle degree',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Slider(onChangeEnd: (value){
                      channel.sink.add("T$approximatedTiltAngle");
                    },min: -0.5,max: 0.5,thumbColor: Colors.orange.shade900,activeColor: Colors.white,inactiveColor: Colors.white,label: "Throttle",value: tiltAngle, onChanged: (value){
                      setState(() {
                        tiltAngle = value.toDouble();
                        convertTitleAngle(tiltAngle);
                      });

                    }),
                    // Container(
                    //   decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.circular(10),
                    //   ),
                    //   child: Column(
                    //
                    //     children: [TextField(
                    //       controller: tiltAngleTextController,
                    //       keyboardType: TextInputType.number,
                    //       maxLength: 2,
                    //       style: const TextStyle(color: Colors.black),
                    //       decoration: InputDecoration(
                    //         labelStyle: const TextStyle(
                    //             color: Colors.black,
                    //         ),
                    //         labelText: 'TiltAngle',
                    //         counterStyle: const TextStyle(
                    //             color: Colors.red, fontWeight: FontWeight.bold),
                    //       ),
                    //       onSubmitted: (value){
                    //         setState(() {
                    //           int angleGiven = int.tryParse(tiltAngleTextController.text)!;//inputVoltageController.text.toString() as double ;
                    //           if(angleGiven > 90 || angleGiven < 0 ){
                    //             showSimpleNotification(const Text("Angle Should be int the range 0-90 degrees only",style: TextStyle(color: Colors.white),),background: Colors.red.shade900);
                    //             tiltAngleTextController.clear();
                    //           }
                    //
                    //         });
                    //       },
                    //     ),
                    //       SizedBox(height: 10,),
                    //       TextField(
                    //         controller: rollAngleTextController,
                    //         keyboardType: TextInputType.number,
                    //         maxLength: 2,
                    //         style: const TextStyle(color: Colors.black),
                    //         decoration: InputDecoration(
                    //           labelStyle: const TextStyle(
                    //               color: Colors.black,
                    //               ),
                    //           labelText: 'RollAngle',
                    //           counterStyle: const TextStyle(
                    //               color: Colors.red, fontWeight: FontWeight.bold),
                    //         ),
                    //         onSubmitted: (value){
                    //           setState(() {
                    //             int angleGiven = int.tryParse(rollAngleTextController.text)!;//inputVoltageController.text.toString() as double ;
                    //             if(angleGiven > 90 || angleGiven < 0 ){
                    //               showSimpleNotification(const Text("Angle Should be int the range 0-90 degrees only",style: TextStyle(color: Colors.white),),background: Colors.red.shade900);
                    //               rollAngleTextController.clear();
                    //             }
                    //
                    //           });
                    //         },
                    //       ),
                    //       SizedBox(height: 10,),
                    //       TextButton(onPressed: (){
                    //         channel.sink.add("R${int.tryParse(rollAngleTextController.text)!}");
                    //         rollAngleTextController.clear();
                    //         channel.sink.add("T${int.tryParse(tiltAngleTextController.text)!}");
                    //         tiltAngleTextController.clear();
                    //         showSimpleNotification(Text("Rotating...",),background: Colors.green,);
                    //
                    //       }, child: const Text("ROTATE"),),
                    //
                    //     ]
                    //   ),
                    // ),

                    // Joystick(listener: (details){
                    // }),
                  ],
                ),
              ),
              // This trailing comma makes auto-formatting nicer for build methods.
            ),

              if(!startSystem) Container(color: Colors.black.withOpacity(0.7),),
              if(!startSystem) SafeArea(
                child: Align(alignment: Alignment.bottomRight, child: ZoomTapAnimation(
                  child: const Icon(Icons.settings,color: Colors.white,size: 35,),
                  onTap: (){

                    setState(() {
                      changeIpAddress = !changeIpAddress;
                    });




                  },
                ),),
              ),
              Align(alignment: Alignment.bottomCenter, child: ZoomTapAnimation(
                child: FloatingActionButton(

                  backgroundColor: Colors.white,
                  elevation: 0,

                  onPressed: (){
                    if(!startSystem){
                      channel.sink.add("turnON");
                    }
                    if(startSystem){
                      channel.sink.add("turnON");
                      channel.sink.add("R0");
                      channel.sink.add("T0");
                      rotorSpeed = 0;
                      approximatedRotorSpeed = 0;
                      rollAngle = 0;
                      approximatedRollAngle = 0;
                      tiltAngle = 0;
                      approximatedTiltAngle = 0;

                    }
                    setState(() {
                      startSystem = !startSystem;
                    });

                  },
                  tooltip: "Operate",
                  child: startSystem?  const Icon(Icons.stop_circle,color: Colors.redAccent,size: 35,) : const Icon(Icons.play_arrow,color: Colors.green,size: 35,) ,
                ),
              ),),


              if(changeIpAddress) Scaffold(
                appBar: AppBar(
                  title: IconButton(onPressed: (){
                    setState(() {
                      changeIpAddress = !changeIpAddress;
                    });
                  }, icon:const  Icon(Icons.close,color: Colors.black,)),
                ),
                backgroundColor: Colors.blue.shade900.withOpacity(0.4),
                body: Column(
                  children: [ZoomTapAnimation(
                    onTap: (){
                      setState(() {
                        startSystem = !startSystem;
                        ipAddressController.clear();

                      });
                    },
                    child: TextField(
                      controller: ipAddressController,
                      keyboardType: TextInputType.number,
                      maxLength: 15,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelStyle: const TextStyle(
                            color: Colors.white,
                            fontStyle: FontStyle.italic),
                        labelText: 'New ip Address',
                        counterText: counterText,
                        counterStyle: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      onChanged: (value) {
                        // You can add further validation or processing here
                        if (countIpDots(
                            ipAddressController.text.toString()) <
                            3) {
                          setState(() {
                            counterText = "please enter a valid ip address";
                          });
                        } else {
                          setState(() {
                            counterText = "";
                          });
                        }
                      },
                      onSubmitted: (value){
                        setState(() {
                          channel = IOWebSocketChannel.connect('ws://${ipAddressController.text.toString()}/ws');
                          ipAddressController.clear();
                          changeIpAddress = !changeIpAddress;
                          showSimpleNotification(Text("ip address changed to ${ipAddressController.text.toString()}",),background: Colors.green,);
                        });
                      },
                    ),
                  ),


                    TextField(
                      controller: inputVoltageController,
                      keyboardType: TextInputType.number,
                      maxLength: 5,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelStyle: const TextStyle(
                            color: Colors.white,
                            fontStyle: FontStyle.italic),
                        labelText: 'Update input voltage for bldc',
                        counterStyle: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      onSubmitted: (value){
                        setState(() {
                          inputVoltage = double.tryParse(inputVoltageController.text)!;//inputVoltageController.text.toString() as double ;
                          inputVoltageController.clear();
                          changeIpAddress = !changeIpAddress;
                          showSimpleNotification(Text("input voltage changed to $inputVoltage",),background: Colors.green,);

                        });
                      },
                    ),
                    TextField(
                      controller: tiltAngleController,
                      keyboardType: TextInputType.number,
                      maxLength: 5,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelStyle: const TextStyle(
                            color: Colors.white,
                            fontStyle: FontStyle.italic),
                        labelText: 'TiltAngle',
                        counterStyle: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      onSubmitted: (value){
                        setState(() {
                          tiltAngleCalib = int.tryParse(tiltAngleController.text)!;//inputVoltageController.text.toString() as double ;
                          tiltAngleController.clear();
                          changeIpAddress = !changeIpAddress;
                          showSimpleNotification(Text("tiltAngle set to range -$tiltAngleCalib to +$tiltAngleCalib",),background: Colors.green,);

                        });
                      },
                    ),
                    TextField(
                      controller: rollAngleController,
                      keyboardType: TextInputType.number,
                      maxLength: 5,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelStyle: const TextStyle(
                            color: Colors.white,
                            fontStyle: FontStyle.italic),
                        labelText: 'RollAngle',
                        counterStyle: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      onSubmitted: (value){
                        setState(() {
                          rollAngleCalib= int.tryParse(rollAngleController.text)!;//inputVoltageController.text.toString() as double ;
                          rollAngleController.clear();
                          changeIpAddress = !changeIpAddress;
                          showSimpleNotification(Text("RollAngle changed to 0 to +$rollAngleCalib",),background: Colors.green,);

                        });
                      },
                    ),


                  ]
                ),
              ),


            ]
        );

      },

    );
  }
}
