import 'package:flutter/material.dart';

class CustomButtomAsmaAlah extends StatelessWidget {
   CustomButtomAsmaAlah({super.key, required this.name,required this.onTap});
final String name;
void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
         padding: const EdgeInsets.all(3),
         child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap:onTap ,
           child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(20)
            ),
            child: Center(child: Text("$name",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)),
           ),
         ),
       );
  }
}