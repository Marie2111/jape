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

import java.io.BufferedInputStream;
import java.io.EOFException;
import java.io.InputStream;
import java.io.IOException;
import java.io.PrintStream;

import java.util.HashMap;

public class JapeCharEncoding implements DebugConstants {
    // This is the encoding that allows Konstanz to appear on the MacOS X  screen.
    // I don't really need to use it, but since something similar has to support the Konstanz<->Unicode translation
    // on other platforms, it's useful to find out what it is, and be in control.
    final static char MacRoman[] = new char [] {
        0x00,   0x01,   0x02,   0x03,   0x04,   0x05,   0x06,   0x07,   0x08,   0x09,   0x0A,   0x0B,   0x0C,   0x0D,   0x0E,   0x0F,
        0x10,   0x11,   0x12,   0x13,   0x14,   0x15,   0x16,   0x17,   0x18,   0x19,   0x1A,   0x1B,   0x1C,   0x1D,   0x1E,   0x1F,
        ' ',    '!',    '"',    '#',    '$',    '%',    '&',    '\'',   '(',    ')',    '*',    '+',    ',',    '-',    '.',    '/',
        '0',    '1',    '2',    '3',    '4',    '5',    '6',    '7',    '8',    '9',    ':',    ';',    '<',    '=',    '>',    '?',
        '@',    'A',    'B',    'C',    'D',    'E',    'F',    'G',    'H',    'I',    'J',    'K',    'L',    'M',    'N',    'O',
        'P',    'Q',    'R',    'S',    'T',    'U',    'V',    'W',    'X',    'Y',    'Z',    '[',    '\\',   ']',    '^',    '_',
        '`',    'a',    'b',    'c',    'd',    'e',    'f',    'g',    'h',    'i',    'j',    'k',    'l',    'm',    'n',    'o',
        'p',    'q',    'r',    's',    't',    'u',    'v',    'w',    'x',    'y',    'z',    '{',    '|',    '}',    '~',    0x7F,
        0x00C4, 0x00C5, 0x00C7, 0x00C9, 0x00D1, 0x00D6, 0x00DC, 0x00E1, 0x00E0, 0x00E2, 0x00E4, 0x00E3, 0x00E5, 0x00E7, 0x00E9, 0x00E8, 
     // perp,   Aring,  Gamma,  Eacute, Ntilde, Odier,  Udier,  aacute, agrave, acircm, stile3, seqbra, aring,  ccedil, eacute, egrave
        0x00EA, 0x00EB, 0x00ED, 0x00EC, 0x00EE, 0x00EF, 0x00F1, 0x97,   0x98,   0x99,   0x00F6, 0x00F5, 0x00FA, 0x00F9, 0x00FB, 0x00FC,
     // ecircm, ltrian, iacute, igrave, icircm, sttilde,seqket, ?oacute,?ograve,?ocircm,bararr, leftar, uacute, ugrave, ucircm, harp2
        0x2020, 0x00B0, 0x00A2, 0x00A3, 0x00A7, 0x2022, 0x00B6, 0x00DF, 0x00AE, 0x00A9, 0x2122, 0x00B4, 0x00A8, 0x2260, 0x00C6, 0x00D8,
     // Tserif, degree, cent,   pound,  para,   bullet, logand, subset, regist, copyri, tradma, acute,  umlaut, noteq,  AE,     Oslash
        0x221E, 0x00B1, 0x2264, 0x2265, 0x00A5, 0x00B5, 0x2202, 0x2211, 0x220F, 0x03C0, 0x222B, 0x00AA, 0x00BA, 0x2126, 0x00E6, 0x00F8, 
     // infin,  plusmi, lesseq, greaeq, lolli,  mu,     delta,  Sigma,  Pi,     pi,     curlyS, xcircl, plusci, Omega,  ae,     oslash
        0x00BF, 0x00A1, 0x00AC, 0x221A, 0x0192, 0x2248, 0x2206, 0x00AB, 0x00BB, 0x2026, 0x00A0, 0x00C0, 0x00C3, 0x00D5, 0x0152, 0x0153, 
     // seuq,   alxce,  not,    root,   curlyf, curlyeq,Delta,  guibra, guiket, ...,    nbspace,Agrave, Atilde, Otilde, OE,     oe,
        0x2013, 0x2014, 0x201C, 0x201D, 0x2018, 0x2019, 0x00F7, 0x25CA, 0x00FF, 0x0178, 0x2044, 0x00A4, 0x2039, 0x203A, 0xFB01, 0xFB02,
     // endash, emdash, quote,  etouq,  squote, etouqs, divide, lozeng, mapsto, bottom, member, 2arrow, ::,     sembra, semket, interse,
        0x2021, 0x00B7, 0x201A, 0x201E, 0x2030, 0x00C2, 0x00CA, 0x00C1, 0x00CB, 0x00C8, 0x00CD, 0x00CE, 0x00CF, 0x00CC, 0x00D3, 0x00D4,
     // srepma, fishta, blksq,  lowquot,exists, stiboth,stile,  arrow,  forall, equiv,  lrarrow,logor,  Lambda, models, forces, union
        0xF8FF, 0x00D2, 0x00DA, 0x00DB, 0x00D9, 0x0131, 0x02C6, 0x02DC, 0x00AF, 0x02D8, 0x02D9, 0x02DA, 0x00B8, 0x02DD, 0x0328, 0x02C7
     // bimodel,tildop, aleph,  Ucircm, times,  sqgee,  whsqua, eqdef,  prep,   dot,    hook,   lambda, cedilla,2acute, ogonek, caron
    };
    // 21DD is rightwards squiggle arrow (should be turnstile with tilde as horizontal)
    final static char KonstanzUnicode[] = new char[] {
        0x00,   0x01,   0x02,   0x03,   0x04,   0x05,   0x06,   0x07,   0x08,   0x09,   0x0A,   0x0B,   0x0C,   0x0D,   0x0E,   0x0F,
        0x10,   0x11,   0x12,   0x13,   0x14,   0x15,   0x16,   0x17,   0x18,   0x19,   0x1A,   0x1B,   0x1C,   0x1D,   0x1E,   0x1F,
        ' ',    '!',    '"',    '#',    '$',    '%',    '&',    '\'',   '(',    ')',    '*',    '+',    ',',    '-',    '.',    '/',
        '0',    '1',    '2',    '3',    '4',    '5',    '6',    '7',    '8',    '9',    ':',    ';',    '<',    '=',    '>',    '?',
        '@',    'A',    'B',    'C',    'D',    'E',    'F',    'G',    'H',    'I',    'J',    'K',    'L',    'M',    'N',    'O',
        'P',    'Q',    'R',    'S',    'T',    'U',    'V',    'W',    'X',    'Y',    'Z',    '[',    '\\',   ']',    '^',    '_',
        '`',    'a',    'b',    'c',    'd',    'e',    'f',    'g',    'h',    'i',    'j',    'k',    'l',    'm',    'n',    'o',
        'p',    'q',    'r',    's',    't',    'u',    'v',    'w',    'x',    'y',    'z',    '{',    '|',    '}',    '~',    0x7F,
        0x2ADF, 0x00C5, 0x0393, 0x00C9, 0x00D1, 0x00D6, 0x00DC, 0x00E1, 0x00E0, 0x00E2, 0x2AE2, 0x27E8, 0x00E5, 0x00E7, 0x00E9, 0x00E8,
     // perp,   Aring,  Gamma,  Eacute, Ntilde, Odier,  Udier,  aacute, agrave, acircm, stile3, seqbra, aring,  ccedil, eacute, egrave
        0x00EA, 0x25C1, 0x00ED, 0x00EC, 0x00EE, 0x21DD, 0x27E9, 0x97,   0x98,   0x99,   0x00F6, 0x21D0, 0x00FA, 0x00F9, 0x00FB, 0x21CC,
     // ecircm, ltrian, iacute, igrave, icircm, sttilde,seqket, ?oacute,?ograve,?ocircm,bararr, leftar, uacute, ugrave, ucircm, harp2
        0x03a4, 0x00B0, 0x00A2, 0x00A3, 0x00A7, 0x2022, 0x2227, 0x2286, 0x00AE, 0x00A9, 0x2122, 0x00B4, 0x00A8, 0x2260, 0x00C6, 0x00D8,
     // Tserif, degree, cent,   pound,  para,   bullet, logand, subset, regist, copyri, tradma, acute,  umlaut, noteq,  AE,     Oslash
        0x221E, 0x00B1, 0x2264, 0x2265, 0x22B8, 0x00B5, 0x2202, 0x2211, 0x220F, 0x03C0, 0x222B, 0x2297, 0x2295, 0x2126, 0x00E6, 0x00F8,
     // infin,  plusmi, lesseq, greaeq, lolli,  mu,     delta,  Sigma,  Pi,     pi,     curlyS, xcircl, plusci, Omega,  ae,     oslash
        0x00BF, 0x00A1, 0x00AC, 0x221A, 0x0192, 0x2248, 0x2206, 0x00AB, 0x00BB, 0x2026, 0x00A0, 0x00C0, 0x00C3, 0x00D5, 0x0152, 0x0153,
     // seuq,   alxce,  not,    root,   curlyf, curlyeq,Delta,  guibra, guiket, ...,    nbspace,Agrave, Atilde, Otilde, OE,     oe,
        0x2013, 0x2014, 0x201C, 0x201D, 0x2018, 0x2019, 0x00F7, 0x25CA, 0x21A6, 0x22A5, 0x2208, 0x21d2, 0x2234, 0x27E6, 0x27E7, 0x2229,
     // endash, emdash, quote,  etouq,  squote, etouqs, divide, lozeng, mapsto, bottom, member, 2arrow, ::,     sembra, semket, interse,
        0x214B, 0x297D, 0x25AA, 0x201E, 0x2203, 0x27DB, 0x22A2, 0x2192, 0x2200, 0x2261, 0x2194, 0x2228, 0x039B, 0x22A7, 0x22A9, 0x222A,
     // srepma, fishta, blksq,  lowquot,exists, stiboth,stile,  arrow,  forall, equiv,  lrarrow,logor,  Lambda, models, forces, union
        0x27DA, 0x223C, 0x2135, 0x00DB, 0x00D7, 0x2292, 0x25A1, 0x225C, 0x2AE0, 0x25CF, 0x2283, 0x03BB, 0x00B8, 0x02DD, 0x0328, 0x02C7
     // bimodel,tildop, aleph,  Ucircm, times,  sqgee,  whsqua, eqdef,  prep,   dot,    hook,   lambda, cedilla,2acute, ogonek, caron
    };

