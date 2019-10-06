/**

This software is provided as Creative-Commons/Non-Commercial/With-Attribution.
(C)Copyright 2019, Mark Fischer, https://aguasonic.com/

https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode

*/
//- D import file for MessageTimer support.
module timer_message;

import std.concurrency : Tid;

struct TickMessage {
	const ulong tickNumber;

	this(const ulong tickNumber) {
		this.tickNumber = tickNumber;
	}
}

//- Call startTimer with a period in milliseconds.
//- Timer will send TickMessage to receiverOfTicks.
//- Ends itself when receiverOfTicks ends.
void startTimer(immutable ushort periodInMilliseconds, void function() receiverOfTicks);

