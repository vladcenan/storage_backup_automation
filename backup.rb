#!/usr/bin/env ruby
require 'net/ssh'
require 'net/sftp'

script = $PROGRAM_NAME

if ARGV.length != 2
  puts "\nUsage: Please run the script with source_host and source_storage argument: #{script} qa-main1.net /storage"
  puts "\n"
  exit
end

#################################################################################################
#                                                                                               #
# Configuration Parameters                                                                      #
#################################################################################################
source_host, source_storage = ARGV
puts "Source Host: #{source_host}"
puts "Source Storage: #{source_storage}"

backup_server = 'devops-backup.net'
backup_storage = "/backup/#{source_host}/"
public_key = '~/.ssh/root.pem'
backup_user = 'root'
#################################################################################################

Net::SFTP.start(
  "#{source_host}", 'root',
  :keys => [ "#{public_key}" ],) do |sftp|

  sftp.stat!(source_storage) do |response|
    if response.ok?
      puts "#{source_storage} exist on host!"
    else
      puts "#{source_storage} don't exist...Please check!"
      exit
    end
  end
end

Net::SSH.start(
  "#{backup_server}", "#{backup_user}",
  :keys => [ "#{public_key}" ],
) do |ssh|
  
  cmd = "rsync -av -e 'ssh -i #{public_key} -o StrictHostKeyChecking=no' #{backup_user}@#{source_host}:#{source_storage} #{backup_storage}" 
  result = ssh.exec!(cmd)
  puts result 
end
