#!/bin/bash
dart test --coverage=.coverage 
dart run coverage:format_coverage \
    --lcov \
    --in=.coverage \
    --out=.coverage/lcov_all.info \
    --packages=.dart_tool/package_config.json 
lcov --remove .coverage/lcov_all.info "*/src/provider/*" \
    -o .coverage/lcov.info
