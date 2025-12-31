extension DistrictIdExts on List<int> {
  List<Map<String, int>> toMapList(String key) {
    return map((id) => {key: id}).toList();
  }
}
