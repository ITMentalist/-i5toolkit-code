/**
 * @file wonder-dog.rexx
 *
 * Example REXX program provided by Simon Coulter in a RPG400-L post
 * (http://archive.midrange.com/rpg400-l/200007/msg00554.html) in Jul,
 * 2000.
 */

/* Rexx the wonder dog */
tally = 0;
number = 0;
say ' ';
say date('w') center("System Calculator", 54) date();
say ' ';
say "Type an arithmetical expression, RESET, or press Enter to end.";
say ' ';
do n = 1 to 400;
    pull expression;
    if expression = '' then exit(0);
    interpret 'tally='expression;
    if expression = 'RESET' | ,
        expression = 'R'     | ,
        expression = 'r' then tally = 0;
    say expression " = " tally;
end
