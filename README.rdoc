= tickle
  http://github.com/noctivityinc/tickle
  by Joshua Lippiner, Noctivity

== *LEGACY WARNING*

If you starting using Tickle pre version 0.1.X, you will need to update your code to either include the :next_only => true option or read correctly from the options hash.  Sorry.

== DESCRIPTION

Tickle is a natural language parser for recurring events.
 
Tickle is designed to be a compliment of Chronic and can interpret things such as "every 2 days, every Sunday, Sundays, Weekly, etc."

In a lot of ways Tickle is actually an enhancement of Chronic, handling a lot of things that Chronic can't, such as commas and US Holidays (yup - you can do Tickle.parse('Christmas Eve'))

Tickle has one main method, "Tickle.parse," which returns the next time the event should occur, at which point you simply call Tickle.parse again.   

== INSTALLATION

Tickle can be installed via RubyGems:

$ gem install tickle

== TINKERING

Everything's at Github - http://github.com/noctivityinc/tickle

== DEPENDENCIES

chronic gem (gem install chronic)

thoughtbot's shoulda (gem install shoulda)

== USAGE

You can parse strings containing a natural language interval using the Tickle.parse method.

You can either pass a string prefixed with the word "every, each or 'on the'" or simply the time frame.   

Tickle.parse returns a hash containing the following keys:
* next = the next occurrence of the event.  This is NEVER today as its always the next date in the future.
* starting = the date all calculations as based on.  If not passed as an option, the start date is right now.
* until = the last date you want this event to run until.
* expression = this is the natural language expression to store to run through tickle later to get the next occurrence.

Tickle returns nil if it cannot parse the string cannot be parsed.

Tickle HEAVILY uses chronic for parsing but mostly the start and until phrases.

=== OPTIONS

There are two ways to pass options: natural language or an options hash.

NATURAL LANGUAGE:
* Pass a start date with the word "starting, start, stars" (e.g. Tickle.parse('every 3 days starting next friday'))
* Pass an end date with the word "until, end, ends, ending" (e.g. Tickle.parse('every 3 days until next friday'))
* Pass both at the same time (e.g. "starting May 5th repeat every other week until December 1")

OPTIONS HASH
Valid options are:
* start - must be a valid date or Chronic date expression. (e.g. Tickle.parse('every other day', {:start => Date.new(2010,8,1) }))
* until - must be a valid date or Chronic date expression. (e.g. Tickle.parse('every other day', {:until => Date.new(2010,10,1) }))
* next_only - legacy switch to ONLY return the next occurrence as a date and not return a hash

=== SUPER IMPORTANT NOTE ABOUT NEXT OCCURRENCE & START DATE

You may notice when parsing an expression with a start date that the next occurrence IS the start date passed.  This is DESIGNED BEHAVIOR.  

Here's why - assume your user says "remind me every 3 weeks starting Dec 1" and today is May 8th.  Well the first reminder needs to be sent on Dec 1, not Dec 21 (three weeks later). 

If you don't like that, fork and have fun but don't say I didn't warn ya.

=== EXAMPLES

  require 'rubygems'
  require 'tickle'

