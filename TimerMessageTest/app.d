/**

This software is provided as Creative-Commons/Non-Commercial/With-Attribution.
(C)Copyright 2019, Mark Fischer, https://aguasonic.com/

https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode

*/
//- Module to parse all V-Log files in the current directory.
module message_timer_app;

//- OS imports.
import core.sys.linux.timerfd : timerfd_create, timerfd_settime;
import core.sys.posix.signal : timespec;
import core.sys.posix.time : itimerspec, CLOCK_REALTIME;
import core.sys.posix.unistd : read;
import core.thread;

//- System imports.
import std.concurrency : receive, receiveOnly, spawn, spawnLinked, LinkTerminated, Tid;
import std.datetime;
import std.stdio;

//- Provides a messageTimer.
import timer_message;

//- Simulates getting to End-Of-File in intended application.
static private ulong counter;

//- Waits for ticks from the clock.
static private void waitForTicks() {
    bool notDone = true;

    while (notDone) {
        receive(
        (TickMessage message) {
            //writeln("Received tick: ", message.tickNumber);
            const string tickTime = Clock.currTime().toString();

            writeln(tickTime);

            counter = message.tickNumber;
        });

        //- Simulating condition where we are done with the timer.
        //- For example, encountering End-Of-File in actual usage.
        if (counter == 4) {
            writeln("Counter equals 4.");
            notDone = false;
            //endTimer();
        }
    }

    writeln("Waiter is done!.");
}

//- Testing TimerMessage facility.
void main(const string[] args) {
    static const string compileTime ="TimerMessageTest, built on " ~ __DATE__ ~ " at " ~ __TIME__;
    const string begTime = "Started at: " ~ Clock.currTime().toString();
    immutable ushort periodInMilliseconds = 900;
    //- Spawn Linked if one needs to know when startTimer is done.
    //- startTimer is done when waitForTicks tells it so.
    //- Else just spawn.
    const Tid tickWaiter = spawnLinked(&startTimer, periodInMilliseconds, &waitForTicks);

    writeln(compileTime);
    writeln(begTime);

    //- Wait for these to finish.
    receiveOnly!LinkTerminated;

    //- Write end time...
    scope (exit) {
        const string endTime = "Ended at: " ~ Clock.currTime().toString();

        writeln(endTime);
    }
}

