
#### TimerMessage -- a simple message-passing timer in D

This software is provided as Creative-Commons/Non-Commercial/With-Attribution.

&copy;Copyright 2019, Mark Fischer, https://aguasonic.com/

https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode

#### To build the library

If not already available, install the D language compiler, https://dlang.org/

cd libTimerMessage

dub

-or-

dub --build release

#### Move the library to the "lib" directory.

mv build/*.a ../lib


#### To build the example application

cd example

make

#### To run the example application

./example



