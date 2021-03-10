# TouchTracker-Gestures
Chapter 19 Gold Challenge - Speed and Size
Chapter 18 Gold Challenge - Circles

Completed Challenge for Big Nerd Ranch iOS Programming Gold Challenge for Chapters 19: UIGestureRecognizer and UIMenuController

Solution to set the colour and thickness of a line according to the velocity of the of the pan used to draw the line.

The time taken to draw a line is recorded in the touchesMoved event handler by use of a counter.

The velocity of the pan used to draw the line is calculated in the touchesEnded event handler using the length of the line and the time taken to draw the line.
A switch statement is then used to assess the velocity and sets the colour and thickness for the line.


