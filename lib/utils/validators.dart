class Validators {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );
  static final RegExp _passwordRegExp = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
  );

  static final RegExp _dnsExp = RegExp(
      r'^(?:(([a-zA-Z0-9]([a-zA-Z0-9\\-]*[a-zA-Z0-9])?)\\.)*([A-Za-z0-9]([A-Za-z0-9\\-]*[A-Za-z0-9])?))$');
  static const ipv4Octet = "(?:25[0-5]|(?:[1-9]|1[0-9]|2[0-4])?[0-9])";
  static final RegExp _ipv4RegExp =
      RegExp("^(?:(?:(?:$ipv4Octet\\.){3}$ipv4Octet))\$");

  static bool isValidEmail(String email) {
    return _emailRegExp.hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return _passwordRegExp.hasMatch(password);
  }

  static bool isValidDnsName(String name) {
    return _dnsExp.hasMatch(name);
  }

  static bool isValidIPV4(String ip) {
    return _ipv4RegExp.hasMatch(ip);
  }
}
