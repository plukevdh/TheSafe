# gem_window_controller.rb
# GemManage
#
# Created by Luke van der Hoeven on 10/10/09.
# Copyright 2009 HungerAndThirst Productions. All rights reserved.

require 'gem.rb'

class GemWindowController < NSWindowController

		#windows for the application
	attr_writer :add_sheet, :info_sheet, :main_window		
		#gem list table
	attr_writer :gemTableView
		#inputs for adding a gem
	attr_writer :add_name, :add_version, :add_source, :add_docs
		#outputs for
	attr_writer :info_name, :info_curr_ver, :info_vers
	
	def awakeFromNib
		get_all_gems()
	end
	
	def get_all_gems
			@gems = []
	
		list = `gem list --local`
		lines = list.split("\n")
		lines.each do |g|
			v_start = g.index("(") + 1
			v_end = g.index(")") - 1

			name = g.split(" ").first
			version = g[v_start..v_end]	
			
			@gems << Gem.new(name, version)
		end
		
		@gemTableView.dataSource = self
	end
	
	def info(sender)
		select = @gems[@gemTableView.selectedRow]
		@info_name.stringValue = select.name
		@info_curr_ver.stringValue = select.latest_version
		@info_vers.stringValue = select.versions
	
		NSApp.beginSheet(@info_sheet, 
			modalForWindow:@main_window, 
			modalDelegate:self, 
			didEndSelector:"gem_info",
			contextInfo:nil)			
	end

	def add(sender)
		NSApp.beginSheet(@add_sheet, 
			modalForWindow:@main_window, 
			modalDelegate:self, 
			didEndSelector:"added_gem",
			contextInfo:nil)
	end
	
	def close_info(sender)
		@info_sheet.orderOut(nil)
    NSApp.endSheet(@info_sheet)
	end

	def close_add(sender)
		get_all_gems
		
		@add_sheet.orderOut(nil)
    NSApp.endSheet(@add_sheet)
	end
	
	def gem_info
	end
	
	def update(sender)
		select_name = @gems[@gemTableView.selectedRow].name
		output = `gem update #{select_name}`
		puts output
		
		get_all_gems
	end
	
	def added_gem
		gem_name = @add_name.stringValue
		version = "--version \"= #{@add_version.stringValue}\""
		source = "--source #{@add_source.stringValue}"
		@add_docs.stringValue == "1" ? docs = "" : docs = "--no-rdoc --no-ri"

		action_str = "#{gem_name} #{docs}" 

		if version != "--version "
			action_str += " #{version}"
		end
		
		if source != "--source "
			action_str += " #{source}"
		end
		
		output = `gem install #{action_str}`
		puts output
	end

	def numberOfRowsInTableView(view)
    @gems.size
  end

  def tableView(view, objectValueForTableColumn:column, row:index)
    gem = @gems[index]
    case column.identifier
      when 'name'
        gem.name
      when 'version'
        gem.latest_version
    end
  end
	
end