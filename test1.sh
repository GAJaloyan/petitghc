make || exit 1
./petitghc test.hs >> ast || exit 1
java -jar Mars4_5.jar outfile.s || exit 1
