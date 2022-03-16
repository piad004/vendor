class UnitModel {
  dynamic id;
  dynamic name;
  dynamic uiType;

  UnitModel(this.id, this.name, this.uiType);

  UnitModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    uiType = json['ui_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['ui_type'] = this.uiType;
    return data;
  }
}