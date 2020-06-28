class ImageModel{
  final String fileName;
  final String hashTag;
  final String date;
  final String userid;
  final String url;

  ImageModel({this.fileName,this.hashTag,this.date,this.userid,this.url});

  toJson() {
    return {
      "filename": fileName,
      "hashtag": hashTag,
      "date": date,
      "userid":userid,
      "url":url
    };
  }
  
}