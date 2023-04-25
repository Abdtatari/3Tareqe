import 'package:uuid/uuid.dart';

class UserFeedback {
  String? id;
  String? title;
  String? content;
  String? photoPath;
  UserFeedback({this.title, this.content, this.photoPath,this.id});

  UserFeedback.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    content = json['content'];
    photoPath = json['photoPath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['content'] = this.content;
    data['photoPath'] = this.photoPath;
    return data;
  }
}