SIMPLE
    Tickle.parse('day')
      #=> {:next=>2010-05-10 20:57:36 -0400, :expression=>"day", :starting=>2010-05-09 20:57:36 -0400, :until=>nil}

    Tickle.parse('day')
      #=> {:next=>2010-05-10 20:57:36 -0400, :expression=>"day", :starting=>2010-05-09 20:57:36 -0400, :until=>nil}

    Tickle.parse('week')
      #=> {:next=>2010-05-16 20:57:36 -0400, :expression=>"week", :starting=>2010-05-09 20:57:36 -0400, :until=>nil}

    Tickle.parse('month')
      #=> {:next=>2010-06-09 20:57:36 -0400, :expression=>"month", :starting=>2010-05-09 20:57:36 -0400, :until=>nil}

    Tickle.parse('year')
      #=> {:next=>2011-05-09 20:57:36 -0400, :expression=>"year", :starting=>2010-05-09 20:57:36 -0400, :until=>nil}

    Tickle.parse('daily')
      #=> {:next=>2010-05-10 20:57:36 -0400, :expression=>"daily", :starting=>2010-05-09 20:57:36 -0400, :until=>nil}

    Tickle.parse('weekly')
      #=> {:next=>2010-05-16 20:57:36 -0400, :expression=>"weekly", :starting=>2010-05-09 20:57:36 -0400, :until=>nil}

    Tickle.parse('monthly')
      #=> {:next=>2010-06-09 20:57:36 -0400, :expression=>"monthly", :starting=>2010-05-09 20:57:36 -0400, :until=>nil}

    Tickle.parse('yearly')
      #=> {:next=>2011-05-09 20:57:36 -0400, :expression=>"yearly", :starting=>2010-05-09 20:57:36 -0400, :until=>nil}

    Tickle.parse('3 days')
      #=> {:next=>2010-05-12 20:57:36 -0400, :expression=>"3 days", :starting=>2010-05-09 20:57:36 -0400, :until=>nil}

    Tickle.parse('3 weeks')
      #=> {:next=>2010-05-30 20:57:36 -0400, :expression=>"3 weeks", :starting=>2010-05-09 20:57:36 -0400, :until=>nil}

    Tickle.parse('3 months')
      #=> {:next=>2010-08-09 20:57:36 -0400, :expression=>"3 months", :starting=>2010-05-09 20:57:36 -0400, :until=>nil}

    Tickle.parse('3 years')
      #=> {:next=>2013-05-09 20:57:36 -0400, :expression=>"3 years", :starting=>2010-05-09 20:57:36 -0400, :until=>nil}

    Tickle.parse('other day')
      #=> {:next=>2010-05-11 20:57:36 -0400, :expression=>"other day", :starting=>2010-05-09 20:57:36 -0400, :until=>nil}

    Tickle.parse('other week')
      #=> {:next=>2010-05-23 20:57:36 -0400, :expression=>"other week", :starting=>2010-05-09 20:57:36 -0400, :until=>nil}

    Tickle.parse('other month')
      #=> {:next=>2010-07-09 20:57:36 -0400, :expression=>"other month", :starting=>2010-05-09 20:57:36 -0400, :until=>nil}

    Tickle.parse('other year')
      #=> {:next=>2012-05-09 20:57:36 -0400, :expression=>"other year", :starting=>2010-05-09 20:57:36 -0400, :until=>nil}

    Tickle.parse('Monday')
      #=> {:next=>2010-05-10 12:00:00 -0400, :expression=>"monday", :starting=>2010-05-09 20:57:36 -0400, :until=>nil}

    Tickle.parse('Wednesday')
      #=> {:next=>2010-05-12 12:00:00 -0400, :expression=>"wednesday", :starting=>2010-05-09 20:57:36 -0400, :until=>nil}

    Tickle.parse('Friday')
      #=> {:next=>2010-05-14 12:00:00 -0400, :expression=>"friday", :starting=>2010-05-09 20:57:36 -0400, :until=>nil}

    Tickle.parse('February', {:start=>#<Date: 2020-04-01 (4917881/2,0,2299161)>, :now=>#<Date: 2020-04-01 (4917881/2,0,2299161)>})
      #=> {:next=>2021-02-01 12:00:00 -0500, :expression=>"february", :starting=>2020-04-01 00:00:00 -0400, :until=>nil}

    Tickle.parse('May', {:start=>#<Date: 2020-04-01 (4917881/2,0,2299161)>, :now=>#<Date: 2020-04-01 (4917881/2,0,2299161)>})
      #=> {:next=>2020-05-01 12:00:00 -0400, :expression=>"may", :starting=>2020-04-01 00:00:00 -0400, :until=>nil}

    Tickle.parse('june', {:start=>#<Date: 2020-04-01 (4917881/2,0,2299161)>, :now=>#<Date: 2020-04-01 (4917881/2,0,2299161)>})
      #=> {:next=>2020-06-01 12:00:00 -0400, :expression=>"june", :starting=>2020-04-01 00:00:00 -0400, :until=>nil}

    Tickle.parse('beginning of the week')
      #=> {:next=>2010-05-16 12:00:00 -0400, :expression=>"beginning of the week", :starting=>2010-05-09 20:57:36 -0400, :until=>nil}

    Tickle.parse('middle of the week')
      #=> {:next=>2010-05-12 12:00:00 -0400, :expression=>"middle of the week", :starting=>2010-05-09 20:57:36 -0400, :until=>nil}

    Tickle.parse('end of the week')
      #=> {:next=>2010-05-15 12:00:00 -0400, :expression=>"end of the week", :starting=>2010-05-09 20:57:36 -0400, :until=>nil}

    Tickle.parse('beginning of the month', {:start=>#<Date: 2020-04-01 (4917881/2,0,2299161)>, :now=>#<Date: 2020-04-01 (4917881/2,0,2299161)>})
      #=> {:next=>2020-05-01 00:00:00 -0400, :expression=>"beginning of the month", :starting=>2020-04-01 00:00:00 -0400, :until=>nil}

    Tickle.parse('middle of the month', {:start=>#<Date: 2020-04-01 (4917881/2,0,2299161)>, :now=>#<Date: 2020-04-01 (4917881/2,0,2299161)>})
      #=> {:next=>2020-04-15 00:00:00 -0400, :expression=>"middle of the month", :starting=>2020-04-01 00:00:00 -0400, :until=>nil}

    Tickle.parse('end of the month', {:start=>#<Date: 2020-04-01 (4917881/2,0,2299161)>, :now=>#<Date: 2020-04-01 (4917881/2,0,2299161)>})
      #=> {:next=>2020-04-30 00:00:00 -0400, :expression=>"end of the month", :starting=>2020-04-01 00:00:00 -0400, :until=>nil}

    Tickle.parse('beginning of the year', {:start=>#<Date: 2020-04-01 (4917881/2,0,2299161)>, :now=>#<Date: 2020-04-01 (4917881/2,0,2299161)>})
      #=> {:next=>2021-01-01 00:00:00 -0500, :expression=>"beginning of the year", :starting=>2020-04-01 00:00:00 -0400, :until=>nil}

    Tickle.parse('middle of the year', {:start=>#<Date: 2020-04-01 (4917881/2,0,2299161)>, :now=>#<Date: 2020-04-01 (4917881/2,0,2299161)>})
      #=> {:next=>2020-06-15 00:00:00 -0400, :expression=>"middle of the year", :starting=>2020-04-01 00:00:00 -0400, :until=>nil}

    Tickle.parse('end of the year', {:start=>#<Date: 2020-04-01 (4917881/2,0,2299161)>, :now=>#<Date: 2020-04-01 (4917881/2,0,2299161)>})
      #=> {:next=>2020-12-31 00:00:00 -0500, :expression=>"end of the year", :starting=>2020-04-01 00:00:00 -0400, :until=>nil}

    Tickle.parse('the 3rd of May', {:start=>#<Date: 2020-04-01 (4917881/2,0,2299161)>, :now=>#<Date: 2020-04-01 (4917881/2,0,2299161)>})
      #=> {:next=>2020-05-03 00:00:00 -0400, :expression=>"the 3rd of may", :starting=>2020-04-01 00:00:00 -0400, :until=>nil}

    Tickle.parse('the 3rd of February', {:start=>#<Date: 2020-04-01 (4917881/2,0,2299161)>, :now=>#<Date: 2020-04-01 (4917881/2,0,2299161)>})
      #=> {:next=>2021-02-03 00:00:00 -0500, :expression=>"the 3rd of february", :starting=>2020-04-01 00:00:00 -0400, :until=>nil}

    Tickle.parse('the 3rd of February 2022', {:start=>#<Date: 2020-04-01 (4917881/2,0,2299161)>, :now=>#<Date: 2020-04-01 (4917881/2,0,2299161)>})
      #=> {:next=>2022-02-03 00:00:00 -0500, :expression=>"the 3rd of february 2022", :starting=>2020-04-01 00:00:00 -0400, :until=>nil}

    Tickle.parse('the 3rd of Feb 2022', {:start=>#<Date: 2020-04-01 (4917881/2,0,2299161)>, :now=>#<Date: 2020-04-01 (4917881/2,0,2299161)>})
      #=> {:next=>2022-02-03 00:00:00 -0500, :expression=>"the 3rd of feb 2022", :starting=>2020-04-01 00:00:00 -0400, :until=>nil}

    Tickle.parse('the 4th of the month', {:start=>#<Date: 2020-04-01 (4917881/2,0,2299161)>, :now=>#<Date: 2020-04-01 (4917881/2,0,2299161)>})
      #=> {:next=>2020-04-04 00:00:00 -0400, :expression=>"the 4th of the month", :starting=>2020-04-01 00:00:00 -0400, :until=>nil}

    Tickle.parse('the 10th of the month', {:start=>#<Date: 2020-04-01 (4917881/2,0,2299161)>, :now=>#<Date: 2020-04-01 (4917881/2,0,2299161)>})
      #=> {:next=>2020-04-10 00:00:00 -0400, :expression=>"the 10th of the month", :starting=>2020-04-01 00:00:00 -0400, :until=>nil}

    Tickle.parse('the tenth of the month', {:start=>#<Date: 2020-04-01 (4917881/2,0,2299161)>, :now=>#<Date: 2020-04-01 (4917881/2,0,2299161)>})
      #=> {:next=>2020-04-10 00:00:00 -0400, :expression=>"the tenth of the month", :starting=>2020-04-01 00:00:00 -0400, :until=>nil}

    Tickle.parse('first', {:start=>#<Date: 2020-04-01 (4917881/2,0,2299161)>, :now=>#<Date: 2020-04-01 (4917881/2,0,2299161)>})
      #=> {:next=>2020-05-01 00:00:00 -0400, :expression=>"first", :starting=>2020-04-01 00:00:00 -0400, :until=>nil}

    Tickle.parse('the first of the month', {:start=>#<Date: 2020-04-01 (4917881/2,0,2299161)>, :now=>#<Date: 2020-04-01 (4917881/2,0,2299161)>})
      #=> {:next=>2020-05-01 00:00:00 -0400, :expression=>"the first of the month", :starting=>2020-04-01 00:00:00 -0400, :until=>nil}

    Tickle.parse('the thirtieth', {:start=>#<Date: 2020-04-01 (4917881/2,0,2299161)>, :now=>#<Date: 2020-04-01 (4917881/2,0,2299161)>})
      #=> {:next=>2020-04-30 00:00:00 -0400, :expression=>"the thirtieth", :starting=>2020-04-01 00:00:00 -0400, :until=>nil}

    Tickle.parse('the fifth', {:start=>#<Date: 2020-04-01 (4917881/2,0,2299161)>, :now=>#<Date: 2020-04-01 (4917881/2,0,2299161)>})
      #=> {:next=>2020-04-05 00:00:00 -0400, :expression=>"the fifth", :starting=>2020-04-01 00:00:00 -0400, :until=>nil}

    Tickle.parse('the 1st Wednesday of the month', {:start=>#<Date: 2020-04-01 (4917881/2,0,2299161)>, :now=>#<Date: 2020-04-01 (4917881/2,0,2299161)>})
      #=> {:next=>2020-05-01 00:00:00 -0400, :expression=>"the 1st wednesday of the month", :starting=>2020-04-01 00:00:00 -0400, :until=>nil}

    Tickle.parse('the 3rd Sunday of May', {:start=>#<Date: 2020-04-01 (4917881/2,0,2299161)>, :now=>#<Date: 2020-04-01 (4917881/2,0,2299161)>})
      #=> {:next=>2020-05-17 12:00:00 -0400, :expression=>"the 3rd sunday of may", :starting=>2020-04-01 00:00:00 -0400, :until=>nil}

    Tickle.parse('the 3rd Sunday of the month', {:start=>#<Date: 2020-04-01 (4917881/2,0,2299161)>, :now=>#<Date: 2020-04-01 (4917881/2,0,2299161)>})
      #=> {:next=>2020-04-19 12:00:00 -0400, :expression=>"the 3rd sunday of the month", :starting=>2020-04-01 00:00:00 -0400, :until=>nil}

    Tickle.parse('the 23rd of June', {:start=>#<Date: 2020-04-01 (4917881/2,0,2299161)>, :now=>#<Date: 2020-04-01 (4917881/2,0,2299161)>})
      #=> {:next=>2020-06-23 00:00:00 -0400, :expression=>"the 23rd of june", :starting=>2020-04-01 00:00:00 -0400, :until=>nil}

    Tickle.parse('the twenty third of June', {:start=>#<Date: 2020-04-01 (4917881/2,0,2299161)>, :now=>#<Date: 2020-04-01 (4917881/2,0,2299161)>})
      #=> {:next=>2020-06-23 00:00:00 -0400, :expression=>"the twenty third of june", :starting=>2020-04-01 00:00:00 -0400, :until=>nil}

    Tickle.parse('the thirty first of July', {:start=>#<Date: 2020-04-01 (4917881/2,0,2299161)>, :now=>#<Date: 2020-04-01 (4917881/2,0,2299161)>})
      #=> {:next=>2020-07-31 00:00:00 -0400, :expression=>"the thirty first of july", :starting=>2020-04-01 00:00:00 -0400, :until=>nil}

    Tickle.parse('the twenty first', {:start=>#<Date: 2020-04-01 (4917881/2,0,2299161)>, :now=>#<Date: 2020-04-01 (4917881/2,0,2299161)>})
      #=> {:next=>2020-04-21 00:00:00 -0400, :expression=>"the twenty first", :starting=>2020-04-01 00:00:00 -0400, :until=>nil}

    Tickle.parse('the twenty first of the month', {:start=>#<Date: 2020-04-01 (4917881/2,0,2299161)>, :now=>#<Date: 2020-04-01 (4917881/2,0,2299161)>})
      #=> {:next=>2020-04-21 00:00:00 -0400, :expression=>"the twenty first of the month", :starting=>2020-04-01 00:00:00 -0400, :until=>nil}

COMPLEX
    Tickle.parse('starting today and ending one week from now')
      #=> {:next=>2010-05-10 22:30:00 -0400, :expression=>"day", :starting=>2010-05-09 22:30:00 -0400, :until=>2010-05-16 20:57:35 -0400}

    Tickle.parse('starting tomorrow and ending one week from now')
      #=> {:next=>2010-05-10 12:00:00 -0400, :expression=>"day", :starting=>2010-05-10 12:00:00 -0400, :until=>2010-05-16 20:57:35 -0400}

    Tickle.parse('starting Monday repeat every month')
      #=> {:next=>2010-05-10 12:00:00 -0400, :expression=>"month", :starting=>2010-05-10 12:00:00 -0400, :until=>nil}

    Tickle.parse('starting May 13th repeat every week')
      #=> {:next=>2010-05-13 12:00:00 -0400, :expression=>"week", :starting=>2010-05-13 12:00:00 -0400, :until=>nil}

    Tickle.parse('starting May 13th repeat every other day')
      #=> {:next=>2010-05-13 12:00:00 -0400, :expression=>"other day", :starting=>2010-05-13 12:00:00 -0400, :until=>nil}

    Tickle.parse('every other day starts May 13th')
      #=> {:next=>2010-05-13 12:00:00 -0400, :expression=>"other day", :starting=>2010-05-13 12:00:00 -0400, :until=>nil}

    Tickle.parse('every other day starts May 13')
      #=> {:next=>2010-05-13 12:00:00 -0400, :expression=>"other day", :starting=>2010-05-13 12:00:00 -0400, :until=>nil}

    Tickle.parse('every other day starting May 13th')
      #=> {:next=>2010-05-13 12:00:00 -0400, :expression=>"other day", :starting=>2010-05-13 12:00:00 -0400, :until=>nil}

    Tickle.parse('every other day starting May 13')
      #=> {:next=>2010-05-13 12:00:00 -0400, :expression=>"other day", :starting=>2010-05-13 12:00:00 -0400, :until=>nil}

    Tickle.parse('every week starts this wednesday')
      #=> {:next=>2010-05-12 12:00:00 -0400, :expression=>"week", :starting=>2010-05-12 12:00:00 -0400, :until=>nil}

    Tickle.parse('every week starting this wednesday')
      #=> {:next=>2010-05-12 12:00:00 -0400, :expression=>"week", :starting=>2010-05-12 12:00:00 -0400, :until=>nil}

    Tickle.parse('every other day starting May 1st 2021')
      #=> {:next=>2021-05-01 12:00:00 -0400, :expression=>"other day", :starting=>2021-05-01 12:00:00 -0400, :until=>nil}

    Tickle.parse('every other day starting May 1 2021')
      #=> {:next=>2021-05-01 12:00:00 -0400, :expression=>"other day", :starting=>2021-05-01 12:00:00 -0400, :until=>nil}

    Tickle.parse('every other week starting this Sunday')
      #=> {:next=>2010-05-16 12:00:00 -0400, :expression=>"other week", :starting=>2010-05-16 12:00:00 -0400, :until=>nil}

    Tickle.parse('every week starting this wednesday until May 13th')
      #=> {:next=>2010-05-12 12:00:00 -0400, :expression=>"week", :starting=>2010-05-12 12:00:00 -0400, :until=>2010-05-13 12:00:00 -0400}

    Tickle.parse('every week starting this wednesday ends May 13th')
      #=> {:next=>2010-05-12 12:00:00 -0400, :expression=>"week", :starting=>2010-05-12 12:00:00 -0400, :until=>2010-05-13 12:00:00 -0400}

    Tickle.parse('every week starting this wednesday ending May 13th')
      #=> {:next=>2010-05-12 12:00:00 -0400, :expression=>"week", :starting=>2010-05-12 12:00:00 -0400, :until=>2010-05-13 12:00:00 -0400}


OPTIONS HASH
    Tickle.parse('May 1st 2020', {:next_only=>true})
      #=> 2020-05-01 00:00:00 -0400

    Tickle.parse('3 days', {:start=>2010-05-09 20:57:36 -0400})
      #=> {:next=>2010-05-12 20:57:36 -0400, :expression=>"3 days", :starting=>2010-05-09 20:57:36 -0400, :until=>nil}

    Tickle.parse('3 weeks', {:start=>2010-05-09 20:57:36 -0400})
      #=> {:next=>2010-05-30 20:57:36 -0400, :expression=>"3 weeks", :starting=>2010-05-09 20:57:36 -0400, :until=>nil}

    Tickle.parse('3 months', {:start=>2010-05-09 20:57:36 -0400})
      #=> {:next=>2010-08-09 20:57:36 -0400, :expression=>"3 months", :starting=>2010-05-09 20:57:36 -0400, :until=>nil}

    Tickle.parse('3 years', {:start=>2010-05-09 20:57:36 -0400})
      #=> {:next=>2013-05-09 20:57:36 -0400, :expression=>"3 years", :starting=>2010-05-09 20:57:36 -0400, :until=>nil}

    Tickle.parse('3 days', {:start=>2010-05-09 20:57:36 -0400, :until=>2010-10-09 00:00:00 -0400})
      #=> {:next=>2010-05-12 20:57:36 -0400, :expression=>"3 days", :starting=>2010-05-09 20:57:36 -0400, :until=>2010-10-09 00:00:00 -0400}

    Tickle.parse('3 weeks', {:start=>2010-05-09 20:57:36 -0400, :until=>2010-10-09 00:00:00 -0400})
      #=> {:next=>2010-05-30 20:57:36 -0400, :expression=>"3 weeks", :starting=>2010-05-09 20:57:36 -0400, :until=>2010-10-09 00:00:00 -0400}

    Tickle.parse('3 months', {:until=>2010-10-09 00:00:00 -0400})
      #=> {:next=>2010-08-09 20:57:36 -0400, :expression=>"3 months", :starting=>2010-05-09 20:57:36 -0400, :until=>2010-10-09 00:00:00 -0400}

US HOLIDAYS

    Tickle.parse('New Years Day', {:start=>#<Date: 2020-01-01 (4917699/2,0,2299161)>, :now=>#<Date: 2020-01-01 (4917699/2,0,2299161)>})
      #=> {:next=>2021-01-01 12:00:00 -0500, :expression=>"january 1, 2021", :starting=>2020-01-01 00:00:00 -0500, :until=>nil}

    Tickle.parse('Inauguration', {:start=>#<Date: 2020-01-01 (4917699/2,0,2299161)>, :now=>#<Date: 2020-01-01 (4917699/2,0,2299161)>})
      #=> {:next=>2020-01-20 12:00:00 -0500, :expression=>"january 20", :starting=>2020-01-01 00:00:00 -0500, :until=>nil}

    Tickle.parse('Martin Luther King Day', {:start=>#<Date: 2020-01-01 (4917699/2,0,2299161)>, :now=>#<Date: 2020-01-01 (4917699/2,0,2299161)>})
      #=> {:next=>2020-01-20 12:00:00 -0500, :expression=>"third monday in january", :starting=>2020-01-01 00:00:00 -0500, :until=>nil}

    Tickle.parse('MLK', {:start=>#<Date: 2020-01-01 (4917699/2,0,2299161)>, :now=>#<Date: 2020-01-01 (4917699/2,0,2299161)>})
      #=> {:next=>2020-01-20 12:00:00 -0500, :expression=>"third monday in january", :starting=>2020-01-01 00:00:00 -0500, :until=>nil}

    Tickle.parse('Presidents Day', {:start=>#<Date: 2020-01-01 (4917699/2,0,2299161)>, :now=>#<Date: 2020-01-01 (4917699/2,0,2299161)>})
      #=> {:next=>2020-02-17 12:00:00 -0500, :expression=>"third monday in february", :starting=>2020-01-01 00:00:00 -0500, :until=>nil}

    Tickle.parse('Memorial Day', {:start=>#<Date: 2020-01-01 (4917699/2,0,2299161)>, :now=>#<Date: 2020-01-01 (4917699/2,0,2299161)>})
      #=> {:next=>2020-05-25 12:00:00 -0400, :expression=>"4th monday of may", :starting=>2020-01-01 00:00:00 -0500, :until=>nil}

    Tickle.parse('Independence Day', {:start=>#<Date: 2020-01-01 (4917699/2,0,2299161)>, :now=>#<Date: 2020-01-01 (4917699/2,0,2299161)>})
      #=> {:next=>2020-07-04 12:00:00 -0400, :expression=>"july 4, 2020", :starting=>2020-01-01 00:00:00 -0500, :until=>nil}

    Tickle.parse('Labor Day', {:start=>#<Date: 2020-01-01 (4917699/2,0,2299161)>, :now=>#<Date: 2020-01-01 (4917699/2,0,2299161)>})
      #=> {:next=>2020-09-07 12:00:00 -0400, :expression=>"first monday in september", :starting=>2020-01-01 00:00:00 -0500, :until=>nil}

    Tickle.parse('Columbus Day', {:start=>#<Date: 2020-01-01 (4917699/2,0,2299161)>, :now=>#<Date: 2020-01-01 (4917699/2,0,2299161)>})
      #=> {:next=>2020-10-12 12:00:00 -0400, :expression=>"second monday in october", :starting=>2020-01-01 00:00:00 -0500, :until=>nil}

    Tickle.parse('Veterans Day', {:start=>#<Date: 2020-01-01 (4917699/2,0,2299161)>, :now=>#<Date: 2020-01-01 (4917699/2,0,2299161)>})
      #=> {:next=>2020-11-11 12:00:00 -0500, :expression=>"november 11, 2020", :starting=>2020-01-01 00:00:00 -0500, :until=>nil}

    Tickle.parse('Christmas', {:start=>#<Date: 2020-01-01 (4917699/2,0,2299161)>, :now=>#<Date: 2020-01-01 (4917699/2,0,2299161)>})
      #=> {:next=>2020-12-25 12:00:00 -0500, :expression=>"december 25, 2020", :starting=>2020-01-01 00:00:00 -0500, :until=>nil}

    Tickle.parse('Super Bowl Sunday', {:start=>#<Date: 2020-01-01 (4917699/2,0,2299161)>, :now=>#<Date: 2020-01-01 (4917699/2,0,2299161)>})
      #=> {:next=>2020-02-02 12:00:00 -0500, :expression=>"first sunday in february", :starting=>2020-01-01 00:00:00 -0500, :until=>nil}

    Tickle.parse('Groundhog Day', {:start=>#<Date: 2020-01-01 (4917699/2,0,2299161)>, :now=>#<Date: 2020-01-01 (4917699/2,0,2299161)>})
      #=> {:next=>2020-02-02 12:00:00 -0500, :expression=>"february 2, 2020", :starting=>2020-01-01 00:00:00 -0500, :until=>nil}

    Tickle.parse('Valentines Day', {:start=>#<Date: 2020-01-01 (4917699/2,0,2299161)>, :now=>#<Date: 2020-01-01 (4917699/2,0,2299161)>})
      #=> {:next=>2020-02-14 12:00:00 -0500, :expression=>"february 14, 2020", :starting=>2020-01-01 00:00:00 -0500, :until=>nil}

    Tickle.parse('Saint Patricks day', {:start=>#<Date: 2020-01-01 (4917699/2,0,2299161)>, :now=>#<Date: 2020-01-01 (4917699/2,0,2299161)>})
      #=> {:next=>2020-03-17 12:00:00 -0400, :expression=>"march 17, 2020", :starting=>2020-01-01 00:00:00 -0500, :until=>nil}

    Tickle.parse('April Fools Day', {:start=>#<Date: 2020-01-01 (4917699/2,0,2299161)>, :now=>#<Date: 2020-01-01 (4917699/2,0,2299161)>})
      #=> {:next=>2020-04-01 12:00:00 -0400, :expression=>"april 1, 2020", :starting=>2020-01-01 00:00:00 -0500, :until=>nil}

    Tickle.parse('Earth Day', {:start=>#<Date: 2020-01-01 (4917699/2,0,2299161)>, :now=>#<Date: 2020-01-01 (4917699/2,0,2299161)>})
      #=> {:next=>2020-04-22 12:00:00 -0400, :expression=>"april 22, 2020", :starting=>2020-01-01 00:00:00 -0500, :until=>nil}

    Tickle.parse('Arbor Day', {:start=>#<Date: 2020-01-01 (4917699/2,0,2299161)>, :now=>#<Date: 2020-01-01 (4917699/2,0,2299161)>})
      #=> {:next=>2020-04-24 12:00:00 -0400, :expression=>"fourth friday in april", :starting=>2020-01-01 00:00:00 -0500, :until=>nil}

    Tickle.parse('Cinco De Mayo', {:start=>#<Date: 2020-01-01 (4917699/2,0,2299161)>, :now=>#<Date: 2020-01-01 (4917699/2,0,2299161)>})
      #=> {:next=>2020-05-05 12:00:00 -0400, :expression=>"may 5, 2020", :starting=>2020-01-01 00:00:00 -0500, :until=>nil}

    Tickle.parse('Mothers Day', {:start=>#<Date: 2020-01-01 (4917699/2,0,2299161)>, :now=>#<Date: 2020-01-01 (4917699/2,0,2299161)>})
      #=> {:next=>2020-05-10 12:00:00 -0400, :expression=>"second sunday in may", :starting=>2020-01-01 00:00:00 -0500, :until=>nil}

    Tickle.parse('Flag Day', {:start=>#<Date: 2020-01-01 (4917699/2,0,2299161)>, :now=>#<Date: 2020-01-01 (4917699/2,0,2299161)>})
      #=> {:next=>2020-06-14 12:00:00 -0400, :expression=>"june 14, 2020", :starting=>2020-01-01 00:00:00 -0500, :until=>nil}

    Tickle.parse('Fathers Day', {:start=>#<Date: 2020-01-01 (4917699/2,0,2299161)>, :now=>#<Date: 2020-01-01 (4917699/2,0,2299161)>})
      #=> {:next=>2020-06-21 12:00:00 -0400, :expression=>"third sunday in june", :starting=>2020-01-01 00:00:00 -0500, :until=>nil}

    Tickle.parse('Halloween', {:start=>#<Date: 2020-01-01 (4917699/2,0,2299161)>, :now=>#<Date: 2020-01-01 (4917699/2,0,2299161)>})
      #=> {:next=>2020-10-31 12:00:00 -0400, :expression=>"october 31, 2020", :starting=>2020-01-01 00:00:00 -0500, :until=>nil}

    Tickle.parse('Christmas Day', {:start=>#<Date: 2020-01-01 (4917699/2,0,2299161)>, :now=>#<Date: 2020-01-01 (4917699/2,0,2299161)>})
      #=> {:next=>2020-12-25 12:00:00 -0500, :expression=>"december 25, 2020", :starting=>2020-01-01 00:00:00 -0500, :until=>nil}

    Tickle.parse('Christmas Eve', {:start=>#<Date: 2020-01-01 (4917699/2,0,2299161)>, :now=>#<Date: 2020-01-01 (4917699/2,0,2299161)>})
      #=> {:next=>2020-12-24 12:00:00 -0500, :expression=>"december 24, 2020", :starting=>2020-01-01 00:00:00 -0500, :until=>nil}

    Tickle.parse('Kwanzaa', {:start=>#<Date: 2020-01-01 (4917699/2,0,2299161)>, :now=>#<Date: 2020-01-01 (4917699/2,0,2299161)>})
      #=> {:next=>2021-01-01 12:00:00 -0500, :expression=>"january 1, 2021", :starting=>2020-01-01 00:00:00 -0500, :until=>nil}


== USING IN APP

To use in your app, we recommend adding two attributes to your database model:
* next_occurrence
* tickle_expression

Then call Tickle.parse(date expression) when you need to and save the results accordingly.  In your 
code, each day, simply check to see if today is >= next_occurrence and, if so, run your block.

After it completes, call Tickle.parse(tickle_expression) again to update the next occurrence of the event.


== TESTING

Tickle comes with a full testing suite for simple, complex, options hash and invalid arguments.

You also have some command line options:
    --v     verbose output like the examples above
    --d     debug output showing the guts of a date expression

== LIMITATIONS

Currently, Tickle only works for day intervals but feel free to fork and add time-based interval support or send me a note if you really want me to add it.

== CREDIT

HUGE shout-out to both the creator of Chronic, Tom Preston-Werner (http://chronic.rubyforge.org/) as well as Brian Brownling who maintains a github version at http://github.com/mojombo/chronic.

Without their work and code structure I'd be lost.

As always, BIG shout-out to the RVM Master himself, Wayne Seguin, for putting up with me and Ruby from day one.  Ask Wayne to make you some Ciabatta bread next time you see him


== Note on Patches/Pull Requests
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for time-based branches.

== Copyright

Copyright (c) 2010 Joshua Lippiner. See LICENSE for details.
