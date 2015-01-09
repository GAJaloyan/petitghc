make || exit 1
./petitghc tests/exec/fib1.hs || exit 1
java -jar Mars4_5.jar outfile.s || exit 1
