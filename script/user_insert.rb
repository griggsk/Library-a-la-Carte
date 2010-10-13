#!/usr/bin/env ruby
#
#Install script to populate the subjects, masters table of the database.
#By default, this script looks in lib/subjects.txt, lib/masters.txt and uses the
#abbreviations that work for Oregon State University Libraries.


require File.dirname(__FILE__) + '/../config/boot'
#require 'environment'
require File.dirname(__FILE__) + '/../config/environment'
i = 201
  while (i < 400)
  user = User.new :name => 'test' + i.to_s,
                :password => "p@ssw0rd",
                :password_confirmation => "p@ssw0rd",
                :email => 'test' + i.to_s + '@email.com',
                :role => "pending"
    user.role = "pending" #attr_protected is set, so assigning indirectly
    user.save
    i += 1
  end