#!/usr/bin/env bash
set -x
case ${1:?} in
  success)
    exit 0
    ;;
  *)
    exit 1
    ;;
esac
