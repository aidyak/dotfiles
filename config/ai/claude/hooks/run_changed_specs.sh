#!/bin/bash
grep -q '^rspec:' Makefile 2>/dev/null || exit 0

CHANGED=$(git diff --name-only develop...HEAD 2>/dev/null | grep '_spec\.rb$' | tr '\n' ' ')
[ -n "$CHANGED" ] && make rspec args="$CHANGED" 2>&1 || true
