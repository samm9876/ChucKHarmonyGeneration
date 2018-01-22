# ChucKHarmonyGeneration
Harmony Generation algorithm in the live audio programming language ChucK: 
http://chuck.cs.princeton.edu/

Program often crashes when the thread is initially added to the session.
Initially I thought this was to do with the seed being out of bounds as it
crashed at the beginning with no console debug message. However once the thread
is running the program is stable the whole session regardless of whether or not
the virtual machine is cleared.

This leads me to think it has something to do with ChucK's engine initializing incorrectly
and/or conflicting with my code (ChucK unfortunately isn't known for it's stability).

The harmony generated is fairly pleasant sounding. If the generation formula is
reused it will likely be migrated to a platform with better MIDI & sound synthesis
capabilities (likely candidates include PureData or MaxMSP, however a text based language
like CSound or SuperCollider might be an easier option for transferring the code as text).
