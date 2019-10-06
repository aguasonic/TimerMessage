/**

This software is provided as Creative-Commons/Non-Commercial/With-Attribution.
(C)Copyright 2019, Mark Fischer, https://aguasonic.com/

https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode

**************************************************************************************************
*
* module timer_message;
*
* void startTimer(const ushort periodInMilliseconds, void function() receiverOfTicks);
*
* Sets a timer of indicated period in milliseconds, which sends TickMessage to indicated receiver.
*
* This provides very basic functionality, as only one timer is needed for intended use.
*
* More advanced usage of timers can be done with libasync at:  https://github.com/etcimon/libasync
*
*/
module timer_message;

//- OS imports.
import core.sys.linux.timerfd : timerfd_create, timerfd_settime;
import core.sys.posix.signal : timespec;
import core.sys.posix.time : itimerspec, CLOCK_REALTIME;
import core.sys.posix.unistd : read;

//- System imports.
import std.concurrency : receiveOnly, send, spawn, spawnLinked, LinkTerminated, Tid;
import std.datetime;
import std.stdio;

private struct TickMessage {
    immutable ulong tickNumber;

    this(immutable ulong tickNumber) {
        this.tickNumber = tickNumber;
    }
}

//- Flag for timer loop.
//- MUST be shared because endTimer() will be called from another thread.
private static shared bool timerActive = true;

//- clear timer spec to disarm timer.
private void clearTimer(immutable int timerFD) {
    itimerspec timerSettings;

    /*- Both zero disarms the timer.
    //- Either nonzero arms the timer. */
    timerSettings.it_interval.tv_sec = 0;
    timerSettings.it_interval.tv_nsec = 0;

    /*- Initial expiration.
    //- Both zero disarms the timer.
    //- Either nonzero arms the timer. */
    timerSettings.it_value.tv_sec = 0;
    timerSettings.it_value.tv_nsec = 0;

    if (timerfd_settime(timerFD, 0, &timerSettings, null) == -1)
        stderr.writeln("Disarming failed!");
}

//- Populate timer spec as indicated.
private void armTimer(immutable int timerFD, immutable ushort periodInMilliseconds) {
    immutable uint periodInNanoseconds = periodInMilliseconds * 1_000_000;
    itimerspec timerSettings;

    /*- Both zero disarms the timer.
    //- Either nonzero arms the timer. */
    timerSettings.it_interval.tv_sec = 0;
    timerSettings.it_interval.tv_nsec = periodInNanoseconds;

    //- Initial expiration.
    //- Both zero disarms the timer.
    //- Either nonzero arms the timer.
    timerSettings.it_value.tv_sec = 0;
    timerSettings.it_value.tv_nsec = periodInNanoseconds;

    if (timerfd_settime(timerFD, 0, &timerSettings, null) == -1)
        stderr.writeln("Arming failed!");
}

//- Will start a timer that sends "TickMessages" to thread waiting for such.
private void setupTimer(immutable ushort periodInMilliseconds, Tid tickWaiter) {
    immutable int timerFD = timerfd_create(CLOCK_REALTIME, 0);
    immutable size_t sizeOfUlong = ulong.sizeof;
    //- Others populated elsewhere.
    size_t numberOfExpirations;
    uint counter;

    //- arm the timer.
    armTimer(timerFD, periodInMilliseconds);

    //- While this is active.
    while (timerActive) {
        immutable size_t returnValue = read(timerFD, &numberOfExpirations, sizeOfUlong);

        send(tickWaiter, TickMessage(counter++));
    }

    //- Clear the timer { tell OS to remove from active }.
    clearTimer(timerFD);
}

//- public interface -- needs a period, in milliseconds, and a function which is listening for TickMessages.
void startTimer(immutable ushort periodInMilliseconds, void function() receiverOfTicks) {
    //- Start the listener, who listens for TickMessages.
    Tid tickWaiter = spawnLinked(receiverOfTicks);

    //- Start the sender, which sends TickMessages to the receiver on the indicated period.
    const Tid tickSender = spawn(&setupTimer, periodInMilliseconds, tickWaiter);

    //- Wait until listener is done { /exemplar gratis, receiver encounters end-of-file/. }.
    //- Have to wait, because this is the parent thread of the previous two,
    //- and ending this method ends them, also.
    receiveOnly!LinkTerminated;

    //- Let the sender exit loop. Doing so clears the timer.
    timerActive = false;
}

