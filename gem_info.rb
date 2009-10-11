# git_controller.rb
# GemManage
#
# Created by Luke van der Hoeven on 10/10/09.
# Copyright 2009 HungerAndThirst Productions. All rights reserved.

class GemInfo
	attr_accessor :name, :versions

	def initialize(name, version="1.0")
		@name = name
		@versions = version
	end
	
	def latest_version
		ver_set = @versions.split(", ")
		ver_set.sort.last
	end

end