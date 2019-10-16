/**

Module to test a TimerMessage.

This software is provided as Creative-Commons/Non-Commercial/With-Attribution.
&copy;Copyright 2019, Mark Fischer, https://aguasonic.com/

https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode

**************************************************************************************************
*/
module timermessage_app;

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
      }
   }

   //- Ending this method will send a LinkTerminated to the sender.
   writeln("Waiter is done!.");
}

//- Testing TimerMessage facility.
void main(const string[] args) {
   static const string compileTime ="TimerMessageTest, built on " ~ __DATE__ ~ " at " ~ __TIME__;
   const string begTime = "Started at: " ~ Clock.currTime().toString();
   immutable ushort periodInMilliseconds = 900;
   //
   //- spawnLinked if one needs to know when startTimerMessage is done.
   //- startTimerMessage is done when waitForTicks tells it so.
   //- Else just spawn.
   const Tid tickWaiter = spawnLinked(&startTimerMessage, periodInMilliseconds, &waitForTicks);

   writeln(compileTime);
   writeln(begTime);

   //- Wait for these to finish if process is not actively doing something else.
   receiveOnly!LinkTerminated;

   //- OR, if simply blocking on this to finish.
   startTimerMessage(periodInMilliseconds, &waitForTicks);

   writeln("Done with second one.");

   //- OR, create, and wait { same process }.
   startTimerMessage(periodInMilliseconds);

   waitForTicks();

   //- Let the timer know it can leave.
   endTimerMessage();

   //- Write end time...
   scope (exit) {
      const string endTime = "Ended at: " ~ Clock.currTime().toString();

      writeln(endTime);
   }
}

