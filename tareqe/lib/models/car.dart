class Car {
  String? carNumber;
  int? numberOfSeat;
  String? carType;
  String? carColor;
  Car({this.carNumber, this.numberOfSeat,  this.carType,this.carColor});

  Car.fromJson(Map<String, dynamic> json) {
    carNumber = json['carNumber'];
    numberOfSeat = json['numberOfSeat'];
    carType = json['carType'];
    carColor = json['carColor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['carNumber'] = this.carNumber;
    data['numberOfSeat'] = this.numberOfSeat;
    data['carType'] = this.carType;
    data['carColor']= this.carColor;
    return data;
  }

  @override
  String toString() {
    return 'Car{carNumber: $carNumber, numberOfSeat: $numberOfSeat, carType: $carType, carColor: $carColor}';
  }
}


