import 'package:flutter/material.dart';
import 'package:tareqe/models/theme.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      color: appTheme.mainColor,
      child: SizedBox(
          width: double.infinity,
          height: size.height * 0.3,
          child: Image.asset('assets/images/friendship.png'),
    )
    );
  }
}
