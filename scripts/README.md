Scripts
=======
This folder contains custom scripts used on the tilde.red server.

Voting
------
From time to time, the tilde.red admin(s) might need feedback from the community. For this, a vote systen is useful. So `vote` and `tally` are available.

###Vote
The `vote` script allows you to vote for a specific option on a topic. The result gets stored in ~/.vote.json. Editing this manually is not recommended; if there is a a parsing error, your votes will get discarded. Current voting topics are stored in a single topics.json file, probably in ~berkay's directory. This file is edited manually.

    Usage:
        vote TOPIC CHOICE
        vote [-l|--list] [TOPIC]

    Options:
        -l, --list [TOPIC]      List all topics and their options. If the topic is supplied, list the options for that topic.

###Tally
The `tally` script allows you to count the total number of votes for a single topic or all topics. You can optionally output it to a JSON file. This also allows you to essentially make a public API for the vote results: simply have `tally` output to a public location, and run the command periodically using `cron`.

    Usage:
        tally [TOPIC] [options]
    Options:
        -o, --output            Output file, in JSON format
