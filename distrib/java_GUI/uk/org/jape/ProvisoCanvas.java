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

import java.awt.Component;
import java.awt.Container;
import java.awt.FontMetrics;

public class ProvisoCanvas extends JapeCanvas implements ProtocolConstants {

    public ProvisoCanvas(Container viewport, boolean scrolled) {
        super(viewport, scrolled);
        clear();
    }

    public String getSelections(String sep) {
        Alert.abort("ProvisoCanvas.getSelections");
        return ""; // shut up compiler
    }
    
    // not efficient, not in time order
    // always ends with a blank line
    public String getTextSelections(String sep) {
        String s = null;
        int nc = child.getComponentCount(); // oh dear ...
        for (int i=0; i<nc; i++) {
            Component c = child.getComponent(i); // oh dear ...
            if (c instanceof TextSelectableItem) {
                TextSelectableItem sti = (TextSelectableItem)c;
                String s1 = sti.getTextSelections();
                if (s1!=null) {
                    if (s==null)
                        s=s1;
                    else
                        s=s+sep+s1;
                }
            }
        }
        return s;
    }
    public Component add(Component c) {
        Alert.abort("ProvisoCanvas.add("+c+")");
        return c; // shut up compiler
    }

    public Component add(Component c, int index) {
        Alert.abort("ProvisoCanvas.add("+c+", "+index+")");
        return c; // shut up compiler
    }

    public void remove(Component c) {
        Alert.abort("ProvisoCanvas.remove("+c+")");
    }

    public void removeAll() {
        Alert.abort("ProvisoCanvas.removeAll()");
    }

    public void clear() {
        super.removeAll();
        setOrigin(0,0); // maybe ...
        ensureFontInfo();
        provisoCursor = givenCursor = inset+ascent;
        provisoHeaderInserted = givenHeaderInserted = false;
    }

    private static String provisoHeader = "Provided:";
    private static int ascent=-1, descent, leading; 
    private static int inset, linestep;

    private void ensureFontInfo() {
        if (ascent==-1) {
            FontMetrics f = JapeFont.getFontMetrics(ProvisoFontNum);
            ascent = f.getMaxAscent(); descent = f.getMaxDescent();
            leading = f.getLeading();
            linestep = ascent+descent+leading;
            inset = Math.max(2, 2*leading);
        }
    }
    
    private int provisoCursor, givenCursor;
    private boolean provisoHeaderInserted, givenHeaderInserted;

    public void addProvisoLine(String annottext) {
        ensureFontInfo();
        if (!provisoHeaderInserted) {
            insertHeader(provisoCursor, provisoHeader);
            provisoCursor += linestep; givenCursor += linestep;
            provisoHeaderInserted = true;
        }
        insertLine(provisoCursor, annottext);
        provisoCursor += linestep; givenCursor += linestep;
    }

    private void shiftLines(int cursor) {
        ensureFontInfo();
        int nc = child.getComponentCount();
        for (int i=0; i<nc; i++) {
            TextItem t = (TextItem)child.getComponent(i);
            if (t.getY()+ascent>=cursor) {
                t.repaint();
                t.setLocation(t.getX(), t.getY()+linestep);
                t.repaint();
            }
        }
    }

    private void insertHeader(int cursor, String text) {
        shiftLines(cursor);
        super.add(new TextItem(this, inset, cursor, ProvisoFontNum, text));
    }

    private void insertLine(int cursor, String annottext) {
        shiftLines(cursor);
        super.add(new TextSelectableProvisoItem(this, 3*inset, cursor, annottext));
    }
}