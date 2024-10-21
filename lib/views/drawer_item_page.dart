// Notification Preferences Page
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationPreferencesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notification Preferences')),
      body: Center(child: Text('Manage your notification preferences here.')),
    );
  }
}

// News Preferences Page
class NewsPreferencesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('News Preferences')),
      body: Center(child: Text('Manage your news preferences here.')),
    );
  }
}

// Privacy Policy Page
class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Privacy Policy')),
      body: Center(child: Text('Your privacy policy content goes here.')),
    );
  }
}

// Terms of Service Page
class TermsOfServicePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Terms of Service')),
      body: Center(child: Text('Your terms of service content goes here.')),
    );
  }
}