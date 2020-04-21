#!/bin/bash
swift test --enable-test-discovery | tee >(grep --color=always error)
