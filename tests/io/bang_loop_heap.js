// The JS lane has no bump to read.
function heap_bump(k) {
  return 0;
}

io_eff(CID(heap.bump), heap_bump);
