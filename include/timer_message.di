/**-
* D import file for TimerMessage support.
*
* This software is provided as Creative-Commons/Non-Commercial/With-Attribution.
* &copy;Copyright 2019, Mark Fischer, https://aguasonic.com/
*
* https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
*
*/
module timer_message;

import std.concurrency : Tid;

struct TickMessage {
    immutable ulong tickNumber;

    this(immutable ulong tickNumber) {
        this.tickNumber = tickNumber;
    }
}

//- Call startTimer with a period in milliseconds.
//- Timer will send TickMessage to receiverOfTicks.
//- Ends itself when receiverOfTicks ends.
void startTimerMessage(immutable ushort periodInMilliseconds, void function() receiverOfTicks);


//- Call startTimer with a period in milliseconds.
//- Timer will send TickMessage to thisTid { parent }.
//- Ends itself when parentTask ends { which will send a LinkTerminated message }.
void startTimerMessage(immutable ushort periodInMilliseconds);

//- But requires caller to say when it is finished.
void endTimerMessage();

