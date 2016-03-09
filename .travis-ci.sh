# Git should be configured properely to run the tests
git config --global user.email "travis@example.com"
git config --global user.name "Travis CI"

install_on_linux () {
    # Install OCaml PPAs
    case "$OCAML_VERSION" in
        3.12.1) ppa=avsm/ocaml312+opam12 ;;
        4.00.1) ppa=avsm/ocaml40+opam12 ;;
        4.01.0) ppa=avsm/ocaml41+opam12 ;;
        4.02.3) ppa=avsm/ocaml42+opam12 ;;
        *) echo Unknown $OCAML_VERSION; exit 1 ;;
    esac

    echo "yes" | sudo add-apt-repository ppa:$ppa
    sudo apt-get update -qq
    sudo apt-get install -qq opam
    sudo apt-get install -qq spim
}

install_on_osx () {
    curl -OL "http://xquartz.macosforge.org/downloads/SL/XQuartz-2.7.6.dmg"
    sudo hdiutil attach XQuartz-2.7.6.dmg
    sudo installer -verbose -pkg /Volumes/XQuartz-2.7.6/XQuartz.pkg -target /
    brew update
    brew install opam
    brew install spim
}

case $TRAVIS_OS_NAME in
    osx) install_on_osx ;;
    linux) install_on_linux ;;
esac

#opam stuff
opam init
opam switch 4.02.3
`opam config env`
opam install ocamlbuild menhir

#compiling the project
$BUILD
