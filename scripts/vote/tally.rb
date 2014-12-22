#!/usr/bin/env ruby

SUBJECTS = "/etc/vote/subjects.json"
VOTEFILE = '.vote.json'
HOMEDIRS = '/home/*/'

class Tallier
  def initialize(subjects, votes)
    @subjects = subjects
    @votes = votes

    @tallylist = Hash[
      subjects.map do |subject, choices|
        [subject, Hash[choices.map{ |choice| [choice, 0] }]]
      # For each subject, turn the list of choices into
      # a hash map of choice => amount
      end
    ]
  end

  def tally!
    @votes.each do |vote|
      vote.each do |subject, choice|
        if @tallylist.has_key?(subject) && @tallylist[subject].include?(choice)
          @tallylist[subject][choice] += 1
        end
      end
    end
  end

  def tallylist
    @tallylist
  end
end

if __FILE__ == $0
  require 'json'
  require 'optparse'

  begin
    subjects = File.open(SUBJECTS) do |file|
      JSON.parse(file.read)
    end
  rescue
    abort "Error parsing subjects file. "\
      "Please make sure there is a valid JSON file at '#{SUBJECTS}'"
  end

  options = {}
  OptionParser.new(width: 20, indent: ' ' * 4) do |opts|
    opts.banner = "Usage: tally [SUBJECT] [options]"
    opts.separator ""
    opts.separator "Options:"

    opts.on("-o", "--output OUTPUT", "Output file, in JSON format.") do |output|
      options[:output] = output
    end

    opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      exit
    end
  end.parse!

  wanted_subject = ARGV.pop

  unless wanted_subject.nil?
    subjects = subjects.select {|subject, _| subject == wanted_subject}
  end

  homes = Dir.glob(HOMEDIRS).select do |home|
    votefile = "#{home}#{VOTEFILE}"
    File.file?(votefile) && !File.zero?(votefile)
  end

  votes = homes.map do |home|
    votestring = File.new("#{home}#{VOTEFILE}").read
    JSON.parse(votestring)
  end

  abort "No votes found!" if votes.nil?

  tallier = Tallier.new(subjects, votes)
  tallier.tally!

  if options[:output]
    begin
      File.open(options[:output], 'w') do |file|
        JSON.dump(tallier.tallylist, file)
      end
    rescue
      abort "Error saving file. Please make sure you're saving "\
      "to a valid location, and that you have write permissions."
    end
  else
    puts "Results:"
    tallier.tallylist.each do |subject, votes|
      puts ' '*2 + "#{subject}:"
      votes.each do |name, amount|
        puts ' '*4 + "#{name}: #{amount}"
      end
    end
  end
end
