
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:rokenalmuslem/core/class/statusrequist.dart';
import 'package:rokenalmuslem/core/constant/imageassets.dart';
class HandlingDataView extends StatelessWidget {
  final StatusRequist statusRequest;
  final Widget widget;
  const HandlingDataView({
    Key? key,
    required this.statusRequest,
    required this.widget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return statusRequest == StatusRequist.loading
        ? Center(
          child: Lottie.asset(ImageAsset.loading, width: 250, height: 250),
        )
        : statusRequest == StatusRequist.offlinefilure
        ? Center(
          child: Lottie.asset(
            ImageAsset.offlinefilure,
            width: 250,
            height: 250,
            repeat: false,
          ),
        )
        : statusRequest == StatusRequist.serverfilure
        ? Center(
          child: Lottie.asset(
            ImageAsset.serverfilure,
            width: 250,
            height: 250,
            repeat: false,
          ),
        )
        : statusRequest == StatusRequist.filuere
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                ImageAsset.nodatafound,
                width: 250,
                height: 250,
                repeat: true,
              ),
            ],
          ),
        )
        : statusRequest == StatusRequist.noData
        ? Center(
          child: Lottie.asset(
            ImageAsset.noData,
            width: 250,
            height: 250,
            repeat: false,
          ),
        )
        : widget;
  }
}

class HandlingDataRequest extends StatelessWidget {
  final StatusRequist statusRequest;
  final Widget widget;
  const HandlingDataRequest({
    Key? key,
    required this.statusRequest,
    required this.widget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return statusRequest == StatusRequist.loading
        ? Center(
          child: Lottie.asset(ImageAsset.loading, width: 250, height: 250),
        )
        : statusRequest == StatusRequist.offlinefilure
        ? Center(
          child: Lottie.asset(
            ImageAsset.offlinefilure,
            width: 250,
            height: 250,
            repeat: false,
          ),
        )
        : statusRequest == StatusRequist.serverfilure
        ? Center(
          child: Lottie.asset(
            ImageAsset.serverfilure,
            width: 250,
            height: 250,
            repeat: false,
          ),
        )
        : statusRequest == StatusRequist.filuere
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Lottie.asset(
                ImageAsset.nodatafound,
                width: 250,
                height: 250,
                repeat: false,
              ),
            ],
          ),
        )
        : statusRequest == StatusRequist.noData
        ? Center(
          child: Lottie.asset(
            ImageAsset.noData,
            width: 250,
            height: 250,
            repeat: true,
          ),
        )
        : widget;
  }
}
