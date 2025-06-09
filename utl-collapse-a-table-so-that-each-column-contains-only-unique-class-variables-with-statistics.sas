%let pgm=utl-collapse-a-table-so-that-each-column-contains-only-unique-class-variables-with-statistics;

%stop_submission;

Collapse a table so that each column contains only unique class variables with statistics

This is an extension of Mark's algorithm for crating a cardinality matrix.
I think Marks algorithm might have other applications?

github
https://tinyurl.com/3evjh9dt
https://github.com/rogerjdeangelis/utl-collapse-a-table-so-that-each-column-contains-only-unique-class-variables-with-statistics

ORIGINAL POST
github
https://tinyurl.com/mu9synkw
https://github.com/rogerjdeangelis/utl-collapse-a-table-so-that-each-column-contains-only-unique-values-cardinality-matrix

Helpful query
please provide a reproducible example using whichc to find the position of variable value in a sas array of strings

PROBLEM:
========

  Create this output using sashelp.prdsale, where count is the frequency of each invividual class variable

  Do this for every class variable and merge

  proc freq data=prdsale;
    table country / list nopercent nocum ;
  run;quit;

  COUNTRY       Frequency
  -----------------------
  CANADA             226
  GERMANY            232
  U.S.A.             252


             COUNTRY_              REGION_                 DIVISION_                 PRODTYPE_
  COUNTRY      CNT       REGION      CNT      DIVISION        CNT       PRODTYPE        CNT

  CANADA       226        EAST       357      CONSUMER        353       FURNITURE       269
  GERMANY      232        WEST       353      EDUCATION       357       OFFICE          441
  U.S.A.       252


/*******************************************************************************************************************************************/
/*                  INPUT                 |            PROCESS                        |                     OUTPUT                         */
/*                  ====                  |            =======                        |                     ======                         */
/*  Obs COUNTRY REGION DIVISION  PRODTYPE | proc summary data=                        |                                  D            P    */
/*                                        |   prdsale missing;                        |           C                      I            R    */
/*   1  CANADA  EAST  EDUCATION FURNITURE |  class &vars;                             |           O       R              V            O    */
/*   2  CANADA  EAST  EDUCATION FURNITURE |  ways 1;                                  |           U       E              I            D    */
/*   3  CANADA  EAST  EDUCATION FURNITURE |  output out=need;                         |           N       G     D        S    P       T    */
/*   4  CANADA  EAST  EDUCATION FURNITURE | run;                                      |      C    T       I     I        I    R       Y    */
/*   5  CANADA  EAST  EDUCATION FURNITURE |                                           |      O    R   R   O     V        O    O       P    */
/* ....                                   | options missing=" ";                      |      U    Y   E   N     I        N    D       E    */
/* 706  U.S.A.  WEST  CONSUMER  OFFICE    | data need0;                               |      N    _   G   _     S        _    T       _    */
/* 707  U.S.A.  WEST  CONSUMER  OFFICE    |   retain %do_over(_vs,phrase=? ?_cnt);    |      T    C   I   C     I        C    Y       C    */
/* 708  U.S.A.  WEST  CONSUMER  OFFICE    |   set need;                               |      R    N   O   N     O        N    P       N    */
/* 709  U.S.A.  WEST  CONSUMER  OFFICE    |   array vs &vars;                         |      Y    T   N   T     N        T    E       T    */
/* 710  U.S.A.  WEST  CONSUMER  OFFICE    |   array cs $16                            |                                                    */
/*                                        |     %do_over(_vs,phrase=?_cnt);           |  CANADA  226 EAST 357 CONSUMER  353 FURNITURE 269  */
/* %array(_vs,values=                     |   first_nonmiss_index =                   |  GERMANY 232 WEST 353 EDUCATION 357 OFFICE    441  */
/*   country region division prodtype);   |     whichc(coalescec(of vs(*)),of vs(*)); |  U.S.A.  252                                       */
/*                                        |   cs[first_nonmiss_index]=_freq_;         |                                                    */
/* data prdsale;                          |   output;                                 |                                                    */
/*   set sashelp.prdsale                  |   cs[first_nonmiss_index]=.;              |                                                    */
/*    (where=(uniform(12345)<.5));        |   drop _freq_ first_nonmiss_index ;       |                                                    */
/*   keep %do_over(_vs,phrase=?) ;        | run;quit;                                 |                                                    */
/* run;quit;                              |                                           |                                                    */
/*                                        | data need2 ;                              |                                                    */
/*                                        |   set need0;                              |                                                    */
/*                                        |   by _type_;                              |                                                    */
/*                                        |   _row+1;                                 |                                                    */
/*                                        |   if first._type_                         |                                                    */
/*                                        |      then _row=1;                         |                                                    */
/*                                        | run;                                      |                                                    */
/*                                        |                                           |                                                    */
/*                                        | proc sort ;                               |                                                    */
/*                                        |   by _row ;                               |                                                    */
/*                                        | run;                                      |                                                    */
/*                                        |                                           |                                                    */
/*                                        | data want ;                               |                                                    */
/*                                        |   update need2 (obs=0)                    |                                                    */
/*                                        |          need2;                           |                                                    */
/*                                        |   by _row;                                |                                                    */
/*                                        |   drop _type_ _row;                       |                                                    */
/*                                        | run;                                      |                                                    */
/*                                        |                                           |                                                    */
/*                                        | %arraydelete(_vs)                         |                                                    */
/*******************************************************************************************************************************************/

