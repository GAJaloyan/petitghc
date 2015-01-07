make || exit 1
./petitghc test.hs || exit 1
java -jar Mars4_5.jar outfile.s || exit 1
