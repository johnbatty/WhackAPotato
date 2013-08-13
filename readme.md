WhackAPotato
============

A modified version of the [Loom Game Engine](http://theengine.co/loom) [WhackAMole example](http://theengine.co/examples) to make it suitable for use with [MaKey MaKey](http://www.makeymakey.com).

Main modifications:
* Added keyboard support
  * Whack with A, S, D keys (keys that can easily be connected on MaKey MaKey)
  * F to toggle fullscreen mode
  * Space bar to restart game
  * ESC to quit game
* Added sounds
* Changed graphics to just use 3 identical instances of mole image (so they can easily be replaced by user photos), and modified game so that these are not changed during game
* Removed code that ended game after 3 strikes/misses (often made games too short)
* Slowed down moles to make it easier to play for young children
* Added negative points for misses
* Replaced "Retry" label with "Game Over"
* Cleaned up directory structure

To connect up MaKey MaKey, just plug potatoes into the A, S, D connections on the rear of the board.
You need a connection to earth before you start whacking - I find holding a banana wired to earth works well.

Potatoes are a good choice for the whacking controllers.  Much more robust than bananas!

Replace the mole bitmaps (assets/sprites/[mole_1.png,mole_2.png,mole_3.png]) with pictures of people you know for even more fun.

To run you need the Loom SDK installed.  From the root directory:

    > loom run
