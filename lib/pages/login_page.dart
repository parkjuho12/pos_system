// POS 시스템의 로그인 페이지입니다.
// 사용자는 식당을 선택하고 비밀번호를 입력하여 로그인합니다.
// 로그인 성공 시 결제 페이지(PaymentPage)로 이동합니다.

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'payment_page.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String _errorMessage = '';
  String _selectedRestaurant = '아질리아'; // 기본 선택

  Future<void> _login() async {
    if (_passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = '비밀번호를 입력해주세요.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('https://qr.pjhpjh.kr/seahawk1/auth/pos-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'password': _passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        if (data['token'] != null && data['user'] != null) {
          final String restaurantFromServer = data['user']['restaurant'];
          final String menuName;
          final int price;
          
          if (restaurantFromServer == '아질리아') {
            menuName = '아질리아 식권';
            price = 4800;
          } else if (restaurantFromServer == '피오니') {
            menuName = '피오니 식권';
            price = 5000;
          } else {
            throw Exception('알 수 없는 식당입니다.');
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (_) => PaymentPage(
                    token: data['token'],
                    restaurant: restaurantFromServer,
                    menuName: menuName,
                    price: price,
                  ),
            ),
          );
        } else {
          throw Exception('API 응답에 토큰이 없습니다.');
        }
      } else {
        final errorMessage =
            data['message'] ?? 'POS 비밀번호가 일치하지 않습니다';
        throw Exception(errorMessage);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'POS 비밀번호가 일치하지 않습니다.\n올바른 비밀번호를 확인해주세요.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: Image.asset('images/kbu_logo.png', height: 60),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Container(
                  constraints: BoxConstraints(maxWidth: screenWidth * 0.6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            '경복대학교 학식 POS 로그인',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        // 식당 선택 탭
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedRestaurant = '아질리아';
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    color: _selectedRestaurant == '아질리아'
                                        ? const Color.fromARGB(230, 2, 47, 123)
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      bottomLeft: Radius.circular(8),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.restaurant,
                                        color: _selectedRestaurant == '아질리아'
                                            ? Colors.white
                                            : Colors.grey[600],
                                        size: 28,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '아질리아',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: _selectedRestaurant == '아질리아'
                                              ? Colors.white
                                              : Colors.grey[700],
                                        ),
                                      ),
                                      Text(
                                        '지운관 1층',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _selectedRestaurant == '아질리아'
                                              ? Colors.white70
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedRestaurant = '피오니';
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    color: _selectedRestaurant == '피오니'
                                        ? const Color.fromARGB(230, 123, 2, 47)
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(8),
                                      bottomRight: Radius.circular(8),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.restaurant_menu,
                                        color: _selectedRestaurant == '피오니'
                                            ? Colors.white
                                            : Colors.grey[600],
                                        size: 28,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '피오니',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: _selectedRestaurant == '피오니'
                                              ? Colors.white
                                              : Colors.grey[700],
                                        ),
                                      ),
                                      Text(
                                        '창조관 1층',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _selectedRestaurant == '피오니'
                                              ? Colors.white70
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                        // 비밀번호 입력
                        TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          style: TextStyle(color: Colors.black, fontSize: 16),
                          decoration: InputDecoration(
                            labelText: 'POS 비밀번호',
                            hintText: _selectedRestaurant == '아질리아' 
                                ? '아질리아12!@'
                                : '피오니12!@',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            labelStyle: TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 1.2,
                              ),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey[600],
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          onSubmitted: (value) {
                            if (!_isLoading) _login();
                          },
                        ),
                        SizedBox(height: 16),
                        // 로그인 버튼
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedRestaurant == '아질리아'
                                  ? const Color.fromARGB(230, 2, 47, 123)
                                  : const Color.fromARGB(230, 123, 2, 47),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.login, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        '$_selectedRestaurant 로그인',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.red[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage,
                                      style: TextStyle(
                                        color: Colors.red[900],
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
