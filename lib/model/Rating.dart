class RatingModel{
  late int AvisId;
  int? senderId;
  int? receiverId;
  String? comment;
  int? rating;

  RatingModel(this.AvisId,  this.senderId, this.receiverId, this.comment, this.rating);

  Map<String, dynamic> toJson() => {
    'senderId' : senderId,
    'receiverId': receiverId,
    'Comment': comment,
    'Rating': rating
  };

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
        json['AvisId'],
        json['senderId'],
        json['receiverId'],
        json['comment'],
        json['Rating']
    );
  }

}