require require File.join(File.dirname(__FILE__), "..", "awesome_nested_set_patch") 

def find_root(issue)
  if issue.parent_id.nil?
    issue.id
  else
    find_root(Issue.find(issue.parent_id))
  end
end

namespace :tree do
  
  
  task :init => :environment do
    
  end
  task :cleanup => :init do
    puts "removing relations parent and child"
    Issue.connection.execute "delete from issue_relations where relation_type='parents' or relation_type='child';"
  end
  task :rebuild => :init do
    puts "Rebuilding Tree Structure" 
    Issue.rebuild!
  end
  task :reset_root => :init do
    puts "Setting Root id "
    Issue.find(:all).each do |issue|        
      root = find_root(issue)
      issue.reload
      issue.root_id = root      
      issue.save(false) 
    end
  end
  task :copy_parents => :init do
    puts "Coping parents from relations to issues"
    Issue.connection.execute "update issues left join issue_relations on (issues.id = issue_relations.issue_from_id and issue_relations.relation_type='parents') set issues.parent_id = issue_relations.issue_to_id where issues.parent_id is null;"
  end
  task :build => [:copy_parents, :reset_root, :rebuild, :cleanup]
end