    char[] encoding = null;
    
    final int bufsize = 1024;
    
    BufferedInputStream in;
    PrintStream out;

    public JapeCharEncoding(InputStream in, PrintStream out) {
        this.in = new BufferedInputStream(in, bufsize);
        this.out = out;
    }

    StringBuffer inbuf = new StringBuffer(bufsize);
    private boolean ignoreLF = false; // deal with CRLF problems

    public String inputline() throws EOFException, IOException {
        int c;
        inbuf.delete(0, inbuf.length());
        while (true) {
            switch (c=in.read()) {
                case '\r':
                    ignoreLF=true;
                    return inbuf.toString();
                case '\n':
                    if (ignoreLF)
                        ignoreLF=false;
                    else
                        return inbuf.toString();
                case -1  :
                    if (inbuf.length()==0)
                        throw new EOFException();
                    else
                        return inbuf.toString();
                default:
                    inbuf.append(encoding==null ? (char)c : encoding[c]);
                    break;
            }
        }
    }

    private byte[] outbuf = new byte[bufsize];
    private PosIntHashMap toAsc;
    
    public void output(String s) throws IOException {
        int len = s.length();
        int bufi = 0;
        for (int i=0; i<len; i++) {
            char c0 = s.charAt(i);
            if (toAsc==null) {
                if (c0>0xFF)
                    throw new IOException("can't decode "+c0+" without encoding");
                else
                    outbuf[bufi++] = (byte)c0;
            }
            else {
                int c = toAsc.get(c0);
                if (c<0)
                    throw new IOException("can't decode "+c0);
                else
                    outbuf[bufi++] = (byte)c;
            }
            if (bufi==bufsize) {
                out.write(outbuf, 0, bufi);
                if (encoding_tracing) {
                    System.err.println("JapeCharEncoding.output sends (1)***");
                    System.err.write(outbuf, 0, bufi);
                    System.err.println("\n***");
                }
                bufi = 0;
            }    
        }
        if (bufi!=0) {
            out.write(outbuf, 0, bufi);
            if (encoding_tracing) {
                System.err.println("JapeCharEncoding.output sends (2)***");
                System.err.write(outbuf, 0, bufi);
                System.err.println("\n***");
            }
        }
    }

