*PHPINFO DNA*

_This was going to be the beginning of my Dissertation work_

*Contents*
1) collection_tools - tools used to collect PHPINFO files from the internet and save them locally
2) parsing_phpinfo_tools  - tools to parse the collected PHPINFO files and store them into a mysql database 
3) rails_website - ActiveRecord is used to store data in the mysql database, rails provides a nice explorable front-end to the extracted phpinfo data
4) graph_analysis - tools to convert the mysql database into Graph formats compatible with network analysis software such as pyajek
5) misc_graphing_scripts - scripts used in the creation of the graph_analysis code

*Getting Started*

_(How to get a PHD)_

1) Configure rails 
2) Download a bunch of Phpinfo files using the collection tools (I have about 4 GIGs of phpinfo output, but they aren't in GIT)
3) Parse the php info files, and store them in a mysql database
4) use the rails website to browse the collected files, and the graph_analysis scripts to make sense of them
5) write a bunch of papers
6) celebrate!


*Libraries You'll need*

You probably need to install _hpricot_, and at least a few other ruby modules.

Good luck :-)

