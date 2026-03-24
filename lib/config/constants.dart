class AppConstants {
  static const String appName = 'IWC - India with Civic Sense';
  static const String appShortName = 'IWCS';
  static const String appVersion = '1.0.0';

  // Complaint categories
  static const List<String> categories = [
    'plastic_waste',
    'river_pollution',
    'deforestation',
    'construction',
    'other',
  ];

  // Complaint statuses
  static const List<String> statuses = [
    'open',
    'in_progress',
    'resolved',
    'closed',
  ];

  // Indian cities / branches
  static const List<String> cities = [
    'Mumbai',
    'Delhi',
    'Bangalore',
    'Chennai',
    'Kolkata',
    'Hyderabad',
    'Pune',
    'Ahmedabad',
    'Jaipur',
    'Lucknow',
    'Chandigarh',
    'Bhopal',
    'Kochi',
    'Indore',
    'Nagpur',
    'Patna',
    'Dehradun',
    'Guwahati',
    'Varanasi',
    'Surat',
  ];

  // User roles
  static const String rolePublic = 'public';
  static const String roleVolunteer = 'volunteer';
  static const String roleAdmin = 'admin';

  // Hive box names
  static const String usersBox = 'users';
  static const String complaintsBox = 'complaints';
  static const String updatesBox = 'complaint_updates';
  static const String rtiBox = 'rti_requests';
  static const String settingsBox = 'settings';

  // Follow-up reminder days
  static const int followUpReminderDays = 3;
}
