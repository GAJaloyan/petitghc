# Git should be configured properely to run the tests
git config --global user.email "travis@example.com"
git config --global user.name "Travis CI"

install_on_linux () {
    
    ppa=avsm/ocaml42+opam12
    
    sudo add-apt-repository ppa:$ppa
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
