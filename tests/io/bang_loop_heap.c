// The heap's bump (in pages) while bangs run on the GPU, else 0.
Term heap_bump_run(Env e, Term* f, IoWork* w) {
  return io_gpu ? a32_load_acq(a32_at(e.mem, H_BUMP)) : 0;
}

static void __attribute__((constructor)) heap_bump_use(void) {
  io_eff(CID(heap.bump), heap_bump_run, 0);
}
