#!/usr/bin/env ruby

SUBJECTS = "/etc/vote/subjects.json"
VOTEFILE = Dir.home + "/.vote.json"

if __FILE__ == $0
  require 'optparse'
  require 'json'

  begin
    subjects = File.open(SUBJECTS) do |file|
      JSON.parse(file.read)
    end
  rescue
    abort "Error parsing subjects file. "\
      "Please make sure there is a valid JSON file at '#{SUBJECTS}'"
  end

  OptionParser.new do |opts|
    opts.banner = "Usage:
      vote SUBJECT CHOICE [options]"
    opts.separator ""
    opts.separator "Options:"

    opts.on('-l', '--list', "List all subjects.") do
      puts "Available subjects:"
      subjects.each do |subject, options|
        puts ' '*2 + "#{subject}:"
        options.each do |option|
          puts ' '*4 + option
        end
      end
      exit
    end

    opts.on_tail('-h', '--help', "Show this message.") do
      puts opts
      exit
    end
  end.parse!

  if ARGV.length < 2
    abort "Not enough arguments! Provide both a subject and a choice."
  elsif ARGV.length > 2
    abort "Too much arguments! Provide just a subject and a choice."
  end

  choice = ARGV.pop
  subject = ARGV.pop

  if !subjects.key?(subject)
    abort "'#{subject}': not a valid subject. Use --list to list available subjects."
  elsif !subjects[subject].include?(choice)
    abort "'#{option}': not a valid choice for '#{subject}'. Use --list to list available subjects."
  end

  votes = {}

  if File.file?(VOTEFILE)
    File.open(VOTEFILE) do |file|
      votes = JSON.parse(file.read)
    end
  end

  votes[subject] = choice

  File.open(VOTEFILE, 'w+') do |file|
    JSON.dump(votes, file)
  end

  puts "Succesfully voted '#{choice}' for '#{subject}'!"
  puts "If you want to change your vote, just run this script again."
end
