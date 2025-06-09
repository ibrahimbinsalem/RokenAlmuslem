// import 'package:eco_store/controller/testController.dart';
// import 'package:eco_store/core/class/statusrequist.dart';
// import 'package:eco_store/core/constant/color.dart';
// import 'package:eco_store/view/widget/error/anmation_error.dart';
// import 'package:eco_store/view/widget/login&singup/custom_tetx.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:get/get.dart';
// import 'package:lottie/lottie.dart';

// class TestForm extends StatelessWidget {
//   const TestForm({super.key});


//   @override
//   Widget build(BuildContext context) {
//     Get.put(TestController());
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Test"),
        
//       ),


//       body: GetBuilder<TestController>(builder: (controller) {
//         if(controller.statusRequist == StatusRequist.loading){
//           return  Column(
//             children: [
//               Row(
//                 children: [
                  


//                   Padding(
//                      padding: const EdgeInsets.only(top: 50),
//                      child: AnmationError(image: "assets/js/loading_anmition.json",dimension: 400,maxWidth: 400,minWidth: 200,),
//                    ),

              

//                 ],
                

//               ),

//               CustomText(title: "Loading",)
//             ],
//           );


//         }else if(controller.statusRequist == StatusRequist.offlinefilure){
//           return Column(
//             children: [
//               Row(
               
//                 children: [


//                  Padding(
//                      padding: const EdgeInsets.only(top: 50),
//                      child: AnmationError(image: "assets/js/wifi_close.json",dimension: 400,maxWidth: 400,minWidth: 200,),
//                    ),
                 
//                 ],
                
//               ),

//               CustomText(title: "Check Your Internet ",color: ColorsApp.titles,)
//             ],
//           );


//         }else if(controller.statusRequist == StatusRequist.serverfilure){
//           return Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
                   
//                    Padding(
//                      padding: const EdgeInsets.only(top: 50),
//                      child: AnmationError(image: "assets/js/link_error.json",dimension: 400,maxWidth: 400,minWidth: 200,),
//                    ),
                  
//                 ],
//               ),

//               CustomText(title: "Soory No Connection With The Server")



              
             
//             ],

//           );

//         }else if(controller.statusRequist == StatusRequist.serverfilure){

//         return  CustomText(title: "No Data");


//         }else{
           
//            return ListView.builder(
            
//             itemCount: controller.data.length,
//             itemBuilder: (context, index) {
//              return Text("${controller.data}");
//            },);
//         }
        
//       },),
//     );
//   }
// }