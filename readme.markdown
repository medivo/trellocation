Trellocation
===
a tool to generate reports based on trello board lists

setup
---
1. git clone
2. ```$ cp config/configuration.rb.example config/configuration.rb```
3. fill in the values for trello_developer_public_key and trello_member_token in config/configuration.rb
4. set up sql database for Card class, create 'trellocation' database in postgresql.
5. go into 'sql' folder. ```cd sql```
6. ```psql -d trellocation -a -f create_tables.sql```

instructions for generating report for specific trello list
---

1. ```$ rake console```
2. ```pry> list = Trellocation::List.new(trello_list_id goes here)```
3. ```pry> list.generate_output```
4. at the root of this project, there will be file created with the naming structure of "[previous month]_[current year]_[trello board name]_report.markdown".

instructions for running multiple reports at once
---

1. ```$ rake console```
2. ```pry> Trellocation::Report.run```
3. multiple reports will be generated at root of this project.
