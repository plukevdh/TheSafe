# gem_window_controller.rb
# GemManage
#
# Created by Luke van der Hoeven on 10/10/09.
# Copyright 2009 HungerAndThirst Productions. All rights reserved.

require 'gem_info.rb'

class GemWindowController < NSWindowController

		#windows for the application
	attr_accessor :add_sheet, :info_sheet, :main_window		
		#gem list table
	attr_accessor :gemTableView
		#inputs for adding a gem
	attr_accessor :add_name, :add_version, :add_source, :add_docs
		#outputs for
	attr_accessor :info_name, :info_curr_ver, :info_vers, :gem_nums
		#segement controller
	attr_accessor :segmentControl
	
	def awakeFromNib
		get_all_gems()
		
		@gem_nums.stringValue = @gem_nums.stringValue.sub("x", @gems.size.to_s)
	end
	
  def windowWillClose(sender)
		exit
  end
	
	def get_all_gems
		@gems = []
	
		Gem.cache.each do |gem|
			name = gem[1].name
			version = gem[1].version.to_s
			@gems << GemInfo.new(name, version)
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
			didEndSelector:nil,
			contextInfo:nil)			
	end

	def add
		NSApp.beginSheet(@add_sheet, 
			modalForWindow:@main_window, 
			modalDelegate:self, 
			didEndSelector:nil,
			contextInfo:nil)
	end
	
	def close_add		
		@add_sheet.orderOut(nil)
    NSApp.endSheet(@add_sheet)
	end

	
	def close_info(sender)
		@info_sheet.orderOut(nil)
    NSApp.endSheet(@info_sheet)
	end
	
	def cancel_add(sender)
		close_add
	end
	
	def update
		select_name = @gems[@gemTableView.selectedRow].name
		NSTask.launchedTaskWithLaunchPath("/usr/local/bin/gem", arguments: ["update", select_name])
		output = `gem update #{select_name}`
		puts output
		
		get_all_gems
	end
	
	def added_gem(sender)
		gem_name = @add_name.stringValue
    args = ['install', gem_name]
    if @add_docs.stringValue == "1"
      args << "--no-rdoc"
      args << "--no-ri"
    end 
    args << "--version \"= #{@add_version.stringValue}\"" unless @add_version.stringValue.empty?
		args << "--source #{@add_source.stringValue}" unless @add_source.stringValue.empty?
		
    task = NSTask.alloc.init
    task.launchPath = "/usr/local/bin/gem"
    task.arguments = args
    task.launch
    task.waitUntilExit
    puts task.terminationStatus
		
		puts "running gem #{args.join(' ')}"
		
		get_all_gems
		close_add
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
	
	def remove
		puts "remove a gem"
		select_name = @gems[@gemTableView.selectedRow].name
		NSTask.launchedTaskWithLaunchPath("/usr/local/bin/gem", arguments: ["uninstall", select_name])
	end
	
	def segmentAction(sender)
		selectedSegment = @segmentControl.selectedSegment();
	
		case selectedSegment
			when 0
				add()
		  when 1
				update()
			when 2
				remove()
		end
	end
end