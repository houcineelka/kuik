import 'package:flutter/material.dart';

const Map<String, IconData> categoryIcons = {
  'Téléphone': Icons.smartphone_outlined,
  'Clés': Icons.vpn_key_outlined,
  'Portefeuille': Icons.account_balance_wallet_outlined,
  'CIN/Passeport': Icons.badge_outlined,
  'Sac': Icons.shopping_bag_outlined,
  'Bagage': Icons.luggage_outlined,
  'Animal': Icons.pets_outlined,
  'Vêtement': Icons.checkroom_outlined,
  'Électronique': Icons.devices_other_outlined,
  'Autre': Icons.category_outlined,
};

IconData iconForCategory(String category) => categoryIcons[category] ?? Icons.category_outlined;
