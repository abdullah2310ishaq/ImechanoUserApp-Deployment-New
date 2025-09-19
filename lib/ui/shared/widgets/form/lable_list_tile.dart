import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:imechano/ui/provider/theme_provider.dart';

class LabelListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double widthFactor;

  const LabelListTile({
    Key? key,
    required this.subtitle,
    required this.title,
    this.widthFactor = 0.4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appModel = Provider.of<AppModel>(context);
    var size = MediaQuery.of(context).size;
    return Container(
        decoration: BoxDecoration(
            color: appModel.darkTheme ? Colors.black : Colors.grey.shade100,
            border: Border.all(
              color: appModel.darkTheme ? Colors.white : Colors.grey,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8.0)),
        width: size.width * widthFactor,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(3, 2, 3, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: appModel.darkTheme ? Colors.white : Colors.black,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 0, 12),
                child: Text(subtitle!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: appModel.darkTheme ? Colors.white : Colors.black,
                    )),
              )
            ],
          ),
        ));
  }
}
