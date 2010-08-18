char _g[32] = {"All good wishes \x00\x00\x00\x07"};

int main() {
  int *n = (int*)(&_g[0] + 16);
  *n += 1;

  return 0;
}
