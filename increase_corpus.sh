#!/usr/bin/env sh

set -ex;

if [ "$RUNS" = "" ]; then
    RUNS=1000000;
fi
if [ "$MAX_LEN" = "" ]; then
    MAX_LEN=500000;
fi

# Mix up the corpora
set +ex; # cp can fail..
for input in $(ls fuzz/corpus/); do
    for output in $(ls fuzz/corpus/); do
        cp fuzz/corpus/$input/* fuzz/corpus/$output/ 2>/dev/null;
    done;
done;
set -ex;

# Generate new samples of PSBTs
for i in seq 10; do
    cargo +nightly test --release test_transaction_chain;
done;

cargo +nightly fuzz run --release --all-features --debug-assertions --sanitizer none parse_cancel -- -runs=$RUNS -max_len=$MAX_LEN;
cargo +nightly fuzz run --release --all-features --debug-assertions --sanitizer none parse_emergency -- -runs=$RUNS -max_len=$MAX_LEN;
cargo +nightly fuzz run --release --all-features --debug-assertions --sanitizer none parse_unvault_emergency -- -runs=$RUNS -max_len=$MAX_LEN;
cargo +nightly fuzz run --release --all-features --debug-assertions --sanitizer none parse_spend -- -runs=$RUNS -max_len=$MAX_LEN;

cargo +nightly fuzz cmin parse_cancel;
cargo +nightly fuzz cmin parse_emergency;
cargo +nightly fuzz cmin parse_unvault_emergency;
cargo +nightly fuzz cmin parse_spend;
