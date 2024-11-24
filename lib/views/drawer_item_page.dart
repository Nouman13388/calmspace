import 'package:flutter/material.dart';

// Notification Preferences Page
class NotificationPreferencesPage extends StatefulWidget {
  const NotificationPreferencesPage({super.key});

  @override
  _NotificationPreferencesPageState createState() =>
      _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState
    extends State<NotificationPreferencesPage> {
  bool notificationsEnabled = true;
  bool assessmentReminders = false;
  bool mindfulnessReminders = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification Preferences"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Manage your notification preferences to stay informed and on track with your mental health journey.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text("Enable Notifications"),
              value: notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  notificationsEnabled = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text("Assessment Reminders"),
              value: assessmentReminders,
              onChanged: (value) {
                setState(() {
                  assessmentReminders = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text("Mindfulness Reminders"),
              value: mindfulnessReminders,
              onChanged: (value) {
                setState(() {
                  mindfulnessReminders = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

// News Preferences Page
class NewsPreferencesPage extends StatelessWidget {
  const NewsPreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('News Preferences')),
      body: const Center(
        child: Text('Manage your news preferences here.'),
      ),
    );
  }
}

// Privacy Policy Page
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Privacy Policy",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text(
                "CalmSpace is committed to protecting your privacy and ensuring that your personal data is handled securely. "
                "This Privacy Policy outlines how we collect, use, and protect your data within the CalmSpace app.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              Text("Data Collection",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(
                "We collect personal data such as your name, email, and assessment responses to provide personalized mental health support. "
                "All data is securely stored and used strictly for enhancing your experience on CalmSpace.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              Text("Data Security",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(
                "We use advanced security measures, including end-to-end encryption, to protect your personal data and maintain confidentiality. "
                "Your data is accessible only to authorized personnel.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              Text("Data Sharing",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(
                "CalmSpace does not share your personal data with third parties unless required by law. We are committed to respecting your privacy rights.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              Text("User Consent",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(
                "By using CalmSpace, you consent to our data collection and usage practices as outlined in this policy. "
                "You may request data deletion or updates at any time.",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Terms of Service Page
class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms of Service"),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Terms of Service",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text(
                "Welcome to CalmSpace! By using this app, you agree to the following terms and conditions governing its use.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              Text("Use of CalmSpace",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(
                "CalmSpace provides mental health resources, assessments, and video conferencing to support your mental well-being. "
                "The app is not a substitute for professional mental health services.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              Text("Account Responsibilities",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(
                "You are responsible for maintaining the confidentiality of your account and for all activities under your account.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              Text("Privacy and Security",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(
                "CalmSpace is committed to safeguarding your data. By using the app, you consent to our Privacy Policy.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              Text("Modification of Terms",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(
                "CalmSpace reserves the right to modify these terms at any time. You will be notified of changes through the app.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              Text("Limitation of Liability",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(
                "CalmSpace is not liable for any damages arising from your use of the app or any reliance on its content.",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
