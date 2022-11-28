class Boolean {
  bool value;

  Boolean({required this.value});

  operator &(Boolean v) {
    v.value = !v.value;
  }

  bool get wrappedValue {
    return value;
  }
}
