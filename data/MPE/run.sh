# head process
export RANK=0; ./TuioImageViewer.app/Contents/MacOS/JavaApplicationStub &

# render processes
export RANK=1; ./TuioImageViewer.app/Contents/MacOS/JavaApplicationStub &
export RANK=2; ./TuioImageViewer.app/Contents/MacOS/JavaApplicationStub &
export RANK=3; ./TuioImageViewer.app/Contents/MacOS/JavaApplicationStub &
export RANK=4; ./TuioImageViewer.app/Contents/MacOS/JavaApplicationStub
