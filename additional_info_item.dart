import 'package:flutter/material.dart';
class additional_info_item extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const additional_info_item({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });


  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [Icon(icon,size: 32,
      ),

        Text(label,
        ),
        const SizedBox(height:8),
        Text(value,style:const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        )
      ],

    );
  }
}
