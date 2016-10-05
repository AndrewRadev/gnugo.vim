task :default do
  sh 'rspec spec'
end

desc "Prepare archive for deployment"
task :archive do
  sh 'zip -r ~/gnugo.zip autoload/ doc/gnugo.txt ftdetect/ ftplugin/ plugin/ syntax/'
end
