import 'package:flutter/material.dart';



class Info extends StatefulWidget {
  const Info({super.key});

  @override
  State<Info> createState() => _InfoState();
}

class _InfoState extends State<Info> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(iconTheme: const IconThemeData(color: Colors.white),title:const  Text("About project",style: TextStyle(color: Colors.white),),backgroundColor: Colors.black,),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("By- \n",style: TextStyle(color: Colors.white),),
            Text("Shubham Choudhary",style: TextStyle(color: Colors.white),),
            SizedBox(height: 10,),






          ],
        ),
      ),
    );
  }
}
