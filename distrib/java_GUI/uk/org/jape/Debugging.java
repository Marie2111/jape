/* 
    $Id$

    Copyright � 2002 Richard Bornat & Bernard Sufrin
     
        richard@bornat.me.uk
        sufrin@comlab.ox.ac.uk

    This file is part of japeserver, which is part of jape.

    Jape is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    Jape is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with jape; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
    (or look at http://www.gnu.org).
    
*/

/*
        Controls the inclusion of various debugging featurettes.
*/
class Debugging
{
    // ProofCanvas tracing
    static final public boolean canvas_bbox          = false;
    static final public boolean text_baselines       = false;
    static final public boolean canvas_events        = false;
    static final public boolean canvas_itemevents    = false;

    static final public boolean protocol_tracing     = false;

    static final public boolean JapeMenu             = false;

    static final public boolean TextItem             = false;
}

