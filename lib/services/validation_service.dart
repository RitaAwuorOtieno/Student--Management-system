/// Input validation service for student management system
class ValidationService {
  /// Validate registration number (alphanumeric, 3-20 characters)
  static String? validateRegistrationNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Registration number is required';
    }
    if (value.trim().length < 3) {
      return 'Registration number must be at least 3 characters';
    }
    if (value.trim().length > 20) {
      return 'Registration number must not exceed 20 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9\-_]+$').hasMatch(value.trim())) {
      return 'Registration number can only contain letters, numbers, hyphens, and underscores';
    }
    return null;
  }

  /// Validate student name (letters and spaces only, not empty)
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Student name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 100) {
      return 'Name must not exceed 100 characters';
    }
    if (!RegExp(r"^[a-zA-Z\s'.-]+$").hasMatch(value.trim())) {
      return 'Name can only contain letters, spaces, and apostrophes';
    }
    return null;
  }

  /// Validate course/program name
  static String? validateCourse(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Course/Program is required';
    }
    if (value.trim().length < 2) {
      return 'Course name must be at least 2 characters';
    }
    if (value.trim().length > 100) {
      return 'Course name must not exceed 100 characters';
    }
    return null;
  }

  /// Validate year of study (1-7 typically)
  static String? validateYear(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Year of study is required';
    }
    final year = int.tryParse(value.trim());
    if (year == null) {
      return 'Year must be a valid number';
    }
    if (year < 1) {
      return 'Year must be at least 1';
    }
    if (year > 7) {
      return 'Year must not exceed 7';
    }
    return null;
  }

  /// Validate email address (optional but if provided, must be valid)
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate phone number (optional but if provided, must be valid Kenya format)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    final phone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final phoneRegex = RegExp(r'^(?:\+254|254|0)?([17]\d{8})$');
    if (!phoneRegex.hasMatch(phone)) {
      return 'Please enter a valid Kenyan phone number (e.g., 0722123456 or +254722123456)';
    }
    return null;
  }

  /// Validate gender selection
  static String? validateGender(String? value) {
    if (value == null || value.isEmpty) {
      return 'Gender is required';
    }
    if (!['Male', 'Female', 'Other'].contains(value)) {
      return 'Please select a valid gender';
    }
    return null;
  }

  /// Trim and normalize text input
  static String normalizeText(String value) {
    return value.trim();
  }

  /// Format phone number to standard format
  static String formatPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.startsWith('0')) {
      return '+254${cleaned.substring(1)}';
    } else if (cleaned.startsWith('254')) {
      return '+$cleaned';
    } else if (!cleaned.startsWith('+')) {
      return '+254$cleaned';
    }
    return cleaned;
  }
}
