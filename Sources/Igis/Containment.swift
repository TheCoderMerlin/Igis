/*
IGIS - Remote graphics for Swift on Linux
Copyright (C) 2018 Tango Golf Digital, LLC
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/


// Provides a description of a rectangle relative to a target Point or Rect    
public enum Containment {
    // Special cases combining horizontal and vertical containment
    case containedFully           // Included in set when both containedHorizontally AND containedVertically (Points,Rects)
    case overlapsFully            // Included in set when both overlapsHorizontally AND overlapsVertically   (Rects only)
    case beyondFully              // Included in set when both beyondHorizontally AND beyondVertically       (Points,Rects)

    // Horizontal cases
    case beyondLeft               // Indicates target's right side is beyond (to left of) object             (Points,Rects)
    case overlapsLeft             // Indicates target's left is beyond left but target's right is            (Rects only)
                                  //     within or beyond object (toward right)
    case beyondHorizontally       // Included in set when either beyondLeft OR beyondRight                   (Points,Rects)
    case containedHorizontally    // Target is contained within left and right of object                     (Points,Rects)
    case overlapsHorizontally     // Included in set when both overlapsLeft AND overlapsRight                (Rects only)
    case overlapsRight            // Indicates target's right is beyond right but target's left is           (Rects only)
                                  //     within or beyond object (toward left)
    case beyondRight              // Indicates target's left side is beyond (to right of) object             (Points,Rects)

    // Vertical cases
    case beyondTop                // Indicates target's bottom side is beyond (on top of) object             (Points,Rects)
    case overlapsTop              // Indicates target's top is beyond top but target's bottom is             (Rects only)
                                  //     within or beyond object (toward bottom)
    case beyondVertically         // Included in set when either beyondTop OR beyondBottom                   (Points,Rects)
    case containedVertically      // Target is contained within top and bottom of object                     (Points,Rects)
    case overlapsVertically       // Included in set when both overlapsTop AND overlapsBottom                (Points,Rects)
    case overlapsBottom           // Indicates target's bottom is beyond bottom but target's top is          (Rects only)
                                  //     within or beyond object (toward top)
    case beyondBottom             // Indicates target's top side is beyond (below) object                    (Points,Rects)
}
