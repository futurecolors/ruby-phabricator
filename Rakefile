task :default => [:test]

task :test do
  ruby "tests.rb"
end

desc 'Drop and recreate the test database'
task :prepare do
  databaseyml = File.join(redmine, "config", "database.yml")
  unless File.exists? databaseyml
    File.open("redmine/config/database.yml", "w") do |f|
      f.write "test:\n  adapter: mysql\n  database: redmine_test\n  username: root\n  encoding: utf8\n"
    end
  end
end