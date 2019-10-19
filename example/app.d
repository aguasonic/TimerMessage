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
import std.container;

//- Provides a messageTimer.
import timer_message;

//- Simulates getting to End-Of-File in intended application.
static private ulong counter;

//- Waits for ticks from the clock.
//- using the "self-cleaning" interface.
static private void selfCleaning() {
   bool notDone = true;

   writeln("");
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
   writeln("Self-cleaning Waiter is done!.");

   //endTimerMessage();

   //- Let the timer know it can leave.
   //endTimerMessage();
}

//- Waits for ticks from the clock.
static private void waitForTicks() {
   bool notDone = true;

   writeln("");
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

   //- Let the timer know it can leave.
   endTimerMessage();
}

//- Testing TimerMessage facility.
void main(const string[] args) {
   static immutable string compileTime ="TimerMessageTest, built on " ~ __DATE__ ~ " at " ~ __TIME__;
   immutable begTime = "Started at: " ~ Clock.currTime().toString();
   immutable ushort periodInMilliseconds = 900;
   //
   //- spawnLinked if one needs to know when startTimerMessage is done.
   //- startTimerMessage is done when selfCleaning exits.
   //- Else just spawn and wait, as seen in the next example --
   //- however, that needs to tell the timer when it is done!
   const Tid tickSender = spawnLinked(&startTimerMessage, periodInMilliseconds, &selfCleaning);

   writeln(compileTime);
   writeln(begTime);

   //- Wait for these to finish if process is not actively doing something else.
   receiveOnly!LinkTerminated;
   writeln("Done with first example.");

   //- OR, if simply blocking on this to finish.
   startTimerMessage(periodInMilliseconds, &waitForTicks);
   writeln("Done with second example.");
   
   //- OR, create, and wait { same process }.
   startTimerMessage(periodInMilliseconds);

   waitForTicks();
   writeln("Done with third example.");

   //- Write end time...
   scope (exit) {
      const string endTime = "Ended at: " ~ Clock.currTime().toString();

      writeln(endTime);
   }
}

