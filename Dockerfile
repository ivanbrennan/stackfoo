FROM fpco/haskell-scratch:latest
MAINTAINER ibrennan@sumall.com

ARG local_install_root

ADD ${local_install_root}/bin/stackfoo /bin/stackfoo

ENTRYPOINT exec /bin/stackfoo +RTS -N${CPUCORES} -RTS
