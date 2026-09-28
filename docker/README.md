# Agave seccomp profile

`seccomp-agave.json` is Docker/Moby's default seccomp profile, downloaded from
https://github.com/moby/profiles/blob/main/seccomp/default.json on 2026-09-28.
The only local change adds `io_uring_setup`, `io_uring_enter`, and
`io_uring_register` to its unconditional allow list for Agave 4.3.

Upstream license: Apache-2.0 (see `LICENSE.moby`).
