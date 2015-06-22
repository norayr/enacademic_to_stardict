MODULE enacademic;

IMPORT Unix, Files, Strings := oocStrings, Out := Console, S := SYSTEM;

CONST firstLink="http://armenian.enacademic.com/674/";
(*firstLink="http://armenian.enacademic.com/25054/";*)
      lastLink="http://armenian.enacademic.com/54195/";
tmpFile="tmp.html";

filter='<div id="article"><dl>';
filter0='<dt itemprop="title" class="term" lang="hy">';
filter1='<dd itemprop="content" class="descript" lang="hy">';
filterNL='<li class="next"><a href="http://armenian.enacademic.com/';
output="armenian-enacademic.tab";

PROCEDURE ReadTill(VAR r: Files.Rider; till: CHAR; VAR line: ARRAY OF CHAR);
VAR ch : CHAR;
i : LONGINT;
BEGIN
i := 0;
REPEAT
   Files.Read(r, ch);
   line[i] := ch;
   INC(i);
   IF i = LEN(line) THEN Out.String("Warning: array lenght reached"); Out.Ln END;
UNTIL (ch = till) OR r.eof;
line[i-1] := 0X;
line [i] := 0X;
END ReadTill;


PROCEDURE ReadLine(VAR r: Files.Rider; VAR line: ARRAY OF CHAR);
VAR ch : CHAR;
i : LONGINT;
eol : BOOLEAN;
BEGIN
i := 0;
eol := FALSE;
REPEAT
   Files.Read(r, ch);
   line[i] := ch;
   IF (i > 1) THEN
      IF ((line[i] = 0DX) & (line[i-1]=0AX)) OR ((line[i]=0AX) & (line[i-1]=0DX)) THEN eol := TRUE END;
   END;
   INC(i);
   IF i = LEN(line) THEN 
      Out.String("Warning: array lenght reached"); Out.Ln;
	  Out.String("line = "); Out.String(line); Out.Ln;
   END;
UNTIL eol OR r.eof;
line[i-1] := 0X;
line [i] := 0X;
END ReadLine;

PROCEDURE WriteLine(VAR outrider: Files.Rider; line : ARRAY OF CHAR);
VAR i : INTEGER;
BEGIN
   i := 0;
   REPEAT
      
	  IF line[i] = 0AX THEN
         Files.WriteByte(outrider, 05CX); (* \n *)
		 Files.WriteByte(outrider, 06EX);
	  ELSIF line[i] = 0X THEN
	     (* do nothing *)
      ELSE
         Files.WriteByte(outrider, S.VAL(S.BYTE, line[i]))
      END;
	  INC(i);
   UNTIL (line[i] = 0X) OR (i=LEN(line));
END WriteLine;

PROCEDURE ProcessPage(VAR f: Files.File; VAR outrider: Files.Rider; VAR next: ARRAY OF CHAR);
VAR r : Files.Rider;
line: ARRAY 50000 OF CHAR; 
word, description: ARRAY 50000 OF CHAR;
found0, found1, found2, found3, found4, found5 : BOOLEAN;
i, startpos, endpos, p, pp : INTEGER;
BEGIN

Files.Set(r, f, 0);
Out.String('searching for <div id="article"><dl>'); Out.Ln;
i := 0;
found0 := FALSE;
REPEAT
   ReadLine(r, line);
   INC(i);
   Strings.FindNext(filter, line, 0, found0, startpos);
UNTIL found0;
Out.String("found!"); Out.Ln;
found0 := FALSE;
REPEAT
   ReadLine(r, line);
   Strings.FindNext(filter0, line, 0, found0, i);
   IF found0 THEN
      Strings.FindNext('>', line, 0, found1, startpos);
	  IF found1 THEN
	     INC(startpos);
	     Strings.FindNext("</dt>", line, 0, found2, endpos);
		 IF found2 THEN
		    DEC(endpos);
			Strings.Extract(line, startpos, endpos - startpos + 1, word);
			WriteLine(outrider, word);
			Out.String("word: "); Out.String(word); Out.Ln;
			REPEAT
			   ReadLine(r, line);
			   Strings.FindNext(filter1, line, 0, found3, startpos);

                           IF found3 THEN
                              Strings.FindNext('>', line, 0, found4, startpos);
                              IF found4 THEN
				                 INC(startpos);
								 Strings.FindNext("</dd>", line, 0, found5, endpos);
                                 IF found5 THEN
									DEC(endpos);
									Strings.Extract(line, startpos, endpos - startpos + 1, description);
				                    Out.String("description: ");
				                    Out.String(description); Out.Ln;
					                Out.String("___________________________"); Out.Ln;
									Files.WriteByte(outrider, 09X);
									Files.WriteByte(outrider, 09X);
									Files.WriteByte(outrider, 09X);
									WriteLine(outrider, description);
									Files.WriteByte(outrider, 0AX);
					             END (* found 5 *)
				              END (* found 4 *)
			               END (* found 3 *)
			UNTIL found3;
            (* searching for the next link *)
			found5 := FALSE;
			REPEAT
                           ReadLine(r, line);
                           Strings.FindNext(filterNL, line, 0, found5, startpos);
			UNTIL found5;
			IF found5 THEN
	                   (* getting pos of "/" which is before the number *)
	                   Strings.FindNext("/", line, startpos + 55, found5, p);
	                   (* getting pos of "/" which is after the number   *)
	                   Strings.FindNext("/", line, startpos + 57, found5, pp);
	                   (* startpos + 26 is where the link starts
	                      31 is it's length without a number *)
                           Strings.Extract(line, startpos + 26, 31 + pp - p, next);
			ELSE
			   Out.String("cannot find a next link"); Out.Ln;
			   HALT(1);
			END;
		 END
	  END
   END;
UNTIL r.eof;

END ProcessPage;


PROCEDURE main;
VAR link, nextLink, cmd : ARRAY 256 OF CHAR;
i : LONGINT;
f, outFile : Files.File;
outRider: Files.Rider;
num : ARRAY 32 OF CHAR;
BEGIN

f := Files.Old(tmpFile);
IF f # NIL THEN 
   Files.Purge(f);
   Files.Close(f);
END;   

outFile := Files.New(output);
Files.Set(outRider, outFile, 0);
link:=firstLink;


REPEAT
   Strings.Extract(link, 31, 5, num);
   Out.String(link); Out.Ln;
   Out.String(num); Out.Ln;

   COPY("", cmd);
   Strings.Append("wget -c ", cmd);
   Strings.Append(link, cmd);
   Strings.Append(" -O ", cmd);
   Strings.Append(tmpFile, cmd);

   Out.String(cmd); Out.Ln;
   Unix.system(cmd);
   i := Unix.Sleep(1);
   (*IF i # 0 THEN
      Out.String("cannot call "); Out.String (cmd); Out.Ln;
      HALT(1);
   END;*)

   f := Files.Old(tmpFile);

   IF f = NIL THEN
      Out.String ("cannot open file "); Out.String(tmpFile); Out.Ln;
      HALT(2);
   END;

ProcessPage(f, outRider, nextLink);
Files.Register(outFile);
Out.String ("page processed"); Out.Ln;
Out.String( "next link "); Out.String (nextLink); Out.Ln;
link := nextLink;
Files.Purge(f);
Files.Close(f);
i := Unix.Sleep(1);
UNTIL link = lastLink;

Files.Register(outFile);
Files.Close(outFile);
END main;


BEGIN
main

END enacademic.
