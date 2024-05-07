
import 'package:flutter/material.dart';

import '../../shared/app_colors.dart';

class IconByCategory extends StatelessWidget {
  final String category;

  IconByCategory(this.category);

  @override
  Widget build(BuildContext context) {
    IconData categoryIcon;
    switch (category) {
      case 'Savings':
        categoryIcon = Icons.monetization_on;
        break;
      case 'Transfer':
        categoryIcon = Icons.swap_horiz;
        break;
      case 'Currency Exchange':
        categoryIcon = Icons.attach_money;
        break;
      case 'Food & Drinks':
        categoryIcon = Icons.restaurant;
        break;
      case 'Groceries':
        categoryIcon = Icons.shopping_cart;
        break;
      case 'Education':
        categoryIcon = Icons.school;
        break;
      case 'Shopping':
        categoryIcon = Icons.shopping_bag;
        break;
      case 'Utilities':
        categoryIcon = Icons.lightbulb;
        break;
      case 'Postal Services':
        categoryIcon = Icons.local_post_office;
        break;
      case 'Investments':
        categoryIcon = Icons.trending_up;
        break;
      case 'Health & Wellness':
        categoryIcon = Icons.favorite;
        break;
      case 'Transportation':
        categoryIcon = Icons.directions_car;
        break;
      case 'Travel':
        categoryIcon = Icons.airplanemode_active;
        break;
      case 'Entertainment':
        categoryIcon = Icons.movie;
        break;
      case 'Healthcare':
        categoryIcon = Icons.local_hospital;
        break;
      case 'Financial Services':
        categoryIcon = Icons.account_balance;
        break;
      case 'Income':
        categoryIcon = Icons.attach_money;
        break;
      case 'Expenses':
        categoryIcon = Icons.money_off;
        break;
      case 'Charity':
        categoryIcon = Icons.favorite_border;
        break;
      case 'Cash':
        categoryIcon = Icons.attach_money;
        break;
      case 'Cryptocurrency':
        categoryIcon = Icons.monetization_on;
        break;
      case 'Retail':
        categoryIcon = Icons.store;
        break;
      default:
        categoryIcon = Icons.category;
    }

    return Icon(categoryIcon, color: AppColors.logoBlue);
  }
}