namespace :batch do

  desc 'Constant data updates'
  task :update_constantly => :environment do
    Rails.logger.info "Running hourly update tasks"
    Rake::Task["course:update_courses"].invoke
    Rake::Task["user:update_users"].invoke
    Rake::Task["revision:update_revisions"].invoke
    Rake::Task["cache:update_caches"].invoke
  end

  desc 'Daily data updates'
  task :update_daily => :environment do
    Rails.logger.info "Running daily update tasks"
    Rake::Task["article:update_views"].invoke
    Rake::Task["cache:update_caches"].invoke
  end

  desc 'Initialize the database from scratch'
  task :initialize => :environment do
    Rails.logger.info "Running initialization tasks"
    # Rake::Task["course:update_courses"].invoke
    # Rake::Task["user:update_users"].invoke
    # Rake::Task["revision:update_revisions"].invoke
    # Rake::Task["article:update_views_all_time"].invoke
    # Rake::Task["cache:update_caches"].invoke
    %W[course:update_courses user:update_users revision:update_revisions article:update_views_all_time cache:update_caches].each do |task_name|
      Rake::Task[task_name].invoke
    end
  end

end