    public void outputln(String s) throws IOException {
        output(s); out.println(); // for now: this will be a CRLF when we use a socket
    }

    public void flush() {
        out.flush();
    }

    public String toAscii(String s) {
        if (toAsc==null)
            Alert.abort("JapeCharEncoding.toAscii no encoding");
        
        int len = s.length();
        StringBuffer buf = new StringBuffer(len);
        for (int i=0; i<len; i++) {
            int c = toAsc.get(s.charAt(i));
            if (c<0)
                Alert.abort("JapeCharEncoding.toAscii can't decode "+(int)s.charAt(i)+" in \""+s+"\"");
            else
                buf.append((char)c);
        }
        return buf.toString();
    }

    // a temporary hack, while MacOS doesn't do font fallback
    public String toTitle(String s) {
        if (japeserver.onMacOS) {
            if (encodingName!=null && encodingName.equals("Konstanz")) {
                String asc = toAscii(s);
                int len = s.length();
                StringBuffer buf = new StringBuffer(len);
                for (int i=0; i<len; i++)
                    buf.append(KonstanzUnicode[asc.charAt(i)]);
                return buf.toString();
            }
            else {
                Alert.abort("JapeCharEncoding.toTitle can't recognise encoding "+encodingName);
                return s; // shut up compiler
            }
        }
        else
            return s;
    }

    private String encodingName;
    