/*                   _
(_)_ __  _ __  _   _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
*/

%arraydelete(_vs);

%array(_vs,values=
  country region division prodtype);

data prdsale;
  set sashelp.prdsale
   (where=(uniform(12345)<.5));
  keep %do_over(_vs,phrase=?) ;
run;quit;

/*******************************************************************************************************************************************/
/*  Obs COUNTRY REGION DIVISION  PRODTYPE                                                                                                  */
/*                                                                                                                                         */
/*   1  CANADA  EAST  EDUCATION FURNITURE                                                                                                  */
/*   2  CANADA  EAST  EDUCATION FURNITURE                                                                                                  */
/*   3  CANADA  EAST  EDUCATION FURNITURE                                                                                                  */
/*   4  CANADA  EAST  EDUCATION FURNITURE                                                                                                  */
/*   5  CANADA  EAST  EDUCATION FURNITURE                                                                                                  */
/* ....                                                                                                                                    */
/* 706  U.S.A.  WEST  CONSUMER  OFFICE                                                                                                     */
/* 707  U.S.A.  WEST  CONSUMER  OFFICE                                                                                                     */
/* 708  U.S.A.  WEST  CONSUMER  OFFICE                                                                                                     */
/* 709  U.S.A.  WEST  CONSUMER  OFFICE                                                                                                     */
/* 710  U.S.A.  WEST  CONSUMER  OFFICE                                                                                                     */
/*******************************************************************************************************************************************/

/*
 _ __  _ __ ___   ___ ___  ___ ___
| `_ \| `__/ _ \ / __/ _ \/ __/ __|
| |_) | | | (_) | (_|  __/\__ \__ \
| .__/|_|  \___/ \___\___||___/___/
|_|
*/

proc datasets lib=sd1 nolist nodetails;
 delete need: want;
run;quit;

proc summary data=
  prdsale missing;
 class &vars;
 ways 1;
 output out=need;
run;

options missing=" ";
data need0;
  retain %do_over(_vs,phrase=? ?_cnt);
  set need;
  array vs &vars;
  array cs $16
    %do_over(_vs,phrase=?_cnt);
  first_nonmiss_index =
    whichc(coalescec(of vs(*)),of vs(*));
  cs[first_nonmiss_index]=_freq_;
  output;
  cs[first_nonmiss_index]=.;
  drop _freq_ first_nonmiss_index ;
run;quit;

data need2 ;
  set need0;
  by _type_;
  _row+1;
  if first._type_
     then _row=1;
run;

proc sort ;
  by _row ;
run;

data want ;
  update need2 (obs=0)
         need2;
  by _row;
  drop _type_ _row;
run;

%arraydelete(_vs)

/*******************************************************************************************************************************************/
/*                     OUTPUT                                                                                                              */
/*                     ======                                                                                                              */
/*                                  D            P                                                                                         */
/*           C                      I            R                                                                                         */
/*           O       R              V            O                                                                                         */
/*           U       E              I            D                                                                                         */
/*           N       G     D        S    P       T                                                                                         */
/*      C    T       I     I        I    R       Y                                                                                         */
/*      O    R   R   O     V        O    O       P                                                                                         */
/*      U    Y   E   N     I        N    D       E                                                                                         */
/*      N    _   G   _     S        _    T       _                                                                                         */
/*      T    C   I   C     I        C    Y       C                                                                                         */
/*      R    N   O   N     O        N    P       N                                                                                         */
/*      Y    T   N   T     N        T    E       T                                                                                         */
/*                                                                                                                                         */
/*  CANADA  226 EAST 357 CONSUMER  353 FURNITURE 269                                                                                       */
/*  GERMANY 232 WEST 353 EDUCATION 357 OFFICE    441                                                                                       */
/*  U.S.A.  252                                                                                                                            */
/*******************************************************************************************************************************************/

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/
