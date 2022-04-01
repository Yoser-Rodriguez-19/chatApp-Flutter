import 'package:flutter/material.dart';

class BotonAzul extends StatelessWidget {
  
  final String texto;
  final Function()? onPressed;

  const BotonAzul({
    Key? key,
    required this.texto,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 5,
        primary: Colors.blue,
        shape: const StadiumBorder(),
      ),
      onPressed: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Center(child: Text(texto, style: const TextStyle(color: Colors.white, fontSize: 17),)),
      ),
    );
  }
}