    public void setEncoding(String s) throws ProtocolError {
        encodingName = s;
        if (s.equals("Konstanz")) {
            encoding = japeserver.onMacOS ? MacRoman : KonstanzUnicode;
            if (encoding.length!=0x100)
                Alert.abort("JapeCharEncoding.encode encoding length "+encoding.length);
            toAsc = new PosIntHashMap(0x200);
            for (int i=0; i<0x100; i++) {
                if (toAsc.get(encoding[i])>=0)
                    Alert.abort("(Konstanz) doubly decodes 0x"+Integer.toHexString(encoding[i])+
                                " [0x"+Integer.toHexString(toAsc.get(encoding[i]))+",0x"+Integer.toHexString(i)+"]");
                toAsc.set(encoding[i],i);
            }
        }
        else
            throw new ProtocolError("japeserver doesn't know encoding "+s);
    }
}

/* recovered from JapeFont
    // this list defined by looking at what MacOS X thinks Konstanz means.
    // If it isn't universally accepted, we shall have to translate back into bytes,
    // and then into Unicode again.  But I hope not.

    // note the ones for which I haven't found a perfect match (look for ***)

    setmap(0x00A4, 0x21d2); // double arrow right
    setmap(0x00A5, 0x22b8); // lollipop
    setmap(0x00AA, 0x2297); // circled times
    setmap(0x00AF, 0x2AE0); // short up tack .. best I can find
    setmap(0x00B6, 0x2227); // logical and
    setmap(0x00B7, 0x297D); // right fishhook (RIGHT FISH TAIL), form of logical implication
    setmap(0x00BA, 0x2295); // circled plus
    setmap(0x00C1, 0x2192); // single arrow right
    setmap(0x00C2, 0x27db); // left and right turnstile
    setmap(0x00C4, 0x2ADF); // short down tack .. best I can find
    setmap(0x00C7, 0x0393); // Gamma
    setmap(0x00C8, 0x2261); // equivalent
    setmap(0x00CA, 0x22A2); // turnstile
    setmap(0x00CB, 0x2200); // for all
    setmap(0x00CC, 0x22A7); // models
    setmap(0x00CD, 0x2194); // left-right single arrow
    setmap(0x00CE, 0x2228); // logical or
    setmap(0x00CF, 0x039B); // Lambda
    setmap(0x00D2, 0x223C); // tilde operator
    setmap(0x00D3, 0x22A9); // forces
    setmap(0x00D4, 0x222A); // union
    setmap(0x00D9, 0x00D7); // multiplication (and it is D7, believe it or not ...)
    setmap(0x00DA, 0x2135); // aleph (alef?)
    setmap(0x00DC, 0x22C3); // n-ary union
    setmap(0x00DF, 0x2286); // subset or equal
    setmap(0x00E3, 0x27E8); // sequence bra
    setmap(0x00E4, 0x2AE2); // triple-bar turnstile
    setmap(0x00EB, 0x25C1); // white left-pointing triangle
    setmap(0x00EF, 0x21DD); // rightwards squiggle arrow (*** should be turnstile with tilde as horizontal)
    setmap(0x00F1, 0x27E9); // sequence ket
    setmap(0x00F5, 0x21D0); // leftwards double arrow
    setmap(0x00F6, 0x2907); // rightwards double arrow from bar
    setmap(0x00FC, 0x21CC); // RIGHTWARDS HARPOON OVER LEFTWARDS HARPOON
    setmap(0x00ff, 0x21a6); // rightwards single arrow from bar (maps to)
    setmap(0x0131, 0x2292); // square greater or equal (*** should have a line above)
    setmap(0x0178, 0x22a5); // bottom (as UP TACK)
    setmap(0x02C6, 0x25a1); // white square (25ab is small white square, if more appropriate)
    setmap(0x02D8, 0x25aa); // small black square (25a0 is black square, if more appropriate)
    setmap(0x02d9, 0x2283); // superset
    setmap(0x02da, 0x03bb); // lambda (more lambdas in the unicode 3 space, but let's not go there)
    setmap(0x02dc, 0x225c); // equal by definition to (as DELTA EQUAL TO; 225d is nicer in print but not on screen)
    setmap(0x2020, 0x03a4); // Tau (I think)
    setmap(0x2021, 0x214b); // turned (upside-down) ampersand
    setmap(0x2030, 0x2203); // exists
    setmap(0x2039, 0x2234); // proportion (looks like double colon)
    setmap(0x203a, 0x27e6); // white left square bracket (semantic bra) (301a may be preferable)
    setmap(0x2044, 0x2208); // element of
    setmap(0xf8ff, 0x27da); // left and right models
    setmap(0xfb01, 0x27e7); // white right square bracket (semantic ket) (301b may be preferable)
    setmap(0xfb02, 0x2229); // intersection
*/

