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

public enum Containment {
    case containedFully           // Included in set when both containedHorizontally AND containedVertically
    case overlapsFully            // Included in set when both overlapsHorizontally AND overlapsVertically
    case beyondFully              // Included in set when both beyondHorizontally AND beyondVertically

    case beyondLeft               
    case overlapsLeft
    case beyondHorizontally       // Included in set when either beyondLeft OR beyondRight
    case containedHorizontally   
    case overlapsHorizontally     // Included in set when both overlapsLeft AND overlapsRight
    case overlapsRight
    case beyondRight

    case beyondTop
    case overlapsTop
    case beyondVertically         // Included in set when either beyondTop OR beyondBottom
    case containedVertically      
    case overlapsVertically       // Included in set when both overlapsTop AND overlapsBottom
    case overlapsBottom
    case beyondBottom
}
