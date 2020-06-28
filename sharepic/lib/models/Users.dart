class User{
  final String name;
  final String email;
  final String dob;
  final String mobile;

  User({this.name,this.email,this.dob,this.mobile});

  toJson() {
    return {
      "name": name,
      "email": email,
      "dob": dob,
      "mobile":mobile,
    };
  }
}