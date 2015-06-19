MODULE enacademic;

IMPORT Unix, Files, Strings := oocStrings, Out := Console;

CONST firstLink="http://armenian.enacademic.com/25054";
      lastLink="http://armenian.enacademic.com/54195";
tmpFile="tmp.html";

filter0='<dt itemprop="title" class="term" lang="hy">';
filter1='<dd itemprop="content" class="descript" lang="hy">';
output="test.tab";

PROCEDURE ReadLine(VAR r: Files.Rider; VAR line: ARRAY OF CHAR);
VAR ch : CHAR;
i : LONGINT;
BEGIN
i := 0;
REPEAT
   Files.Read(r, ch);
   line[i] := ch;
   INC(i);
UNTIL ch = 010X;


END ReadLine;

PROCEDURE ProcessPage(VAR f: Files.File; outrider: Files.Rider; VAR next: ARRAY OF CHAR);
VAR r : Files.Rider;
line, word, description: ARRAY 1024 OF CHAR;
found0, found1, found2, found3, found4, found5 : BOOLEAN;
i, startpos, endpos : INTEGER;
BEGIN

Files.Set(r, f, 0);

REPEAT
   ReadLine(r, line);
   Strings.FindNext(filter0, line, 0, found0, i);
   IF found0 THEN
      Strings.FindNext('>', line, 0, found1, startpos);
	  IF found1 THEN
	     Strings.FindNext("</dt>", line, 0, found2, endpos);
		 IF found2 THEN
	        Strings.Extract(line, i, startpos - endpos, word);
			Files.WriteString(outrider, word);
			Out.String(word); Out.Ln;
			REPEAT
			   ReadLine(r, line);
			   Strings.FindNext(filter1, line, 0, found3, startpos);
               IF found3 THEN
                  Strings.FindNext('>', line, 0, found4, endpos);
                  IF found4 THEN
                     Strings.Extract(line, endpos + 1, Strings.Length(line)-endpos, description);
					 Out.String(description);
				  END
			   END
			UNTIL found3;
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
outFile := Files.New(output);
Files.Set(outRider, outFile, 0);
link:=firstLink;


(*REPEAT*)
   Strings.Extract(link, 31, 5, num);
   Out.String(link); Out.Ln;
   Out.String(num); Out.Ln;

   COPY("", cmd);
   Strings.Append("wget ", cmd);
   Strings.Append(link, cmd);
   Strings.Append(" -O ", cmd);
   Strings.Append(tmpFile, cmd);

   Out.String(cmd); Out.Ln;
   Unix.system(cmd);

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

(*UNTIL num = "54195";*)
END main;


BEGIN
main

END enacademic.
