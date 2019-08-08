setup() {
    export ORIGINAL_PWD=$PWD
    export TEST_TMP=$(mktemp -d)
    mkdir ${TEST_TMP}/test-workdir
    cd ${TEST_TMP}/test-workdir
}

teardown() {
    cd ${ORIGINAL_PWD}
    rm -r ${TEST_TMP}/test-workdir
    rmdir ${TEST_TMP}
}

@test "pdftex" {
    cat <<EOF > test.tex
\TeX\ and Clear Linux.
\bye
EOF
    pdftex -halt-on-error -interaction=nonstopmode test.tex
    test -s test.pdf
    pdflatex /usr/share/texmf-dist/tex/latex/base/sample2e.tex
    test -s sample2e.pdf
}
