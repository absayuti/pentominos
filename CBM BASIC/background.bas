1000 poke 53280,0: poke 53281,0
1010 print "{clear}{dark gray}";
1020 for r = 0 to 20
1030     if r/2<>int(r/2) then ch$ = "{cm z}{cm s}" :goto 1050
1040     ch$ = "{cm s}{cm z}"
1050     for c = 1 to 20
1060         print ch$;
1070     next
1080 next