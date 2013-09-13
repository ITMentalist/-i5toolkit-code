/**
 * @file hosttype.rexx
 *
 * Example REXX program provided by Simon Coulter in a RPG400-L post
 * (http://archive.midrange.com/rpg400-l/200007/msg00554.html) in Jul,
 * 2000.
 */

parse source system .

arg user
say system
select
    when system = 'OS/400' then 'dspusrprf usrprf('user')'
    otherwise say 'don''t know the system'
end
