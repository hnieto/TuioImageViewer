# head process
export RANK=0; ./application.macosx/MPEPeasy.app/Contents/MacOS/JavaApplicationStub &

# render processes
export RANK=1; ./application.macosx/MPEPeasy.app/Contents/MacOS/JavaApplicationStub &
export RANK=2; ./application.macosx/MPEPeasy.app/Contents/MacOS/JavaApplicationStub &
export RANK=3; ./application.macosx/MPEPeasy.app/Contents/MacOS/JavaApplicationStub &

