
This software is provided as Creative-Commons/Non-Commercial/With-Attribution.

(C)Copyright 2019, Mark Fischer, https://aguasonic.com/

https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode

## TimerMessage -- a simple message-passing timer in D

# To build the library, install the D language compiler, https://dlang.org/

cd TimerMessageLib

dub

-or-

dub --build release

#- Move the library to the "lib" directory.

mv build/*.a ../lib


# To build the example application

cd TimerMessageTest

make

# To run the example application
./TimerMessageTest



