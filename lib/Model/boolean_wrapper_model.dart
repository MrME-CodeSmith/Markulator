class Boolean {
  bool value;

  Boolean({required this.value});

  void operator &(Boolean v) {
    v.value = !v.value;
  }

  bool get wrappedValue {
    return value;
  }
}
