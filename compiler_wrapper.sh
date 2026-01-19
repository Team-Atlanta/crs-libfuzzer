#!/bin/sh

if [ "$FUZZING_LANGUAGE" = "c" ] || [ "$FUZZING_LANGUAGE" = "c++" ]; then
    bear compile
    status=$?
    cp compile_commands.json /out/ 2>/dev/null || true
    exit $status
else
    exec compile
fi
